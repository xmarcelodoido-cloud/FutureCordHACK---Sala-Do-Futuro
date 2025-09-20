$port = 8080
$webserver = New-Object System.Net.HttpListener
$webserver.Prefixes.Add("http://localhost:$port/")
$webserver.Start()

Write-Host "Web server started at http://localhost:$port"
Write-Host "Press Ctrl+C to stop the server"

try {
    while ($webserver.IsListening) {
        $context = $webserver.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $requestedFile = $request.Url.LocalPath
        if ($requestedFile -eq "/") {
            $requestedFile = "/index.html"
        }
        
        $filePath = Join-Path $PSScriptRoot $requestedFile.TrimStart('/')
        
        if (Test-Path $filePath) {
            $content = [System.IO.File]::ReadAllBytes($filePath)
            
            # Set content type based on file extension
            switch ([System.IO.Path]::GetExtension($filePath)) {
                ".html" { $response.ContentType = "text/html" }
                ".css" { $response.ContentType = "text/css" }
                ".js" { $response.ContentType = "application/javascript" }
                ".png" { $response.ContentType = "image/png" }
                ".jpg" { $response.ContentType = "image/jpeg" }
                ".gif" { $response.ContentType = "image/gif" }
                default { $response.ContentType = "text/plain" }
            }
            
            $response.ContentLength64 = $content.Length
            $response.OutputStream.Write($content, 0, $content.Length)
        } else {
            $response.StatusCode = 404
            $content = [System.Text.Encoding]::UTF8.GetBytes("File not found")
            $response.OutputStream.Write($content, 0, $content.Length)
        }
        
        $response.Close()
    }
} finally {
    $webserver.Stop()
}