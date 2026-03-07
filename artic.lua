local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local AIM_KEY = Enum.KeyCode.Q
local SNAP_SPEED = 0.4
local TRIGGER_DIST = 35
local TRIGGER_FOV = 20

local BODY_PARTS = {
    "Head", "UpperTorso", "LowerTorso", "Torso", 
    "Left Leg", "Right Leg", "Left Arm", "Right Arm"
}

local targetPart = nil
local isGrabbing = false

local function getClosestRandomPart()
    local shortestDistance = math.huge
    local chosenPart = nil

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local human = player.Character:FindFirstChildOfClass("Humanoid")
            
            if root and human and human.Health > 0 then
                local dist = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                
                if dist < shortestDistance then
                    local availableParts = {}
                    for _, name in pairs(BODY_PARTS) do
                        local p = player.Character:FindFirstChild(name)
                        if p and p:IsA("BasePart") then table.insert(availableParts, p) end
                    end
                    
                    if #availableParts > 0 then
                        shortestDistance = dist
                        chosenPart = availableParts[math.random(1, #availableParts)]
                    end
                end
            end
        end
    end
    return chosenPart
end

RunService.RenderStepped:Connect(function()
    if UserInputService:IsKeyDown(AIM_KEY) then
        if not targetPart or not targetPart.Parent or targetPart.Parent:FindFirstChildOfClass("Humanoid").Health <= 0 then
            targetPart = getClosestRandomPart()
        end

        if targetPart then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, SNAP_SPEED)

            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            local worldDist = (targetPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude

            if onScreen and screenDist < TRIGGER_FOV and worldDist < TRIGGER_DIST and not isGrabbing then
                isGrabbing = true
                
                VIM:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, true, game, 1)
                task.wait(0.05)
                VIM:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, false, game, 1)
                
                task.delay(1.2, function()
                    isGrabbing = false
                end)
            end
        end
    else
        targetPart = nil
        isGrabbing = false
    end
end)
