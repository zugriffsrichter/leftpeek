local cam = nil
local state = false
local function destroy()
    if cam then
        SetCamActive(cam, false)
        DestroyCam(cam)
        cam = nil
    end
    state = false
end
local function position()
    local ped = PlayerPedId()
    local pos = GetGameplayCamCoord()
    local rot = GetGameplayCamRot(2)
    local fov = GetGameplayCamFov()
    local rel = GetOffsetFromEntityGivenWorldCoords(ped, pos.x, pos.y, pos.z)
    local world = GetOffsetFromEntityInWorldCoords(ped, rel.x, rel.y, rel.z)
    SetCamCoord(cam, world.x, world.y, world.z)
    SetCamRot(cam, rot.x, rot.y, rot.z, 2)
    AttachCamToEntity(cam, ped, rel.x - 1.0, rel.y, rel.z, true)
    SetCamFov(cam, fov)
    ShowHudComponentThisFrame(14)
end
local function start()
    if GetFollowPedCamViewMode() == 4 or not IsPlayerFreeAiming(PlayerId()) then
        return
    end
    destroy()
    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 0, true, true)
    if not DoesCamExist(cam) then
        destroy()
        return
    end
    state = true
    position()
    Citizen.CreateThread(function()
        while state do
            Citizen.Wait(0)
            
            if GetFollowPedCamViewMode() == 4 or not IsPlayerFreeAiming(PlayerId()) then
                RenderScriptCams(false, true, 0, true, true)
                SetTimeout(200, function()
                    destroy()
                end)
                break
            else
                position()
            end
        end
    end)
end
local function stop()
    if state then
        SetCamAffectsAiming(cam, true)
        RenderScriptCams(false, true, 0, true, true)
        SetTimeout(200, function()
            destroy()
        end)
    end
end
local function toggle()
    if state then
        stop()
    else
        start()
    end
end
RegisterKeyMapping(zugriffsrichter.bind.command, zugriffsrichter.bind.label, 'keyboard', zugriffsrichter.bind.key)
RegisterCommand(zugriffsrichter.bind.command, toggle)
