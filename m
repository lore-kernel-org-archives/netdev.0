From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: How to indenfy the real physical network interface?
Date: Mon, 07 Nov 2011 21:06:37 -0800
Message-ID: <1320728797.2545.19.camel@ppwaskie-mobl2>
References: <CAFcFeQJsnqPvgQs+hAvrUmEeMVaD4U1V2xbN68SMqxsjpdXvOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha1"; protocol="application/x-pkcs7-signature"; boundary="=-LeZulbx1/ys24jCCiehr"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: santosh <ysan99@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27131 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878Ab1KHFGl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Nov 2011 00:06:41 -0500
In-Reply-To: <CAFcFeQJsnqPvgQs+hAvrUmEeMVaD4U1V2xbN68SMqxsjpdXvOg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-LeZulbx1/ys24jCCiehr
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-11-07 at 05:59 -0800, santosh wrote:
> Hi,
>=20
> I am posting this question to "netdev" mailing list because I could
> not find "linux-net" mailing list as suggested at
> http://kernelnewbies.org/ML .

I'm not aware of the networking "user" mailing list, this is the
development mailing list.

>=20
> I have a wireless device running on Linux 2.6.15. (Can't upgrade to
> latest at this time).
>=20
> It has 3 interfaces.
>  ath0 - Wireless interface.
>  eth0 - Ethernet interface.
>  br0 - Bridge interface joining ath0 and eth0.
>=20
> I have a user space socket program that listens to the broadcast
> messages and responds.
> My socket is opened as sock =3D socket(PF_INET, SOCK_DGRAM, 0).
>=20
> I need this socket program to listen for the packet coming from
> Ethernet interface only.
> Or, this socket program should be able to figure out the actual
> interface the packet come from.
>=20
> I tried below methods but both doesn't help me because kernel is
> giving bridge as interface and not giving the real interface to socket
> program.
>=20
> 1. //setsockopt(sock, SOL_SOCKET, SO_BINDTODEVICE, "br0", 3)
>  setsockopt(sock, SOL_SOCKET, SO_BINDTODEVICE, "eth0", 4)
>=20
> 2. setsockopt(sock, SOL_IP, IP_PKTINFO, (char *) &on, sizeof on)
>  // Use recvmsg instead of recvfrom and read the interface index.
>  // If interface is not Ethernet do not respond.
>=20
> Can you please let me know if there is a way to identify the actual
> interface in a UDP socket program when traffic is being controlled by
> a Bridge?

Not in the kernel you're using, that's a very old kernel.  I made some
changes in the 2.6.22 kernel (also ancient) that would allow the "real"
device to be returned instead of a bridge or bond device.  I think
you're SOL if you want this behavior, but can't upgrade to a much more
sane kernel.  The issue is the "real" device is resolved to the bridge
device in the socket code, since that is what the routing table
eventually sends stuff out on (before resolving to the "real" device in
the networking core layer).

Upgrade to a much more recent kernel to at least test.  Otherwise
there's nothing anyone here can do.

Cheers,
-PJ

--=20
Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
LAN Access Division, Intel Corporation

--=-LeZulbx1/ys24jCCiehr
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIPAjCCAz0w
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
ZKj5XeqCJ+JP0mEhJGEdVCY+FFlksJjV86fDrq1QMIIFijCCBHKgAwIBAgIKYSCKYgAAAAAACDAN
BgkqhkiG9w0BAQUFADBSMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9yYXRpb24x
JzAlBgNVBAMTHkludGVsIEV4dGVybmFsIEJhc2ljIFBvbGljeSBDQTAeFw0wOTA1MTUxOTI3MjZa
Fw0xNTA1MTUxOTM3MjZaMFYxCzAJBgNVBAYTAlVTMRowGAYDVQQKExFJbnRlbCBDb3Jwb3JhdGlv
bjErMCkGA1UEAxMiSW50ZWwgRXh0ZXJuYWwgQmFzaWMgSXNzdWluZyBDQSAzQjCCASIwDQYJKoZI
hvcNAQEBBQADggEPADCCAQoCggEBAKQEM1Wn9TU9vc9C+/Tc7KB+eiYElmrcEWE32WUdHvWG+IcQ
HVQsikTmMyKKojNLw2B5s6Iekc8ivDo/wCfjZzX9JyftMnc+AArc0la87Olybzm8K9jXEfTBvTnU
SFSiI9ZYefITdiUgqlAFuljFZEHYKYtLuhrRacpmQfP4mV63NKdc2bT804HRf6YptZFa4k6YN94z
lrGNrBuQQ74WFzz/jLBusbUpEkro6Mu/ZYFOFWQrV9lBhF9Ruk8yN+3N6n9fUo/qBigiF2kEn9xV
h1ykl7SCGL2jBUkXx4qgV27a6Si8lRRdgrHGtN/HWnSWlLXTH5l575H4Lq++77OFv38CAwEAAaOC
AlwwggJYMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFA7GKvdZsggQkCVvw939imYxMCvFMAsG
A1UdDwQEAwIBhjASBgkrBgEEAYI3FQEEBQIDAQABMCMGCSsGAQQBgjcVAgQWBBQ5oFY2ekKQ/5Kt
im+VdMeSWb4QWTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAfBgNVHSMEGDAWgBQaxgxKxEdv
qNutK/D0Vgaj7TdUDDCBvQYDVR0fBIG1MIGyMIGvoIGsoIGphk5odHRwOi8vd3d3LmludGVsLmNv
bS9yZXBvc2l0b3J5L0NSTC9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBQb2xpY3klMjBDQS5j
cmyGV2h0dHA6Ly9jZXJ0aWZpY2F0ZXMuaW50ZWwuY29tL3JlcG9zaXRvcnkvQ1JML0ludGVsJTIw
RXh0ZXJuYWwlMjBCYXNpYyUyMFBvbGljeSUyMENBLmNybDCB4wYIKwYBBQUHAQEEgdYwgdMwYwYI
KwYBBQUHMAKGV2h0dHA6Ly93d3cuaW50ZWwuY29tL3JlcG9zaXRvcnkvY2VydGlmaWNhdGVzL0lu
dGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMFBvbGljeSUyMENBLmNydDBsBggrBgEFBQcwAoZgaHR0
cDovL2NlcnRpZmljYXRlcy5pbnRlbC5jb20vcmVwb3NpdG9yeS9jZXJ0aWZpY2F0ZXMvSW50ZWwl
MjBFeHRlcm5hbCUyMEJhc2ljJTIwUG9saWN5JTIwQ0EuY3J0MA0GCSqGSIb3DQEBBQUAA4IBAQCx
tQEHchVQhXyjEqtMVUMe6gkmPsIczHxSeqNbo9dsD+6xbT65JT+oYgpIAtfEsYXeUJu1cChqpb22
U5bMAz7eaQcW5bzefufWvA6lg2048B8oczBj/q+5P5NpYrUO8jOmN4jTjfJq3ElZ7yFWpy7rB3Vm
/aN6ATYqWfMbS/xfh+JCxmH3droUmMJI0/aZJHsLtjbjFnNsHDNrJZX1vxlM78Lb1hjskTENPmhb
VbfTj5i/ZGnhv4tmI8QZPCNtcegXJrfhRl2D9bWpdTOPrWiLDUqzy1Z6KL7TcOS/PCl8RHCJXkPa
u/thTQCpIoDa2+c+3XA++gRTfAQ4svTO260NMIIGLzCCBRegAwIBAgIKf0es/QABAABRFTANBgkq
hkiG9w0BAQUFADBWMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9yYXRpb24xKzAp
BgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3VpbmcgQ0EgM0IwHhcNMTAwNDA5MDgyNzMw
WhcNMTMwMzI0MDgyNzMwWjBRMR8wHQYDVQQDExZXYXNraWV3aWN6IEpyLCBQZXRlciBQMS4wLAYJ
KoZIhvcNAQkBFh9wZXRlci5wLndhc2tpZXdpY3ouanJAaW50ZWwuY29tMIIBIjANBgkqhkiG9w0B
AQEFAAOCAQ8AMIIBCgKCAQEAxNvzDG+qS7UFSaYiqMqQr7exXHirCVe1tapLZoFlJZLPfqZsBsAA
UqARnY+v3RQj3WDmoIOtTMHxtnmo4pd5UXrsk+PraedGAilso9tkfp5ZjRjZo9LL06AZzjiBVfAx
gvyxMPsoKhdfFijzqSJRpc12kB662PAJWfyJO+f6lg5+Cd4KgRVGrpGI4bvBKEVGMeOqwD+kcVti
wRcqNygx35GqdcpJCCJqOSAJsLI3DR7tDvATeNzsasweaHgWonaK4D6qaHkoGx4VHknC6uNn/FK/
wXtFbXkeOrnRGJIzaZNsOBVhTou9w3NYU1EjuK75hZJ4Fd4/r1gHafxWD+VzrwIDAQABo4IDAjCC
Av4wCwYDVR0PBAQDAgeAMDwGCSsGAQQBgjcVBwQvMC0GJSsGAQQBgjcVCIbDjHWEmeVRg/2BKIWO
n1OCkcAJZ4HevTmV8EMCAWQCAQgwHQYDVR0OBBYEFLtB44dRTSgY1071RY+nMiKRkn1PMB8GA1Ud
IwQYMBaAFA7GKvdZsggQkCVvw939imYxMCvFMIHPBgNVHR8EgccwgcQwgcGggb6ggbuGV2h0dHA6
Ly93d3cuaW50ZWwuY29tL3JlcG9zaXRvcnkvQ1JML0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUy
MElzc3VpbmclMjBDQSUyMDNCKDEpLmNybIZgaHR0cDovL2NlcnRpZmljYXRlcy5pbnRlbC5jb20v
cmVwb3NpdG9yeS9DUkwvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIwSXNzdWluZyUyMENBJTIw
M0IoMSkuY3JsMIH1BggrBgEFBQcBAQSB6DCB5TBsBggrBgEFBQcwAoZgaHR0cDovL3d3dy5pbnRl
bC5jb20vcmVwb3NpdG9yeS9jZXJ0aWZpY2F0ZXMvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIw
SXNzdWluZyUyMENBJTIwM0IoMSkuY3J0MHUGCCsGAQUFBzAChmlodHRwOi8vY2VydGlmaWNhdGVz
LmludGVsLmNvbS9yZXBvc2l0b3J5L2NlcnRpZmljYXRlcy9JbnRlbCUyMEV4dGVybmFsJTIwQmFz
aWMlMjBJc3N1aW5nJTIwQ0ElMjAzQigxKS5jcnQwHwYDVR0lBBgwFgYIKwYBBQUHAwQGCisGAQQB
gjcKAwwwKQYJKwYBBAGCNxUKBBwwGjAKBggrBgEFBQcDBDAMBgorBgEEAYI3CgMMMFsGA1UdEQRU
MFKgLwYKKwYBBAGCNxQCA6AhDB9wZXRlci5wLndhc2tpZXdpY3ouanJAaW50ZWwuY29tgR9wZXRl
ci5wLndhc2tpZXdpY3ouanJAaW50ZWwuY29tMA0GCSqGSIb3DQEBBQUAA4IBAQBYea1KThIl9gNf
1uIob1trWtsthhWAXsdUu1V+gl10RBChuM4okZccJf1JXItFA2z7J2UR4cu/tRZBRFartVPhGBjK
ntLofxsaW7wwzfsinbNy30gHGShG83XDADdGUteL8PmupDcDf/MtbRIlfjEknLiuOnrM25WVajtB
3fB1pOA2jmLaaNmasza9ordaD3afJD3IWr/Zj+aevMu4zrKzwdOZqBZW1J1Qc7uog8Mn+mm+wRMm
EY0z7VFdjsZjJH9EQA0UbF1aYcshv0a/M2deKN9TdYuJ1eTKRSZdzSiRG5w75xujFMYZgo4ETlu1
Behgey1jvJiyWdOsPt7at08QMYIB6jCCAeYCAQEwZDBWMQswCQYDVQQGEwJVUzEaMBgGA1UEChMR
SW50ZWwgQ29ycG9yYXRpb24xKzApBgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3Vpbmcg
Q0EgM0ICCn9HrP0AAQAAURUwCQYFKw4DAhoFAKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEw
HAYJKoZIhvcNAQkFMQ8XDTExMTEwODA1MDYzN1owIwYJKoZIhvcNAQkEMRYEFH5Ys4LdGYhAsE0u
NI5oAfXalh1WMA0GCSqGSIb3DQEBAQUABIIBAAqzpel/1SZ4DZL/QQImKEgmFh+5TF+xp9NhcJc+
7QlKa3BPSmZQkD0jtdw9RQuqwJ9Z1oZbinC3doETikoBdZt3/j84eWzDttN3eIBf9IHfUh2iG9ZB
tihPUs8UV3xmEgYucJw13/jYyUR0UV4a4omBpjI/gXbqdN3aoMLPUu4sqdzgEI8c03aT1GWTeKO+
2WWi3Qabo2SF45GzBLFPmLAl2MpdrZkg7EJAOG3W9eSjNTk+X5g64W57nh8Er9dXQXg0/XvZopAF
MPuEQHNJWwm5UE6Vk8fGJ1GwFroaznIkCM4OlDgWBezQvn+ZM5ww9Pwe3t3bV+hSGjvhWKjyE9IA
AAAAAAA=


--=-LeZulbx1/ys24jCCiehr--
