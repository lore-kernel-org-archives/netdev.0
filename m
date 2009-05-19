From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [net-next PATCH 1/1] e1000e: Expose MDI-X state via sysfs
Date: Tue, 19 May 2009 16:45:28 -0700
Message-ID: <F169D4F5E1F1974DBFAFABF47F60C10A335276C4@orsmsx507.amr.corp.intel.com>
References: <20090519210553.GA2491@clala-laptop>
 <9929d2390905191455i3103ead3p13c0b4c51be29b5@mail.gmail.com>
 <4A133126.10608@riverbed.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/x-pkcs7-signature";
	micalg=SHA1; boundary="----=_NextPart_000_0016_01C9D8A1.377DDEE0"
Cc: "jgarzik@redhat.com" <jgarzik@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Chaitanya Lala <clala@riverbed.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:30871 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754026AbZESXp3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2009 19:45:29 -0400
In-Reply-To: <4A133126.10608@riverbed.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_NextPart_000_0016_01C9D8A1.377DDEE0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 7bit

Chaitanya Lala wrote:
> Jeff Kirsher wrote:
>> On Tue, May 19, 2009 at 2:05 PM, Chaitanya Lala <clala@riverbed.com>
>> wrote:
>>
>>> While debugging network connectivity problems, it is often helpful
>>> to report the MDI-X state. The is_mdix variable holds the current
>>> state which we expose on a per-interface basis as a sysfs attribute.
>>> We use sysfs over methods such as netlink due to the convenience of
>>> reading a file (using the cat command) as opposed to connecting to a
>>> netlink socket. If we use a fiber PHY then is_mdix will always be
>>> zero
>>> as the mdi-x feature only applies to copper PHYs.
>>>
>>> Signed-off-by: Chaitanya Lala <clala@riverbed.com>
>>> Signed-off-by: Arthur Jones <ajones@riverbed.com>
>>> ---
>>>
>>
>> NAK.  We do not want to be adding sysfs entries for every little
>> piece
>> of information in the driver.  Instead, I would suggest looking at
>> enhancing existing tools like ethtool to get that sort of information
>> in a more generic way which is not driver specific.
>>
>>
> The MDI-X setting is a non-standard piece of information & every
> driver may or may-not have it. But still this is an important
> de-bugging tool & we would want to use this information from the
> drivers that do provide this facility.  So what would be a standard
> way to do this via something like ethtool ? Any pointers would be
> helpful.

how about (psuedo diff)

        Supported ports: [ TP ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
        Advertised auto-negotiation: Yes
        Speed: 1000Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 1
        Transceiver: internal
        Auto-negotiation: on
+       MDI-X: on
        Supports Wake-on: umbg
        Wake-on: g
        Current message level: 0x00000003 (3)
        Link detected: yes

where possible MDI-X values are (on|off)

This way drivers can optionally implement the feature in their 
get_settings and set_settings handlers.

------=_NextPart_000_0016_01C9D8A1.377DDEE0
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIXMTCCAyAw
ggKJoAMCAQICBDXe9M8wDQYJKoZIhvcNAQEFBQAwTjELMAkGA1UEBhMCVVMxEDAOBgNVBAoTB0Vx
dWlmYXgxLTArBgNVBAsTJEVxdWlmYXggU2VjdXJlIENlcnRpZmljYXRlIEF1dGhvcml0eTAeFw05
ODA4MjIxNjQxNTFaFw0xODA4MjIxNjQxNTFaME4xCzAJBgNVBAYTAlVTMRAwDgYDVQQKEwdFcXVp
ZmF4MS0wKwYDVQQLEyRFcXVpZmF4IFNlY3VyZSBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkwgZ8wDQYJ
KoZIhvcNAQEBBQADgY0AMIGJAoGBAMFdsVhnCGLuoJotHwhtkRRomAoe/toEbxOEYiHD0XzOnwXg
uAHwTjTs4oqVBGSs8WtTXwWzy2eAv0ICjv7dAQns4QAUT/z78AzdQ7pbK+EfgHCZFVeTFvEPl2q3
wmgjHMxNWTCsUR47ryvW7mNFe8XZX1DS41APOojnvxT94Me5AgMBAAGjggEJMIIBBTBwBgNVHR8E
aTBnMGWgY6BhpF8wXTELMAkGA1UEBhMCVVMxEDAOBgNVBAoTB0VxdWlmYXgxLTArBgNVBAsTJEVx
dWlmYXggU2VjdXJlIENlcnRpZmljYXRlIEF1dGhvcml0eTENMAsGA1UEAxMEQ1JMMTAaBgNVHRAE
EzARgQ8yMDE4MDgyMjE2NDE1MVowCwYDVR0PBAQDAgEGMB8GA1UdIwQYMBaAFEjmaPkr0rKV10fY
IyAQTzOYkJ/UMB0GA1UdDgQWBBRI5mj5K9KylddH2CMgEE8zmJCf1DAMBgNVHRMEBTADAQH/MBoG
CSqGSIb2fQdBAAQNMAsbBVYzLjBjAwIGwDANBgkqhkiG9w0BAQUFAAOBgQBYzinq/Pfetc4CuRe1
hdG54+CVzCUxDQCmkm5/tpJjnlCV0Zpv5BHeY4VumO6o/1rI01WyZnFX3sAh6z0qpyNJAQSGQnv8
7n+iFlK1Z2fTQNs7JliyKHc9rhR3Ydb6KmYnoA36p3Nc6nDxlCFlRF/6/O8paKmih3nvee9PrAd3
ODCCAz0wggKmoAMCAQICAwWw/zANBgkqhkiG9w0BAQUFADBOMQswCQYDVQQGEwJVUzEQMA4GA1UE
ChMHRXF1aWZheDEtMCsGA1UECxMkRXF1aWZheCBTZWN1cmUgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
MB4XDTA2MDIxNjE4MDEzMFoXDTE2MDIxOTE4MDEzMFowUjELMAkGA1UEBhMCVVMxGjAYBgNVBAoT
EUludGVsIENvcnBvcmF0aW9uMScwJQYDVQQDEx5JbnRlbCBFeHRlcm5hbCBCYXNpYyBQb2xpY3kg
Q0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDBpd/XOb9QVqEZ8mQ1042TdOIq3ATD
IsV2xDyt30yLyMR5Wjtus0bn3B+he89BiNO/LP6+rFzEwlD55PlX+HLGIKeNNG97dqyc30FElEUj
ZzTZFq2N4e3kVJ/XAEEgANzV8v9qp7qWwxugPgfc3z9BkYot+CifozexHLb/hEZj+yISCU61kRZv
uSQ0E11yYL4dRgcglJeaHo3oX57rvIckaLsYV5/1Aj+R8DM1Ppk965XQAKsHfnyT7C4S50T4lVn4
lz36wOdNZn/zegG1zp41lnoTFfT4KuKVJH5x7YD1p6KbgJCKLovnujGuohquBNfdXKpZkvz6pGv+
iC1HawJdAgMBAAGjgaAwgZ0wDgYDVR0PAQH/BAQDAgEGMB0GA1UdDgQWBBQaxgxKxEdvqNutK/D0
Vgaj7TdUDDA6BgNVHR8EMzAxMC+gLaArhilodHRwOi8vY3JsLmdlb3RydXN0LmNvbS9jcmxzL3Nl
Y3VyZWNhLmNybDAfBgNVHSMEGDAWgBRI5mj5K9KylddH2CMgEE8zmJCf1DAPBgNVHRMBAf8EBTAD
AQH/MA0GCSqGSIb3DQEBBQUAA4GBABMQOK2kVKVIlUWwLTdywJ+e2O+PC/uQltK2F3lRyrPfBn69
tOkIP4SgDJOfsxyobIrPLe75kBLw+Dom13OBDp/EMZJZ1CglQfVV8co9mT3aZMjSGGQiMgkJLR3j
Mfr900fXZKj5XeqCJ+JP0mEhJGEdVCY+FFlksJjV86fDrq1QMIIFYzCCBEugAwIBAgIKYSyUiQAA
AAAABTANBgkqhkiG9w0BAQUFADBSMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9y
YXRpb24xJzAlBgNVBAMTHkludGVsIEV4dGVybmFsIEJhc2ljIFBvbGljeSBDQTAeFw0wNjAzMjIy
MjIyNDJaFw0xMjAzMjIyMjMyNDJaMFYxCzAJBgNVBAYTAlVTMRowGAYDVQQKExFJbnRlbCBDb3Jw
b3JhdGlvbjErMCkGA1UEAxMiSW50ZWwgRXh0ZXJuYWwgQmFzaWMgSXNzdWluZyBDQSAzQTCCASIw
DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKvXqH/ah10uJc7YzQUh+XEDNqS6IsXOyqCtizr9
x6F+v6iRAbvddRRJRWixfV78qarSN9WMymJ90M8c9/Dfr1yzFuq95RgCAF3vdve3wKi7kJv6lkMJ
wyyB+uIYcWtljYx2LDqbb9S6Z6He3q8W/aGKvu23I9ksNx+cmZcDNZwGdXVIEHpEMyA4bp0RvYtf
p8BsGAyn6YuK63HugeyYdeFL+4+Wz2tGUqw9OWhob6oV1oDH3zboLhHJiQ2oIj3jAJ3/LrIkzcWP
2R20UIliDAPAAl6MNWJPdsNK5EEeuxEuUSpdFsMj5rBmPHH4U8i8rUmi6GEOcX5rwAw64AzS3gEC
AwEAAaOCAjUwggIxMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFAlpgTN7BnOPI0wKA9/3FoER
ghMFMAsGA1UdDwQEAwIBhjAQBgkrBgEEAYI3FQEEAwIBADAZBgkrBgEEAYI3FAIEDB4KAFMAdQBi
AEMAQTAfBgNVHSMEGDAWgBQaxgxKxEdvqNutK/D0Vgaj7TdUDDCBvQYDVR0fBIG1MIGyMIGvoIGs
oIGphk5odHRwOi8vd3d3LmludGVsLmNvbS9yZXBvc2l0b3J5L0NSTC9JbnRlbCUyMEV4dGVybmFs
JTIwQmFzaWMlMjBQb2xpY3klMjBDQS5jcmyGV2h0dHA6Ly9jZXJ0aWZpY2F0ZXMuaW50ZWwuY29t
L3JlcG9zaXRvcnkvQ1JML0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMFBvbGljeSUyMENBLmNy
bDCB4wYIKwYBBQUHAQEEgdYwgdMwYwYIKwYBBQUHMAKGV2h0dHA6Ly93d3cuaW50ZWwuY29tL3Jl
cG9zaXRvcnkvY2VydGlmaWNhdGVzL0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMFBvbGljeSUy
MENBLmNydDBsBggrBgEFBQcwAoZgaHR0cDovL2NlcnRpZmljYXRlcy5pbnRlbC5jb20vcmVwb3Np
dG9yeS9jZXJ0aWZpY2F0ZXMvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIwUG9saWN5JTIwQ0Eu
Y3J0MA0GCSqGSIb3DQEBBQUAA4IBAQCuNCnecJ+vDpXzsHOzMEyz4KgTNDbJROHag8H/ZVga7soc
oJyC+HKqDfQgxifVorbTbSajCBEAxqg6bbNWBJ6qKOFHneBrXkENf5WdD50eCTCFWRV3EIsHEOQ1
kP0eNYV5Ed4hp9y6wASV6z2z86O4+qouLJiow4AIhoCKD8rEyD7ODgTvjvLCKpsVyPlG1jOVSsOS
IF2VUmueAmK3RFU4np83zerK/j0G37owhniEDT6ZhwkUd0XL45nt1m7yApMEbnXUTHNaXnE+P98k
k3nDXdW25sB+5xWcYR3GpgMdQiZgP/f0KZ+yZKNE7gcp3I/O4pXqUNWIsLSYTi3soAR2MIIFizCC
BHOgAwIBAgIKTys7CwAAAAAWqTANBgkqhkiG9w0BAQUFADBWMQswCQYDVQQGEwJVUzEaMBgGA1UE
ChMRSW50ZWwgQ29ycG9yYXRpb24xKzApBgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3Vp
bmcgQ0EgM0EwHhcNMDcwODA3MDAyMzE2WhcNMTAwODA2MDAyMzE2WjBHMRowGAYDVQQDExFCcmFu
ZGVidXJnLCBKZXNzZTEpMCcGCSqGSIb3DQEJARYaamVzc2UuYnJhbmRlYnVyZ0BpbnRlbC5jb20w
gZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBALVYgP1o+Y7nwm5Lr6GerkzP9QweQWF7Ban1beaZ
Etba5ALpVHObkA/1pXF8sE/iJnu4CxUAxAmVArSVNHWFJDdS/rR43JOvekwVIKEo4a9JABCXF+rt
K/1ImEN+RDLfl/0Wd73CRfOvRtTSlg+pUqVyCtL9B3X1bzY+OPxicYahAgMBAAGjggLsMIIC6DAL
BgNVHQ8EBAMCB4AwHQYDVR0OBBYEFKqZruraVjeOWvjg3XEwVS5Kkvn0MDwGCSsGAQQBgjcVBwQv
MC0GJSsGAQQBgjcVCIbDjHWEmeVRg/2BKIWOn1OCkcAJZ4HevTmV8EMCAWQCAQMwHwYDVR0jBBgw
FoAUCWmBM3sGc48jTAoD3/cWgRGCEwUwgckGA1UdHwSBwTCBvjCBu6CBuKCBtYZUaHR0cDovL3d3
dy5pbnRlbC5jb20vcmVwb3NpdG9yeS9DUkwvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIwSXNz
dWluZyUyMENBJTIwM0EuY3Jshl1odHRwOi8vY2VydGlmaWNhdGVzLmludGVsLmNvbS9yZXBvc2l0
b3J5L0NSTC9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBJc3N1aW5nJTIwQ0ElMjAzQS5jcmww
ge8GCCsGAQUFBwEBBIHiMIHfMGkGCCsGAQUFBzAChl1odHRwOi8vd3d3LmludGVsLmNvbS9yZXBv
c2l0b3J5L2NlcnRpZmljYXRlcy9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBJc3N1aW5nJTIw
Q0ElMjAzQS5jcnQwcgYIKwYBBQUHMAKGZmh0dHA6Ly9jZXJ0aWZpY2F0ZXMuaW50ZWwuY29tL3Jl
cG9zaXRvcnkvY2VydGlmaWNhdGVzL0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMElzc3Vpbmcl
MjBDQSUyMDNBLmNydDAfBgNVHSUEGDAWBggrBgEFBQcDBAYKKwYBBAGCNwoDDDApBgkrBgEEAYI3
FQoEHDAaMAoGCCsGAQUFBwMEMAwGCisGAQQBgjcKAwwwUQYDVR0RBEowSKAqBgorBgEEAYI3FAID
oBwMGmplc3NlLmJyYW5kZWJ1cmdAaW50ZWwuY29tgRpqZXNzZS5icmFuZGVidXJnQGludGVsLmNv
bTANBgkqhkiG9w0BAQUFAAOCAQEAJL8raLZYyz2imhvIrmSaQNhCOEzTwIXqxhlMbnPpeZUKlUym
6Tg7VaGXsqSyNQRe2eOK3gv2Et1O1ZsJwRGLC9mzKug8xeE5doO7HbbO04C8bR4B7jID2xByDJsT
f99mrprSwng4brFaW9JiSbCQyxmmApPoVXEff3lUqphiotdebDeV8y8a+s/yJCviLUinLbs4Uowf
/SXu6k+b27ue/I/QmWq01CF9wT/QMPyyAkIR+62XCGjGAZJIfsoZzCtab9/ujU7B0d7wV1Tq/koX
L21E3rOyAZ6I+7jpV0HDqY9KjPdLQu2tQ7I1u6iPORDH29STos5g/xv48jMK+RemBTCCBdIwggS6
oAMCAQICCk82OTAAAAAAFqowDQYJKoZIhvcNAQEFBQAwVjELMAkGA1UEBhMCVVMxGjAYBgNVBAoT
EUludGVsIENvcnBvcmF0aW9uMSswKQYDVQQDEyJJbnRlbCBFeHRlcm5hbCBCYXNpYyBJc3N1aW5n
IENBIDNBMB4XDTA3MDgwNzAwMzUxM1oXDTEwMDgwNjAwMzUxM1owRzEaMBgGA1UEAxMRQnJhbmRl
YnVyZywgSmVzc2UxKTAnBgkqhkiG9w0BCQEWGmplc3NlLmJyYW5kZWJ1cmdAaW50ZWwuY29tMIGf
MA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDi2zY1Qs4T/t3n7P8HqwPt42qNN+oSkatx6IEcMpQ3
F0gPolrDmw2NqF4cC77He10MCA5vCd4dyL0wPDKguH0wcntGCaYVf4EitdnTl+TGPkuAoRaUZAhc
NjmPrL2pH8HtJf/ANHQPtVuCUnPbUl12c9HPOqvVWSdXniNBUVCM9QIDAQABo4IDMzCCAy8wCwYD
VR0PBAQDAgQwMEQGCSqGSIb3DQEJDwQ3MDUwDgYIKoZIhvcNAwICAgCAMA4GCCqGSIb3DQMEAgIA
gDAHBgUrDgMCBzAKBggqhkiG9w0DBzAdBgNVHQ4EFgQUvdfuEHaw1+wbTNraFaClPaDVErUwPQYJ
KwYBBAGCNxUHBDAwLgYmKwYBBAGCNxUIhsOMdYSZ5VGD/YEohY6fU4KRwAlnhLnZQYeE/04CAWQC
AQcwHwYDVR0jBBgwFoAUCWmBM3sGc48jTAoD3/cWgRGCEwUwgckGA1UdHwSBwTCBvjCBu6CBuKCB
tYZUaHR0cDovL3d3dy5pbnRlbC5jb20vcmVwb3NpdG9yeS9DUkwvSW50ZWwlMjBFeHRlcm5hbCUy
MEJhc2ljJTIwSXNzdWluZyUyMENBJTIwM0EuY3Jshl1odHRwOi8vY2VydGlmaWNhdGVzLmludGVs
LmNvbS9yZXBvc2l0b3J5L0NSTC9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBJc3N1aW5nJTIw
Q0ElMjAzQS5jcmwwge8GCCsGAQUFBwEBBIHiMIHfMGkGCCsGAQUFBzAChl1odHRwOi8vd3d3Lmlu
dGVsLmNvbS9yZXBvc2l0b3J5L2NlcnRpZmljYXRlcy9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMl
MjBJc3N1aW5nJTIwQ0ElMjAzQS5jcnQwcgYIKwYBBQUHMAKGZmh0dHA6Ly9jZXJ0aWZpY2F0ZXMu
aW50ZWwuY29tL3JlcG9zaXRvcnkvY2VydGlmaWNhdGVzL0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNp
YyUyMElzc3VpbmclMjBDQSUyMDNBLmNydDAfBgNVHSUEGDAWBggrBgEFBQcDBAYKKwYBBAGCNwoD
BDApBgkrBgEEAYI3FQoEHDAaMAoGCCsGAQUFBwMEMAwGCisGAQQBgjcKAwQwUQYDVR0RBEowSKAq
BgorBgEEAYI3FAIDoBwMGmplc3NlLmJyYW5kZWJ1cmdAaW50ZWwuY29tgRpqZXNzZS5icmFuZGVi
dXJnQGludGVsLmNvbTANBgkqhkiG9w0BAQUFAAOCAQEAWZ7lU8JqwDbBes8ezVkGWmY91zVg87Bi
0Qxh0u9J5fIF+8KZ6tt7GX3Q8GRj0bZnX4hzFk6+wxT+25hXUb7c0ZmEIMbr8LYvOWXHghvjQja1
mkIC2eArcr42E8Bwy3BcwF+0K38UsqAkmlBzDOEf/lleIjgEamarv94UvjwFNsK6/sRCVSgOIU1T
8QeeCx0Y7Roaqjwt+66CwpIT6upnfJdSfplPXeYqatHfvAb+6evOB2EG37ejQmWEN5co8dfXD+1L
kkqlNn2YZfj4SGJeYHq0s/EmDPHzyrZohSoPgZJape03LRR7JUUtesB9nNtBuCnzMfWQw/tfL3of
ae/0MDGCAsAwggK8AgEBMGQwVjELMAkGA1UEBhMCVVMxGjAYBgNVBAoTEUludGVsIENvcnBvcmF0
aW9uMSswKQYDVQQDEyJJbnRlbCBFeHRlcm5hbCBCYXNpYyBJc3N1aW5nIENBIDNBAgpPKzsLAAAA
ABapMAkGBSsOAwIaBQCgggGyMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkF
MQ8XDTA5MDUxOTIzNDUyOFowIwYJKoZIhvcNAQkEMRYEFCKnWi+nIuWHSV3KxQ/W4N/KbHDCMGcG
CSqGSIb3DQEJDzFaMFgwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFA
MAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMAcGBSsOAwIaMAoGCCqGSIb3DQIFMHMGCSsGAQQBgjcQ
BDFmMGQwVjELMAkGA1UEBhMCVVMxGjAYBgNVBAoTEUludGVsIENvcnBvcmF0aW9uMSswKQYDVQQD
EyJJbnRlbCBFeHRlcm5hbCBCYXNpYyBJc3N1aW5nIENBIDNBAgpPNjkwAAAAABaqMHUGCyqGSIb3
DQEJEAILMWagZDBWMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9yYXRpb24xKzAp
BgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3VpbmcgQ0EgM0ECCk82OTAAAAAAFqowDQYJ
KoZIhvcNAQEBBQAEgYByi5w/mFE01XxRAPkxPuRqVaq97zGQE6jLec/h5peYYPrJxIsslWY8m9tP
5W76HZwkIKSeRRCI9iBu7Gc4nh2JxzWUxdJj2MJr/I3er8maA/j7BJ3B+69MLXstX6AGf5XTt/3W
PjxWx5deFFVY+2JBtdbnzV2YzKC3L9WiQj1JPgAAAAAAAA==

------=_NextPart_000_0016_01C9D8A1.377DDEE0--
