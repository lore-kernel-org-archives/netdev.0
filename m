From: "Ward, David - 0663 - MITLL" <david.ward@ll.mit.edu>
Subject: Re: [PATCH] net/vlan: withdraw VLAN ID attribute from GVRP on VLAN
 device stop
Date: Mon, 26 Mar 2012 21:35:20 -0400
Message-ID: <4F711958.5060904@ll.mit.edu>
References: <4F707163.2000209@ll.mit.edu>	<4F7087CA.5010804@dti2.net>
 <4F709038.20107@ll.mit.edu>
 <20120326.174216.151181141269420661.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature";
	micalg=sha1; boundary="------------ms080900000108090503090005"
Cc: "jorge@dti2.net" <jorge@dti2.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:43358 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755465Ab2C0CGF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Mar 2012 22:06:05 -0400
In-Reply-To: <20120326.174216.151181141269420661.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------ms080900000108090503090005
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

On 03/26/2012 05:42 PM, David Miller wrote:
> From: "Ward, David - 0663 - MITLL"<david.ward@ll.mit.edu>
> Date: Mon, 26 Mar 2012 11:50:16 -0400
>
>> If I create an interface that is initially down, then bring it up, and=

>> finally bring it back down, I think it should return to the state it
>> was in initially.  So in my opinion, either the GVRP attribute should
>> exist while the interface is down, or it shouldn't.
> You're whole argument breaks down because we definitely don't do this
> for IPv4 addresses, we'll keep receiving traffic for IPv4 addresses
> configured on that interface when received on other interfaces which
> are still up, even when you bring that interface down.

=2E.. but that also seems to work if you never bring the interface up.  I=
=20
can create a dummy interface, set an IP address on it, and immediately=20
receive traffic on that IP address from another interface, without ever=20
having brought the dummy interface up.  (The behavior after setting the=20
interface down is the same as before the interface was ever brought up.)

Instead with GVRP, I create an interface and set the GVRP flag on it,=20
but GVRP does not declare the attribute for that VLAN until you bring=20
the VLAN interface up the first time.  However it doesn't withdraw the=20
attribute when you bring the VLAN interface down, only when you delete it=
=2E

So to approach this differently -- would there be anything wrong with=20
GVRP declaring the attribute as soon as the GVRP flag is set, even if=20
the VLAN interface has not come up yet?  The user might do this to=20
deliberately give the switching infrastructure a head start, so that=20
(for example) the IPv6 DAD packets that are sent as soon as the VLAN=20
interface comes up make it to all participants on the LAN...right now=20
you can't do that.  You could still choose not to set the GVRP flag on=20
the interface until you bring it up, similar to what you were saying.

Then each attribute declaration event would have an opposite attribute=20
withdrawal event.  This means if we tried to create an attribute that=20
already existed and wasn't in the "leaving" state, it would alert us to=20
a bug.

Thoughts?

David


--------------ms080900000108090503090005
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIOZjCC
BLcwggOfoAMCAQICARQwDQYJKoZIhvcNAQELBQAwVDELMAkGA1UEBhMCVVMxHzAdBgNVBAoT
Fk1JVCBMaW5jb2xuIExhYm9yYXRvcnkxDDAKBgNVBAsTA1BLSTEWMBQGA1UEAxMNTUlUTEwg
Um9vdCBDQTAeFw0wOTEyMTQxMjAwMDBaFw0xNTEyMzEyMzU5NTlaMFExCzAJBgNVBAYTAlVT
MR8wHQYDVQQKExZNSVQgTGluY29sbiBMYWJvcmF0b3J5MQwwCgYDVQQLEwNQS0kxEzARBgNV
BAMTCk1JVExMIENBLTIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCnBMsjYUiH
7DegMwcFYWZM6OknYzRgEO5gNgPE9JJnQgfDB+o1o1VTMBWcJYPXII4CyhLhDvSjfCvTPI4H
mRDKIp5UX5N2BCzwu7BJJMwUJHFaS4RMAC7nvYh6MIEixpl2aWCpkYX74b2CeDDQriGlqXCv
xmg2QhPlNmk4ONpL/80Kx9wKKhV/NThe54sFzZ2pz9YUEX5DE0a52hFvA19EzGhv7fUcucUj
Ky0zXPQ70LYwOWXLlpxAolKcgwRVsS6/cse8YH9fy8IAsXKAXikgQaFs5EJigLIDKPTKtRaf
55yKsORSpoDrO1cvuntA5PnIH/qAFfACvGRTEK1RNLh9AgMBAAGjggGVMIIBkTASBgNVHRMB
Af8ECDAGAQH/AgEAMB0GA1UdDgQWBBSOSn2JoWMXHIGINFc3JkVeGYp+JDAfBgNVHSMEGDAW
gBRnqnrP9AqmuXK1iqDSnfIQw0PtKTAOBgNVHQ8BAf8EBAMCAYYwYQYIKwYBBQUHAQEEVTBT
MC0GCCsGAQUFBzAChiFodHRwOi8vY3JsLmxsLm1pdC5lZHUvZ2V0dG8/TExSQ0EwIgYIKwYB
BQUHMAGGFmh0dHA6Ly9vY3NwLmxsLm1pdC5lZHUwMwYDVR0fBCwwKjAooCagJIYiaHR0cDov
L2NybC5sbC5taXQuZWR1L2dldGNybD9MTFJDQTCBkgYDVR0gBIGKMIGHMA0GCyqGSIb3EgIB
AwEGMA0GCyqGSIb3EgIBAwEIMA0GCyqGSIb3EgIBAwEHMA0GCyqGSIb3EgIBAwEJMA0GCyqG
SIb3EgIBAwEKMA0GCyqGSIb3EgIBAwELMA0GCyqGSIb3EgIBAwEOMA0GCyqGSIb3EgIBAwEP
MA0GCyqGSIb3EgIBAwEQMA0GCSqGSIb3DQEBCwUAA4IBAQCIdwah0P1x/Augwi/nhBq6Ds8Q
XAqkzSLZrL+DADWjk6HYFNo64x3Bo15c6oaW/GcTpZACt3StPa3OvsgAnKCtk81bQ0WV2MaL
/0qmUYyN3bn1NiWrQD8aLAssv9aLY5dUylGOO1r37d9b3X+YtFytg0FRCfl5arYAYhU1SDCH
wScD2o67Is/qYBRGMIYcCcb7PH5UotBSwhO+1WCxIqD+YcRusyD3kEcc4dW6IG36YVhx7aIk
w5AUmeFH7xl0E1X+0I4Q+cmMNdMiArYx5rYG34AZB+f770fdjWPUUpTT82aphiiImutWyQpm
oEWBsnsX3nVTRdHCVi+Cf3Cx4YDWMIIE0DCCA7igAwIBAgIKHZq/iQAAAAAmizANBgkqhkiG
9w0BAQsFADBRMQswCQYDVQQGEwJVUzEfMB0GA1UEChMWTUlUIExpbmNvbG4gTGFib3JhdG9y
eTEMMAoGA1UECxMDUEtJMRMwEQYDVQQDEwpNSVRMTCBDQS0yMB4XDTExMDkwMjEzMjMyN1oX
DTEyMDkwMTEzMjMyN1owXzELMAkGA1UEBhMCVVMxHzAdBgNVBAoTFk1JVCBMaW5jb2xuIExh
Ym9yYXRvcnkxDzANBgNVBAsTBlBlb3BsZTEeMBwGA1UEAxMVV2FyZC5EYXZpZC5QLjUwMDEx
NDU5MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAs/kc4nm0iXua+QkuOu84IL7W
wUO0SE5E9kNN1jkGyUHFAlGZM6MCrX+WCjriUhZ81kvHdDrwc1T4dM2uVomh9PtllfVTtDCl
me0gyl8MytZFyGY3T9lvvXGo10spznb2NfW0mwz3o6KgcB1r+CAZg+i3eImv+KYcDPRRs1HX
h9A0wpEZnTRFK9IbL0bOQRimfYCtmiT0cU+lkKDNxdtFOvDeqBvItnlAlSqRc+dgU8wO3so1
KGAIPTH6DyNOA6c6zGy0W7DA4enSXjRv1zj4WqziFaaonbqB6bot9BL6iNkxRQNw46Ggz7Av
C3YUq97bcEtIo6/yK+h2lvvfdOeIzQIDAQABo4IBmjCCAZYwHQYDVR0OBBYEFM45m7umEDp1
0q5/GycF/INvcYO6MA4GA1UdDwEB/wQEAwIGwDAfBgNVHSMEGDAWgBSOSn2JoWMXHIGINFc3
JkVeGYp+JDAzBgNVHR8ELDAqMCigJqAkhiJodHRwOi8vY3JsLmxsLm1pdC5lZHUvZ2V0Y3Js
L0xMQ0EyMGIGCCsGAQUFBwEBBFYwVDAtBggrBgEFBQcwAoYhaHR0cDovL2NybC5sbC5taXQu
ZWR1L2dldHRvL0xMQ0EyMCMGCCsGAQUFBzABhhdodHRwOi8vb2NzcC5sbC5taXQuZWR1LzAM
BgNVHRMBAf8EAjAAMD0GCSsGAQQBgjcVBwQwMC4GJisGAQQBgjcVCIOD5R2H7Kdmhq2HFYPq
8EWFtqEfHYXL3jKH/4pzAgFkAgEFMCIGA1UdJQEB/wQYMBYGCCsGAQUFBwMEBgorBgEEAYI3
CgMMMBgGA1UdIAQRMA8wDQYLKoZIhvcSAgEDAQgwIAYDVR0RBBkwF4EVZGF2aWQud2FyZEBs
bC5taXQuZWR1MA0GCSqGSIb3DQEBCwUAA4IBAQBJFv9wS0zxBhRjFpjIlz2d6SYQnnjrWSAT
fBQ4kgBh4eU12s/fWXx6Do//TkxYy11vWxFH8J+388F1i016ttcDTmCTJJTaEyregC4sok83
5zd0B2MsQ1T78jfwwDyY1YdGfRfeAjFaTZiXoz9x2dFR8EdCoxs922/2hph9a4LnN+OiMa2A
PHEuJFQpz5MPgnKCo4VkzADK5+xwl0kpyf3XaitHbyEyiFwNOuJLmjXwPSr6cXArpdaI3qPq
x4vHta3nny5vZft8gnVg/zyRsKgJR/ELxjmrN+lmvdJnmLS0rfFFcZ2injNeP5r9oFYC99p9
co1Z9PTfKSqs2+Jb+369MIIE0zCCA7ugAwIBAgIKHZoVFwAAAAAmijANBgkqhkiG9w0BAQsF
ADBRMQswCQYDVQQGEwJVUzEfMB0GA1UEChMWTUlUIExpbmNvbG4gTGFib3JhdG9yeTEMMAoG
A1UECxMDUEtJMRMwEQYDVQQDEwpNSVRMTCBDQS0yMB4XDTExMDkwMjEzMjI0M1oXDTEyMDkw
MTEzMjI0M1owXzELMAkGA1UEBhMCVVMxHzAdBgNVBAoTFk1JVCBMaW5jb2xuIExhYm9yYXRv
cnkxDzANBgNVBAsTBlBlb3BsZTEeMBwGA1UEAxMVV2FyZC5EYXZpZC5QLjUwMDExNDU5MIIB
IjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsuroCmsIXD3x6D20VEA7j995rdTiXDpz
crJOm23Y91lHvgR1slI2kcwcKe5ERFn17G9wN/rQn6ASYcKL1+LjjcnYGtHBIOkKcIJSVMOb
DG+Fblg2osuJf6iRd3nvIUHqezt4mrH9VWpRZTCYzJcl/S8VBMqgsY7oNo9IfEL3c7IKqER4
yAvjD/iPg81VaWR2QOcubms42J5O48qWt0p9sr0/Z2CYC2iGy+QfAkeqOXSGvhcDckiYEOpE
segN0S6y4mvY+KpvTR6QUh2YfRf69r6/v/xp/KxmsgtbZzf4KWnUsBYq2h9d1gIxtRkxiNSU
1qCKLhrHB4sTYMEaxzI75QIDAQABo4IBnTCCAZkwHQYDVR0OBBYEFA8tOvez46Vf83C/sZVn
vVWVzGSMMA4GA1UdDwEB/wQEAwIFIDAfBgNVHSMEGDAWgBSOSn2JoWMXHIGINFc3JkVeGYp+
JDAzBgNVHR8ELDAqMCigJqAkhiJodHRwOi8vY3JsLmxsLm1pdC5lZHUvZ2V0Y3JsL0xMQ0Ey
MGIGCCsGAQUFBwEBBFYwVDAtBggrBgEFBQcwAoYhaHR0cDovL2NybC5sbC5taXQuZWR1L2dl
dHRvL0xMQ0EyMCMGCCsGAQUFBzABhhdodHRwOi8vb2NzcC5sbC5taXQuZWR1LzAMBgNVHRMB
Af8EAjAAMD0GCSsGAQQBgjcVBwQwMC4GJisGAQQBgjcVCIOD5R2H7Kdmhq2HFYPq8EWFtqEf
HYXr0HCD6+0gAgFkAgEEMCUGA1UdJQQeMBwGBFUdJQAGCCsGAQUFBwMEBgorBgEEAYI3CgME
MBgGA1UdIAQRMA8wDQYLKoZIhvcSAgEDAQgwIAYDVR0RBBkwF4EVZGF2aWQud2FyZEBsbC5t
aXQuZWR1MA0GCSqGSIb3DQEBCwUAA4IBAQAzAVu7kVRNe2jceIj9uOxvgvJuvrK0dZ0BM/PQ
pB0VJq5QDpe00fQSJmVurv4+/QZOC6Pbe81Rsott3eXgHdpTBnghWaYQKqMhNEAH0QQ2nvcY
vMn46DRU29u+v7F1XkhYG9GTR9F88EeAO3r/Fio6M+0NNPxSab6p/pkecWI0GQbBEHVtTSNf
bymwljp15nbE8/jThG1MES/mbLq+jue7BCDUw6jLp10fg2uXDd+DmZOI2K2G4kpZ0s2T1dtX
h4HfOoHsBGFUMYQGMnL48b9p9mXwrJXo/WKFGe8l9+dLoOWMdZ+dvKQva9kEAAOnbIZ2xXSi
7EAz0AD/QPSwUnf8MYIDKjCCAyYCAQEwXzBRMQswCQYDVQQGEwJVUzEfMB0GA1UEChMWTUlU
IExpbmNvbG4gTGFib3JhdG9yeTEMMAoGA1UECxMDUEtJMRMwEQYDVQQDEwpNSVRMTCBDQS0y
Agodmr+JAAAAACaLMAkGBSsOAwIaBQCgggGgMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEw
HAYJKoZIhvcNAQkFMQ8XDTEyMDMyNzAxMzUyMFowIwYJKoZIhvcNAQkEMRYEFGhZhm6lmaFK
FFfcrs4mww8URKW+MF8GCSqGSIb3DQEJDzFSMFAwCwYJYIZIAWUDBAECMAoGCCqGSIb3DQMH
MA4GCCqGSIb3DQMCAgIAgDANBggqhkiG9w0DAgIBQDAHBgUrDgMCBzANBggqhkiG9w0DAgIB
KDBuBgkrBgEEAYI3EAQxYTBfMFExCzAJBgNVBAYTAlVTMR8wHQYDVQQKExZNSVQgTGluY29s
biBMYWJvcmF0b3J5MQwwCgYDVQQLEwNQS0kxEzARBgNVBAMTCk1JVExMIENBLTICCh2aFRcA
AAAAJoowcAYLKoZIhvcNAQkQAgsxYaBfMFExCzAJBgNVBAYTAlVTMR8wHQYDVQQKExZNSVQg
TGluY29sbiBMYWJvcmF0b3J5MQwwCgYDVQQLEwNQS0kxEzARBgNVBAMTCk1JVExMIENBLTIC
Ch2aFRcAAAAAJoowDQYJKoZIhvcNAQEBBQAEggEAHGiuiMFE/lRs+jvZdODBS1mq7WHVPkGZ
zB2bS62wMi9U7Vhc8KRH2jKjIfpF9y7bbMMHBufNLUcXzXMuQO4BmkAuf2dfm3i7sJXTcUcp
DV6O0tcHq4ZQ/Y74EI1vWuOU9cK4ruC+LKJ9WtKvTbEkJmmjPIqAt9N6XO4qwjH75b7DT3Og
7xkvOgQ+5FSzJfZNxyi+8DXfWb1t2qnvBtcKEqfrHgaV+hbdBfWnjAIDGTPcXW/9TQZnD+DL
hJRQlDDVunGx5BtuG1IKqnyeSDUrkG4iAJK21iCEr3Hj1j6wR8FsAH/WPNFRnqQXzppDR89K
DxjqKKKZc/3y9zeE9xVB1gAAAAAAAA==
--------------ms080900000108090503090005--
