# =============================================================================
# render-diagrams.ps1
# Render toan bo so do PlantUML trong thu muc PlantUML/ ra anh PNG trong figures/.
# Dung: mo PowerShell tai thu muc goc du an roi chay:
#     powershell -ExecutionPolicy Bypass -File tools\render-diagrams.ps1
# Khong can cai Java rieng neu da co Android Studio (script tu do JDK di kem).
# =============================================================================
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot      # thu muc goc du an (tools/ nam duoi root)
$jar  = Join-Path $PSScriptRoot "plantuml.jar"
$src  = Join-Path $root "PlantUML"
$out  = Join-Path $root "figures"

if (-not (Test-Path $jar)) { throw "Khong thay $jar. Tai plantuml.jar vao thu muc tools/." }

# --- Tim Java theo thu tu uu tien ---
$java = $null
$cands = @()
if ($env:JAVA_HOME) { $cands += (Join-Path $env:JAVA_HOME "bin\java.exe") }
$cands += "C:\Program Files\Android\Android Studio\jbr\bin\java.exe"
$cands += (Join-Path $env:LOCALAPPDATA "Programs\Android Studio\jbr\bin\java.exe")
foreach ($c in $cands) { if ($c -and (Test-Path $c)) { $java = $c; break } }
if (-not $java) {
    $cmd = Get-Command java -ErrorAction SilentlyContinue
    if ($cmd) { $java = $cmd.Source }
}
if (-not $java) { throw "Khong tim thay Java. Cai JDK hoac dat bien moi truong JAVA_HOME." }

Write-Host "Java     : $java"
Write-Host "PlantUML : $jar"
Write-Host "Nguon    : $src"
Write-Host "Dau ra   : $out"

New-Item -ItemType Directory -Force -Path $out | Out-Null

$pumls = Get-ChildItem -Path $src -Filter *.puml
if ($pumls.Count -eq 0) { throw "Khong co tep .puml nao trong $src" }

& $java -jar $jar -tpng -charset UTF-8 -o $out $pumls.FullName
if ($LASTEXITCODE -ne 0) { throw "PlantUML tra ve ma loi $LASTEXITCODE" }

Write-Host ""
Write-Host "Hoan tat. Cac anh PNG da tao trong: $out"
Get-ChildItem $out -Filter *.png | Select-Object Name, @{N='KB';E={'{0:N1}' -f ($_.Length/1KB)}} | Format-Table -AutoSize
