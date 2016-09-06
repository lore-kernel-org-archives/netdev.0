From: Jeffrey Altman <jaltman@auristor.com>
Subject: Re: [PATCH net-next 4/9] rxrpc: Randomise epoch and starting client
 conn ID values
Date: Mon, 5 Sep 2016 22:12:49 -0400
Message-ID: <1f4c3840-d8a7-7d36-542f-7a24b840371e@auristor.com>
References: <063D6719AE5E284EB5DD2968C1650D6DB00F48DE@AcuExch.aculab.com>
 <147302294435.28597.15007422228950187972.stgit@warthog.procyon.org.uk>
 <147302297165.28597.8317497494192917329.stgit@warthog.procyon.org.uk>
 <3378.1473092663@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-256; boundary="------------ms020508090704050403090409"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-afs@lists.infradead.org" <linux-afs@lists.infradead.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Howells <dhowells@redhat.com>,
        David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sequoia-grove.ad.secure-endpoints.com ([208.125.0.235]:61129
        "EHLO smtp.secure-endpoints.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753294AbcIFCSK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2016 22:18:10 -0400
Received: from [IPv6:2001:470:1f07:f77:54cc:6135:d66f:2582] by secure-endpoints.com (Cipher TLSv1:AES-SHA:256) (MDaemon PRO v16.0.4)
        with ESMTPSA id md50001145331.msg for <netdev@vger.kernel.org>;
        Mon, 05 Sep 2016 22:12:54 -0400
In-Reply-To: <3378.1473092663@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms020508090704050403090409
Content-Type: multipart/mixed;
 boundary="------------7ABFF91C1D98FA8063FBEDD9"

This is a multi-part message in MIME format.
--------------7ABFF91C1D98FA8063FBEDD9
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Reply inline ....

On 9/5/2016 12:24 PM, David Howells wrote:
> [cc'ing Jeff Altman for comment]
>=20
> David Laight <David.Laight@ACULAB.COM> wrote:
>=20
>>> Create a random epoch value rather than a time-based one on startup a=
nd set
>>> the top bit to indicate that this is the case.
>>
>> Why set the top bit?
>> There is nothing to stop the time (in seconds) from having the top bit=
 set.
>> Nothing else can care - otherwise this wouldn't work.
>=20
> This is what I'm told I should do by purveyors of other RxRPC solutions=
=2E

The protocol specification requires that the top bit be 1 for a random
epoch and 0 for a time derived epoch.
>=20
>>> Also create a random starting client connection ID value.  This will =
be
>>> incremented from here as new client connections are created.
>>
>> I'm guessing this is to make duplicates less likely after a restart?

Its to reduce the possibility of duplicates on multiple machines that
might at some point exchange an endpoint address either due to mobility
or NAT/PAT.
>=20
> Again, it's been suggested that I do this, but I would guess so.
>=20
>> You may want to worry about duplicate allocations (after 2^32 connects=
).
>=20
> It's actually a quarter of that, but connection !=3D call, so a connect=
ion may
> be used for up to ~16 billion RPC operations before it *has* to be flus=
hed.
>=20
>> There are id allocation algorithms that guarantee not to generate dupl=
icates
>> and not to reuse values quickly while still being fixed cost.
>> Look at the code NetBSD uses to allocate process ids for an example.
>=20
> I'm using idr_alloc_cyclic()[*] with a fixed size "window" on the activ=
e conn
> ID values.  Client connections with IDs outside of that window are disc=
arded
> as soon as possible to keep the memory consumption of the tree down (an=
d to
> force security renegotiation occasionally).  However, given that there =
are a
> billion IDs to cycle through, it will take quite a while for reuse to b=
ecome
> an issue.
>=20
> I like the idea of incrementing the epoch every time we cycle through t=
he ID
> space, but I'm told that a change in the epoch value is an indication t=
hat the
> client rebooted - with what consequences I cannot say.

State information might be recorded about an rx peer with the assumption
that state will be reset when the epoch changes.  The most frequent use
of this technique is for rx rpc statistics monitoring.


>=20
> [*] which is what Linux uses to allocate process IDs.
>=20
> David
>=20


--------------7ABFF91C1D98FA8063FBEDD9
Content-Type: text/x-vcard; charset=utf-8;
 name="jaltman.vcf"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="jaltman.vcf"

begin:vcard
fn:Jeffrey Altman
n:Altman;Jeffrey
org:AuriStor, Inc.
adr:Suite 6B;;255 West 94Th Street;New York;New York;10025-6985;United St=
ates
email;internet:jaltman@auristor.com
title:Founder and CEO
tel;work:+1-212-769-9018
note;quoted-printable:LinkedIn: https://www.linkedin.com/in/jeffreyaltman=
=3D0D=3D0A=3D
	Skype: jeffrey.e.altman=3D0D=3D0A=3D
=09
url:https://www.auristor.com/
version:2.1
end:vcard


--------------7ABFF91C1D98FA8063FBEDD9--

--------------ms020508090704050403090409
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExDzANBglghkgBZQMEAgEFADCABgkqhkiG9w0BBwEAAKCC
DEkwggYFMIIE7aADAgECAhAxSdDYnMC0s7K+ddH7ywANMA0GCSqGSIb3DQEBCwUAMIGmMQsw
CQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xHzAdBgNVBAsTFlN5
bWFudGVjIFRydXN0IE5ldHdvcmsxHjAcBgNVBAsTFVBlcnNvbmEgTm90IFZhbGlkYXRlZDE3
MDUGA1UEAxMuU3ltYW50ZWMgQ2xhc3MgMSBJbmRpdmlkdWFsIFN1YnNjcmliZXIgQ0EgLSBH
NTAeFw0xNTExMDEwMDAwMDBaFw0xNjExMDEyMzU5NTlaMIGnMS4wLAYDVQQDDCVQZXJzb25h
IE5vdCBWYWxpZGF0ZWQgLSAxNDQ2NDA0MDI1NjI1MSMwIQYJKoZIhvcNAQkBFhRqYWx0bWFu
QGF1cmlzdG9yLmNvbTEPMA0GA1UECwwGUy9NSU1FMR4wHAYDVQQLDBVQZXJzb25hIE5vdCBW
YWxpZGF0ZWQxHzAdBgNVBAsMFlN5bWFudGVjIFRydXN0IE5ldHdvcmswggEiMA0GCSqGSIb3
DQEBAQUAA4IBDwAwggEKAoIBAQC2cv6bENZULsb1FNyEBI47G2kA7Rogocg5u0qnQuDMCCNH
DnXkI62H2z/464AS8AGp4FcZIdvCPYp0POFlOl2XEiyA59FEDi+s3b33nLrnVOa4esw2NFBi
ZvwHvniUjgwWSUcS5V5+VhXeIKBL1U1NtMtB2XEVnc72RiQZB3KqzlS9GUvtSTdmCc6ULD/t
P009yCsBqY6NR/nug5NtUja2N+xUC2l8coYU1ingj/M4+fT8KcSq5t8laj0E+3X9ZPYlN9in
L364hXB1b+EHfxp0F0wZdsCapkEKV2VN16S1Ee5rccJIMaAJxrybK7NdI36Es/XqWlQzSeVN
wUYdwejrAgMBAAGjggIqMIICJjAMBgNVHRMBAf8EAjAAMA4GA1UdDwEB/wQEAwIFoDAgBgNV
HSUBAf8EFjAUBggrBgEFBQcDBAYIKwYBBQUHAwIwHQYDVR0OBBYEFInhroYG7TrlBeOJmwRc
a0rfA3jtMB8GA1UdEQQYMBaBFGphbHRtYW5AYXVyaXN0b3IuY29tMGwGA1UdIARlMGMwYQYL
YIZIAYb4RQEHFwEwUjAmBggrBgEFBQcCARYaaHR0cDovL3d3dy5zeW1hdXRoLmNvbS9jcHMw
KAYIKwYBBQUHAgIwHBoaaHR0cDovL3d3dy5zeW1hdXRoLmNvbS9ycGEwXQYDVR0fBFYwVDBS
oFCgToZMaHR0cDovL3BraS1jcmwuc3ltYXV0aC5jb20vY2FfNTdkZTdhMjM4ZDQ1ZDhkNGZj
NzFmOGE1YzZiODFjOTMvTGF0ZXN0Q1JMLmNybDBOBggrBgEFBQcBAQRCMEAwPgYIKwYBBQUH
MAKGMmh0dHA6Ly9jYWNlci5zeW1hdXRoLmNvbS9tcGtpL3N5bWNjMWluZHN1YmNhZzUuY3J0
MB8GA1UdIwQYMBaAFGcZtj2lebszYNgtU9OMCT0HrBhwMCsGCmCGSAGG+EUBEAMEHTAbBhJg
hkgBhvhFARABAgIEAa3ukhMWBTEwOTIyMDkGCmCGSAGG+EUBEAUEKzApAgEAFiRhSFIwY0hN
Nkx5OXdhMmt0Y21FdWMzbHRZWFYwYUM1amIyMD0wDQYJKoZIhvcNAQELBQADggEBAHhpoe3z
j0uxbWFz4Q7F2KyRJTgREbQ+imVv3ibbd2uvnckJ+vTNJuFoaORXKTt3B8TUT8rBTwXm35D5
K4DOrKMVS0iyR9PDobLpjQM8FcIGUdbGWeZZq/1zoWhi3RtFNzZaSKXjwiQUUWYTZUE7rUmj
qu7fiACksPAAdyG12FJtk1pdVByqmaFC75/z2Qs/jVjyySpy2SRg8wlpqM2h8tl9SGska/BT
gXLHJMhKrHQvBi+9Xo3MrmJA5Z3f5vcheoOAoM5/ScHBUXWDG0+NnEIb340By0adU823pF9c
K4gxI0ZJNID+eaT0XCqg47QFOZYZUlm3s4rDi1l1iPIHekwwggY8MIIFJKADAgECAhAHAqIa
hbhLZZ4YCm7m9aNlMA0GCSqGSIb3DQEBCwUAMIHKMQswCQYDVQQGEwJVUzEXMBUGA1UEChMO
VmVyaVNpZ24sIEluYy4xHzAdBgNVBAsTFlZlcmlTaWduIFRydXN0IE5ldHdvcmsxOjA4BgNV
BAsTMShjKSAxOTk5IFZlcmlTaWduLCBJbmMuIC0gRm9yIGF1dGhvcml6ZWQgdXNlIG9ubHkx
RTBDBgNVBAMTPFZlcmlTaWduIENsYXNzIDEgUHVibGljIFByaW1hcnkgQ2VydGlmaWNhdGlv
biBBdXRob3JpdHkgLSBHMzAeFw0xNTEwMDEwMDAwMDBaFw0yNTA5MzAyMzU5NTlaMIGmMQsw
CQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xHzAdBgNVBAsTFlN5
bWFudGVjIFRydXN0IE5ldHdvcmsxHjAcBgNVBAsTFVBlcnNvbmEgTm90IFZhbGlkYXRlZDE3
MDUGA1UEAxMuU3ltYW50ZWMgQ2xhc3MgMSBJbmRpdmlkdWFsIFN1YnNjcmliZXIgQ0EgLSBH
NTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANb7DTFJIsAMuu9OLRe4tDDlNNKs
Ce7JiQBd9K4TEbMTjlXPIhioIAam/SXLaJS0oIKQDm6WkkTuFbm07PrPeT1p1Jwf3CCaDijV
DbXGnjrx1GUZwIQzTY7aivHWJ7kDoNH6KJyCk2z3DYV9W+lOmWL+k0LS7j6zcVeGl0bL3w3h
xoRasw2P9fQQigVdn2hG7AiwWEKC9r4tEEamJAsn/pgUU4OTgtvqwD9PolhhtUtyaRJfM1n2
+bNMAGTOhcWGkgxuHOsoz3GpkKl0mXQk60jhDl1oEqgBZujumrIv+D3Nt3gkzqVgfOgWPUnx
B7ozvjIrwmejFsdvwNJalATCa0UCAwEAAaOCAj4wggI6MDcGCCsGAQUFBwEBBCswKTAnBggr
BgEFBQcwAYYbaHR0cDovL3BraS1vY3NwLnN5bWF1dGguY29tMBIGA1UdEwEB/wQIMAYBAf8C
AQAwbAYDVR0gBGUwYzBhBgtghkgBhvhFAQcXATBSMCYGCCsGAQUFBwIBFhpodHRwOi8vd3d3
LnN5bWF1dGguY29tL2NwczAoBggrBgEFBQcCAjAcGhpodHRwOi8vd3d3LnN5bWF1dGguY29t
L3JwYTAvBgNVHR8EKDAmMCSgIqAghh5odHRwOi8vcy5zeW1jYi5jb20vcGNhMS1nMy5jcmww
DgYDVR0PAQH/BAQDAgEGMCkGA1UdEQQiMCCkHjAcMRowGAYDVQQDExFTeW1hbnRlY1BLSS0y
LTIxNzAdBgNVHQ4EFgQUZxm2PaV5uzNg2C1T04wJPQesGHAwgfEGA1UdIwSB6TCB5qGB0KSB
zTCByjELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDlZlcmlTaWduLCBJbmMuMR8wHQYDVQQLExZW
ZXJpU2lnbiBUcnVzdCBOZXR3b3JrMTowOAYDVQQLEzEoYykgMTk5OSBWZXJpU2lnbiwgSW5j
LiAtIEZvciBhdXRob3JpemVkIHVzZSBvbmx5MUUwQwYDVQQDEzxWZXJpU2lnbiBDbGFzcyAx
IFB1YmxpYyBQcmltYXJ5IENlcnRpZmljYXRpb24gQXV0aG9yaXR5IC0gRzOCEQCLW3VWhFSF
CwDPrzhIzrGkMA0GCSqGSIb3DQEBCwUAA4IBAQBGGeQndTu+r+LaohRgjx5EkIFpK2NJNY3p
drqfmI8TgdfL/GUb+A5j3pQodPvjb9jJKnoOVKaDrilK9itR/T04ErvdY0X7ZMw+VIZ/TkJt
I7cdC/36zA2OkzXK5UX5zy9/eT1jGMdHI0r2qRQArX5ZVRqJJ9uUoJE4xv5AlaNg9l24yMUW
7ZxmaRRGEErKcCpv0VDgJhrTUrRHcotF0r0DuaXc2QjzkKt0cKvKoE7wwE7k4L5PkBFgJwwr
HN/nbMp1tCXnkUiqkrRRdV8pm0cXHL3J6s91rXUjz/LF31qrt2vKu7heq9WjcNRo8xd6mwug
FDz76IFWaOjPXXxzuC68MYIEYjCCBF4CAQEwgbswgaYxCzAJBgNVBAYTAlVTMR0wGwYDVQQK
ExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0GA1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0d29y
azEeMBwGA1UECxMVUGVyc29uYSBOb3QgVmFsaWRhdGVkMTcwNQYDVQQDEy5TeW1hbnRlYyBD
bGFzcyAxIEluZGl2aWR1YWwgU3Vic2NyaWJlciBDQSAtIEc1AhAxSdDYnMC0s7K+ddH7ywAN
MA0GCWCGSAFlAwQCAQUAoIICdzAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3
DQEJBTEPFw0xNjA5MDYwMjEyNDlaMC8GCSqGSIb3DQEJBDEiBCD15I8PZBjcrvb8uXTWfsVr
6l77yDE41G7Sb8sqFOH70jBsBgkqhkiG9w0BCQ8xXzBdMAsGCWCGSAFlAwQBKjALBglghkgB
ZQMEAQIwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFAMAcGBSsO
AwIHMA0GCCqGSIb3DQMCAgEoMIHMBgkrBgEEAYI3EAQxgb4wgbswgaYxCzAJBgNVBAYTAlVT
MR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0GA1UECxMWU3ltYW50ZWMgVHJ1
c3QgTmV0d29yazEeMBwGA1UECxMVUGVyc29uYSBOb3QgVmFsaWRhdGVkMTcwNQYDVQQDEy5T
eW1hbnRlYyBDbGFzcyAxIEluZGl2aWR1YWwgU3Vic2NyaWJlciBDQSAtIEc1AhAxSdDYnMC0
s7K+ddH7ywANMIHOBgsqhkiG9w0BCRACCzGBvqCBuzCBpjELMAkGA1UEBhMCVVMxHTAbBgNV
BAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMR8wHQYDVQQLExZTeW1hbnRlYyBUcnVzdCBOZXR3
b3JrMR4wHAYDVQQLExVQZXJzb25hIE5vdCBWYWxpZGF0ZWQxNzA1BgNVBAMTLlN5bWFudGVj
IENsYXNzIDEgSW5kaXZpZHVhbCBTdWJzY3JpYmVyIENBIC0gRzUCEDFJ0NicwLSzsr510fvL
AA0wDQYJKoZIhvcNAQEBBQAEggEAhChyjZME9S8MSks8YrVV4tJkvRFMvSTsw6bQtuQT3wuT
S78wqX98g9hwS183OY6dOWlG3AKDZq5H6AdxZ6HFA5dup7WvuV/vhFQAOvucpNZ2ANCv/5vY
tbT6v08yAtsHW9BVNpZ5OQh+ukubNWOY3EHhjPzqrjMxuRaLpxA68aHSaL3o16H5J6n2jaae
+EXr7HMWclCiI5GpT16hqx6kUaQUJImxqI3nlXEnUhFF/t5zv3l+oq5ArmBJPeQdgGa1mvj1
MpK8eJ4bAs5AKhDYFOCa+zhYM2WjqdKvWEMjfOLGH3JpoxzWEiu8e+cY6eIrAL2RRc9nL0nv
yhgqFvAvXgAAAAAAAA==
--------------ms020508090704050403090409--
