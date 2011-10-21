From: "Woodhouse, David" <david.woodhouse@intel.com>
Subject: caif BUG() with network namespaces
Date: Fri, 21 Oct 2011 20:51:50 +0000
Message-ID: <1319230309.19448.10.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=sha1;
	protocol="application/x-pkcs7-signature"; boundary="=-61wM5VG/zntMOoZK/q+H"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sjur Braendeland <sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35977 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751785Ab1JUUvy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Oct 2011 16:51:54 -0400
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-61wM5VG/zntMOoZK/q+H
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

When Chrome initialises its sandbox, we get a BUG:

[   63.674528] ------------[ cut here ]------------
[   63.674540] kernel BUG at net/caif/caif_dev.c:66!
[   63.674547] invalid opcode: 0000 [#1] PREEMPT SMP=20
[   63.674556] Modules linked in: iwlagn serio_raw [last unloaded: battery]
[   63.674568]=20
[   63.674575] Pid: 801, comm: chrome-sandbox Not tainted 3.0.0-4.1-adaptat=
ion-pc #1 Intel Corporation Cedartrail platform/To be filled by O.E.M.
[   63.674589] EIP: 0060:-[<c0baaf8c>] EFLAGS: 00210246 CPU: 1
[   63.674602] EIP is at caif_device_list+0x4c/0x50
[   63.674608] EAX: 00000000 EBX: 00000000 ECX: e1482800 EDX: 00000010
[   63.674614] ESI: e14133c0 EDI: 00000010 EBP: e141dda0 ESP: e141dd98
[   63.674620]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[   63.674627] Process chrome-sandbox (pid: 801, ti=3De141c000 task=3De52a8=
ff0 task.ti=3De141c000)
[   63.674632] Stack:
[   63.674636]  e1482800 00000000 e141ddd8 c0bab291 c04da339 e141ddd8 c0ad6=
4ff 00000011
[   63.674655]  e14133c0 e141ddd8 c0b335cd e1482800 00000010 c0f612bc 00000=
000 fffffff3
[   63.674672]  e141de08 c046e6e7 e141dde8 c0bcda38 e141de20 e1482800 00000=
010 c0f58ac0
[   63.674690] Call Trace:
[   63.674700]  [<c0bab291>] caif_device_notify+0x21/0x2d0
[   63.674710]  [<c04da339>] ? pcpu_alloc_area+0x109/0x250
[   63.674720]  [<c0ad64ff>] ? inetdev_event+0x1f/0x3a0
[   63.674728]  [<c0b335cd>] ? packet_notifier+0x8d/0x180
[   63.674738]  [<c046e6e7>] notifier_call_chain+0x47/0x90
[   63.674747]  [<c0bcda38>] ? mutex_unlock+0x8/0x10
[   63.674756]  [<c046e77b>] raw_notifier_call_chain+0x1b/0x20
[   63.674766]  [<c0a7d938>] call_netdevice_notifiers+0x28/0x60
[   63.674773]  [<c04dac6a>] ? __alloc_percpu+0xa/0x10
[   63.674782]  [<c0a80c6d>] register_netdevice+0xed/0x210
[   63.674790]  [<c0bcdd0e>] ? mutex_lock+0x1e/0x30
[   63.674797]  [<c0a80da2>] register_netdev+0x12/0x20
[   63.674807]  [<c0868ec3>] loopback_net_init+0x43/0x90
[   63.674815]  [<c0a7864f>] ops_init+0x2f/0x80
[   63.674822]  [<c0a7877f>] setup_net+0x4f/0xe0
[   63.674830]  [<c0a78ccc>] copy_net_ns+0x6c/0xe0
[   63.674838]  [<c046de31>] create_new_namespaces+0xc1/0x150
[   63.674847]  [<c046df82>] copy_namespaces+0x72/0xb0
[   63.674856]  [<c0448efe>] copy_process+0x60e/0xc70
[   63.674864]  [<c04df3c1>] ? handle_mm_fault+0x141/0x250
[   63.674872]  [<c04495ef>] do_fork+0x5f/0x300

Is this already known/fixed?

https://bugs.meego.com/show_bug.cgi?id=3D23540

--=20
                   Sent with MeeGo's ActiveSync support.

David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation



--=-61wM5VG/zntMOoZK/q+H
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIO6jCCAz0w
ggKmoAMCAQICAwWw/zANBgkqhkiG9w0BAQUFADBOMQswCQYDVQQGEwJVUzEQMA4GA1UEChMHRXF1
aWZheDEtMCsGA1UECxMkRXF1aWZheCBTZWN1cmUgQ2VydGlmaWNhdGUgQXV0aG9yaXR5MB4XDTA2
MDIxNjE4MDEzMFoXDTE2MDIxOTE4MDEzMFowUjELMAkGA1UEBhMCVVMxGjAYBgNVBAoTEUludGVs
IENvcnBvcmF0aW9uMScwJQYDVQQDEx5JbnRlbCBFeHRlcm5hbCBCYXNpYyBQb2xpY3kgQ0EwggEi
MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDBpd/XOb9QVqEZ8mQ1042TdOIq3ATDIsV2xDyt
30yLyMR5Wjtus0bn3B+he89BiNO/LP6+rFzEwlD55PlX+HLGIKeNNG97dqyc30FElEUjZzTZFq2N
4e3kVJ/XAEEgANzV8v9qp7qWwxugPgfc3z9BkYot+CifozexHLb/hEZj+yISCU61kRZvuSQ0E11y
YL4dRgcglJeaHo3oX57rvIckaLsYV5/1Aj+R8DM1Ppk965XQAKsHfnyT7C4S50T4lVn4lz36wOdN
Zn/zegG1zp41lnoTFfT4KuKVJH5x7YD1p6KbgJCKLovnujGuohquBNfdXKpZkvz6pGv+iC1HawJd
AgMBAAGjgaAwgZ0wDgYDVR0PAQH/BAQDAgEGMB0GA1UdDgQWBBQaxgxKxEdvqNutK/D0Vgaj7TdU
DDA6BgNVHR8EMzAxMC+gLaArhilodHRwOi8vY3JsLmdlb3RydXN0LmNvbS9jcmxzL3NlY3VyZWNh
LmNybDAfBgNVHSMEGDAWgBRI5mj5K9KylddH2CMgEE8zmJCf1DAPBgNVHRMBAf8EBTADAQH/MA0G
CSqGSIb3DQEBBQUAA4GBABMQOK2kVKVIlUWwLTdywJ+e2O+PC/uQltK2F3lRyrPfBn69tOkIP4Sg
DJOfsxyobIrPLe75kBLw+Dom13OBDp/EMZJZ1CglQfVV8co9mT3aZMjSGGQiMgkJLR3jMfr900fX
ZKj5XeqCJ+JP0mEhJGEdVCY+FFlksJjV86fDrq1QMIIFijCCBHKgAwIBAgIKYR6AtwAAAAAABzAN
BgkqhkiG9w0BAQUFADBSMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9yYXRpb24x
JzAlBgNVBAMTHkludGVsIEV4dGVybmFsIEJhc2ljIFBvbGljeSBDQTAeFw0wOTA1MTUxOTI1MTNa
Fw0xNTA1MTUxOTM1MTNaMFYxCzAJBgNVBAYTAlVTMRowGAYDVQQKExFJbnRlbCBDb3Jwb3JhdGlv
bjErMCkGA1UEAxMiSW50ZWwgRXh0ZXJuYWwgQmFzaWMgSXNzdWluZyBDQSAzQTCCASIwDQYJKoZI
hvcNAQEBBQADggEPADCCAQoCggEBAMGPgGLnOO5IOzlHRfr1XfCVb97V4BR2QVpPZ7CrcIQ+FGa2
KHD/6dPjwxOIrtFTdfW4BYikdFmxUZVBWRWZ5Vye2cCdGzFWqIEOE1e17nNx1jM8Z6GZEqbDUS+v
BuPlBFHKQoVm5BaNIHpyn2XZxqwjV9j5/crIfPrCGstk+2ztUhVS8OHEgzO784PgD9pOgBnnAbZH
mEM1FYYmQ6ibS+gVCHzobDYG+YReRiHpFKWBxpUuP+X0WYFw/Ja1JW7N8pELAFDw0UFBWFgiv1QI
usdLvSy8mcsLJ5wy050OVcxShqoUxhw/wvyuuoQxvmEPjhRa1C2oSCmGN0003GMhQWMCAwEAAaOC
AlwwggJYMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFKoWZq+3PVZTYK4Nwu3z7gfLUWB+MAsG
A1UdDwQEAwIBhjASBgkrBgEEAYI3FQEEBQIDAQABMCMGCSsGAQQBgjcVAgQWBBTCKwhTx+hdMsKC
gOmWwLgjQsAV+TAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAfBgNVHSMEGDAWgBQaxgxKxEdv
qNutK/D0Vgaj7TdUDDCBvQYDVR0fBIG1MIGyMIGvoIGsoIGphk5odHRwOi8vd3d3LmludGVsLmNv
bS9yZXBvc2l0b3J5L0NSTC9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBQb2xpY3klMjBDQS5j
cmyGV2h0dHA6Ly9jZXJ0aWZpY2F0ZXMuaW50ZWwuY29tL3JlcG9zaXRvcnkvQ1JML0ludGVsJTIw
RXh0ZXJuYWwlMjBCYXNpYyUyMFBvbGljeSUyMENBLmNybDCB4wYIKwYBBQUHAQEEgdYwgdMwYwYI
KwYBBQUHMAKGV2h0dHA6Ly93d3cuaW50ZWwuY29tL3JlcG9zaXRvcnkvY2VydGlmaWNhdGVzL0lu
dGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMFBvbGljeSUyMENBLmNydDBsBggrBgEFBQcwAoZgaHR0
cDovL2NlcnRpZmljYXRlcy5pbnRlbC5jb20vcmVwb3NpdG9yeS9jZXJ0aWZpY2F0ZXMvSW50ZWwl
MjBFeHRlcm5hbCUyMEJhc2ljJTIwUG9saWN5JTIwQ0EuY3J0MA0GCSqGSIb3DQEBBQUAA4IBAQCU
Y/1d0MS6VPTlIcOho1XWh193PD5kJDJSPdphLHQdM1oKA+whMdIBoY1VzTDDK+C+Ey4Jcyna7fpC
8uVmn/Rz/i9MZtyc7qezPtZTn9UyORvJmddH+Ox/RycGwe3ags8jUdspECorYOkJyZksnDIlTVUv
bR7wyY+gGJYqxWXqrcVFEiMsWu8/OIlf7F2gAYMBw1kZ55dn4lWBIM0WqvReWpPvhYeN7Y+3MKEd
SMkQ7TZiNbfdZ5D/8KfWNMTJ4VHltOgCL1lA5tx/F4R1920skpL5eu3Sj650RUe3rOXsaV5NyJzB
wB31+1zsmleVdFD0k/Fw9HxXbAQE35ucN/7CMIIGFzCCBP+gAwIBAgIKEIhPUAABAABfaTANBgkq
hkiG9w0BAQUFADBWMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9yYXRpb24xKzAp
BgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3VpbmcgQ0EgM0EwHhcNMTEwNDEyMTIzMzQx
WhcNMTQwMzI3MTIzMzQxWjBFMRkwFwYDVQQDExBXb29kaG91c2UsIERhdmlkMSgwJgYJKoZIhvcN
AQkBFhlkYXZpZC53b29kaG91c2VAaW50ZWwuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEAvxW1JMLaZUeM6Cg2OVV1nfsZOt9x/CjVJ7SBlapefSjUoNT48n58zLK+Q00YxPkIxnwl
m57dAxSUf/Dqg+C6DOdLknVQILrGeWNSZdC8GQ8HlHz+D5ldgTDY9L1vDM65p1wbXW4R5QfMbooZ
IQKlyUivGkggwBUpTeeXDOfz5f4m2UW5aCnyG8yhiBUHISAQyXLwQg+iVhBpTqsVvvojybQY8lGF
Z7U+kgbgBY0HCqOuEmT7Iz/tm4W3dpfh8mFluZUn1fMBvCaC+cdKVV/1lpeUdtMNREH+jKUU49lt
BblH1qXmEViOvMT4itbfkUSWeWgeI9umMOK4eL31LLepCQIDAQABo4IC9jCCAvIwCwYDVR0PBAQD
AgeAMDwGCSsGAQQBgjcVBwQvMC0GJSsGAQQBgjcVCIbDjHWEmeVRg/2BKIWOn1OCkcAJZ4HevTmV
8EMCAWQCAQgwHQYDVR0OBBYEFMcuq9ocKJ7EbWcVlAWTYVXwOsrHMB8GA1UdIwQYMBaAFKoWZq+3
PVZTYK4Nwu3z7gfLUWB+MIHPBgNVHR8EgccwgcQwgcGggb6ggbuGV2h0dHA6Ly93d3cuaW50ZWwu
Y29tL3JlcG9zaXRvcnkvQ1JML0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMElzc3VpbmclMjBD
QSUyMDNBKDEpLmNybIZgaHR0cDovL2NlcnRpZmljYXRlcy5pbnRlbC5jb20vcmVwb3NpdG9yeS9D
UkwvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIwSXNzdWluZyUyMENBJTIwM0EoMSkuY3JsMIH1
BggrBgEFBQcBAQSB6DCB5TBsBggrBgEFBQcwAoZgaHR0cDovL3d3dy5pbnRlbC5jb20vcmVwb3Np
dG9yeS9jZXJ0aWZpY2F0ZXMvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIwSXNzdWluZyUyMENB
JTIwM0EoMSkuY3J0MHUGCCsGAQUFBzAChmlodHRwOi8vY2VydGlmaWNhdGVzLmludGVsLmNvbS9y
ZXBvc2l0b3J5L2NlcnRpZmljYXRlcy9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBJc3N1aW5n
JTIwQ0ElMjAzQSgxKS5jcnQwHwYDVR0lBBgwFgYIKwYBBQUHAwQGCisGAQQBgjcKAwwwKQYJKwYB
BAGCNxUKBBwwGjAKBggrBgEFBQcDBDAMBgorBgEEAYI3CgMMME8GA1UdEQRIMEagKQYKKwYBBAGC
NxQCA6AbDBlkYXZpZC53b29kaG91c2VAaW50ZWwuY29tgRlkYXZpZC53b29kaG91c2VAaW50ZWwu
Y29tMA0GCSqGSIb3DQEBBQUAA4IBAQBxLiiAAGnWEDYYtUaje48WjSbMx8O+TsKX2x1sgi/ilnUR
evhznvvFGx9hRrTtQ4Sz+hU7nWvoxbSLDVx6vDQ7+wyGo6SzE0MYqwB3EzwO/P8MnpgZTlEmgDeP
GjYX2IFzp5fG7NNvc6byf8pLjXgn+2wqRLUqrh2PZZ5KKIiicVNT+UOlRIbB2T1WuSVHBMQxhQBr
rzwwYuyoawJCHHo+eKUE51cSSzkT95K+m0Q6XYGC8tQ3i94nBIaLMIg/GM6K2cYKH3vdu/otvGPl
j9/HEKo+mktp2A2S5sIwCKlw8nYOaYKe1dpmYtXKfVoOIIZ/LaVEB/XEIEC1x/oPbrH/MYIB6jCC
AeYCAQEwZDBWMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9yYXRpb24xKzApBgNV
BAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3VpbmcgQ0EgM0ECChCIT1AAAQAAX2kwCQYFKw4D
AhoFAKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTExMTAyMTIw
NTE0OVowIwYJKoZIhvcNAQkEMRYEFMkywgEM9VUvGOSBNiSF6pdpcAUmMA0GCSqGSIb3DQEBAQUA
BIIBAL4DHBtVnMXzAut8aHwM6qfnvRUWwEDLQnX2ODje8FuFrg2epr4Cu1LVod5vj+t+as88coDH
UwCp4Hu8qqeQEl1bgX5HonufzIqjuthZIt91HN61jbG2+Gl/4aMS28uqzsekYmV4LA68566hS2An
IpvYRtcvtyZVKmeoAZiergtu/Qxx82by/MP5qrO9+WZhVnxzVT8MHXdchGRdjqdKJO8vt+GwgihE
1bccJ935kohpmzEXfjCqlJjhbr/KLbcTxMT4Jo4s4W0YAl4EDiGfx2oGQK288d0Njp98McAEOYFR
iK4q7gI3bup36VhQplMTnqbw0O4ew5WYLjcKTZQ7UysAAAAAAAA=


--=-61wM5VG/zntMOoZK/q+H--
