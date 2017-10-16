From: Humberto Alves <hjalves@live.com>
Subject: Re: [iproute2] regression in ss output
Date: Mon, 16 Oct 2017 20:44:07 +0000
Message-ID: <AM4PR0901MB12527C55F04814777A0E6849CC4F0@AM4PR0901MB1252.eurprd09.prod.outlook.com>
References: <AM4PR0901MB125261BF480B49D2BA2DF46BCC480@AM4PR0901MB1252.eurprd09.prod.outlook.com>
 <20171016103320.GP11332@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature";
        micalg=sha-256; boundary="------------ms070206060004010509080702"
To: Phil Sutter <phil@nwl.cc>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oln040092066022.outbound.protection.outlook.com ([40.92.66.22]:53509
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753136AbdJPUoK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 16:44:10 -0400
In-Reply-To: <20171016103320.GP11332@orbyte.nwl.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------ms070206060004010509080702
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

Yes, just get rid of this 'if statement'.
in6addr_any should be represented as '::', not '*'. Otherwise it's=20
impossible to distinguish IPv4 listening addresses from IPv6. Thank you :=
)

On 10/16/2017 11:33 AM, Phil Sutter wrote:
> Hi,
>=20
> On Fri, Oct 13, 2017 at 09:57:37AM +0000, Humberto Alves wrote:
>> Hi! With the last iproute2 release, ss command output does not
>> differentiate between any-address IPv4 sockets from the IPv6 ones.
>> I don't know if this is an expected behaviour, but the old output look=
s
>> more useful. Below I pasted the difference between the old behaviour a=
nd
>> the new one.
>=20
> Although the change is certainly intentional (it was introduced by
> Stephen Hemminger as a side effect of aba9c23a6e1cb ("ss: enclose IPv6
> address in brackets"), I second reverting to the old display of
> in6addr_any as '::'.
>=20
>> I am happy to send a patch if you want. Thanks
>=20
> It should be enough to just getting rid of the
>=20
> | if (!memcmp(a->data, &in6addr_any, sizeof(in6addr_any))) {
>=20
> case in inet_addr_print(). The else-case which calls format_host()
> should deal with in6addr_any just fine. This way the address also gets
> enclosed in brackets which helps separating it from the ':port' part.
>=20
> Cheers, Phil
>=20


--------------ms070206060004010509080702
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExDzANBglghkgBZQMEAgEFADCABgkqhkiG9w0BBwEAAKCC
CxkwggUrMIIEE6ADAgECAhAieTCr/hihj2HgS0mCvAKIMA0GCSqGSIb3DQEBCwUAMIGXMQsw
CQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxm
b3JkMRowGAYDVQQKExFDT01PRE8gQ0EgTGltaXRlZDE9MDsGA1UEAxM0Q09NT0RPIFJTQSBD
bGllbnQgQXV0aGVudGljYXRpb24gYW5kIFNlY3VyZSBFbWFpbCBDQTAeFw0xNzEwMTIwMDAw
MDBaFw0xODEwMTIyMzU5NTlaMCExHzAdBgkqhkiG9w0BCQEWEGhqYWx2ZXNAbGl2ZS5jb20w
ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC47BWTYxsQTz6rcr+3gx9YyXyBg4/K
/bNyEM0H7idMRlUUpXMa0dSj7UEvZoSeQjHBjujDSDK1+HS/x+9TpvnZUUz5Y4ixordZALH5
WCJ2hxYlFpuo6SVryj/nw57ABMsk7pRrVWAjcDyK6e9EztuKCQKB6qXM8Ew0Ftbotm8xsW8Q
Er6PlUeK/M99v8fsD1y9HFl0TugAY7PtcYL0dVoon/E3xfq4W65ILFHxpBxCnd/XRzRd0aBS
eusMDLx1Hrsl7bLhsSJ7yhpXyiotjf2dYqZXTeavs5ZeCF7Zahv81wd5P9bX5AgTU6jtQdtE
kmCgLx1Ixwx+QRdA57CUpxlhAgMBAAGjggHmMIIB4jAfBgNVHSMEGDAWgBSCr2yM+MX+lmF8
6B89K3FIXsSLwDAdBgNVHQ4EFgQUlJKtuPmHGZC7hs9Dx0qHHfwvuGIwDgYDVR0PAQH/BAQD
AgWgMAwGA1UdEwEB/wQCMAAwIAYDVR0lBBkwFwYIKwYBBQUHAwQGCysGAQQBsjEBAwUCMBEG
CWCGSAGG+EIBAQQEAwIFIDBGBgNVHSAEPzA9MDsGDCsGAQQBsjEBAgEBATArMCkGCCsGAQUF
BwIBFh1odHRwczovL3NlY3VyZS5jb21vZG8ubmV0L0NQUzBaBgNVHR8EUzBRME+gTaBLhklo
dHRwOi8vY3JsLmNvbW9kb2NhLmNvbS9DT01PRE9SU0FDbGllbnRBdXRoZW50aWNhdGlvbmFu
ZFNlY3VyZUVtYWlsQ0EuY3JsMIGLBggrBgEFBQcBAQR/MH0wVQYIKwYBBQUHMAKGSWh0dHA6
Ly9jcnQuY29tb2RvY2EuY29tL0NPTU9ET1JTQUNsaWVudEF1dGhlbnRpY2F0aW9uYW5kU2Vj
dXJlRW1haWxDQS5jcnQwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTAb
BgNVHREEFDASgRBoamFsdmVzQGxpdmUuY29tMA0GCSqGSIb3DQEBCwUAA4IBAQCKA78qsNtR
YOtq5rVoixJObIDvlzwM+mYhC58hCkHxAwGzL79Guhj40/yEbieO+24SAdb+jBr+wmo1cJ8c
Piaigr3lyBW7rwDs6qRSG/3JejzuOkx7xEEGxrkerFJUGE7nbE7g6mlh1MxrylOtNZC7wrur
KqGPakZzkuIy8GobcpVIDTfmbm7bG5H4smnor0RDeCYvSLmMn+GO7KKjXK66bzMx2XTEebIj
SO8b0JILx214tnkcWSE3lzMTUJNxc+60HvgLvNX/2vxtosI5GLhwCtD+0CEAek2VBMqjUjcH
aw6t+wPu54DANatFRq/LeRnQSwkvUwL66exMuSmovls4MIIF5jCCA86gAwIBAgIQapvhODv/
K2ufAdXZuKdSVjANBgkqhkiG9w0BAQwFADCBhTELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdy
ZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEaMBgGA1UEChMRQ09NT0RPIENB
IExpbWl0ZWQxKzApBgNVBAMTIkNPTU9ETyBSU0EgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkw
HhcNMTMwMTEwMDAwMDAwWhcNMjgwMTA5MjM1OTU5WjCBlzELMAkGA1UEBhMCR0IxGzAZBgNV
BAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEaMBgGA1UEChMRQ09N
T0RPIENBIExpbWl0ZWQxPTA7BgNVBAMTNENPTU9ETyBSU0EgQ2xpZW50IEF1dGhlbnRpY2F0
aW9uIGFuZCBTZWN1cmUgRW1haWwgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
AQC+s55XrCh2dUAWxzgDmNPGGHYhUPMleQtMtaDRfTpYPpynMS6n9jR22YRq2tA9NEjk6vW7
rN/5sYFLIP1of3l0NKZ6fLWfF2VgJ5cijKYy/qlAckY1wgOkUMgzKlWlVJGyK+UlNEQ1/5Er
CsHq9x9aU/x1KwTdF/LCrT03Rl/FwFrf1XTCwa2QZYL55AqLPikFlgqOtzk06kb2qvGlnHJv
ijjI03BOrNpo+kZGpcHsgyO1/u1OZTaOo8wvEU17VVeP1cHWse9tGKTDyUGg2hJZjrqck39U
Im/nKbpDSZ0JsMoIw/JtOOg0JC56VzQgBo7ictReTQE5LFLG3yQK+xS1AgMBAAGjggE8MIIB
ODAfBgNVHSMEGDAWgBS7r34CPfqm8TyEjq3uOJjs2TIy1DAdBgNVHQ4EFgQUgq9sjPjF/pZh
fOgfPStxSF7Ei8AwDgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYBAf8CAQAwEQYDVR0g
BAowCDAGBgRVHSAAMEwGA1UdHwRFMEMwQaA/oD2GO2h0dHA6Ly9jcmwuY29tb2RvY2EuY29t
L0NPTU9ET1JTQUNlcnRpZmljYXRpb25BdXRob3JpdHkuY3JsMHEGCCsGAQUFBwEBBGUwYzA7
BggrBgEFBQcwAoYvaHR0cDovL2NydC5jb21vZG9jYS5jb20vQ09NT0RPUlNBQWRkVHJ1c3RD
QS5jcnQwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTANBgkqhkiG9w0B
AQwFAAOCAgEAeFyygSg0TzzuX1bOn5dW7I+iaxf28/ZJCAbU2C81zd9A/tNx4+jsQgwRGiHj
ZrAYayZrrm78hOx7aEpkfNPQIHGG6Fvq3EzWf/Lvx7/hk6zSPwIal9v5IkDcZoFD7f3iT7Pd
kHJY9B51csvU50rxpEg1OyOT8fk2zvvPBuM4qQNqbGWlnhMpIMwpWZT89RY0wpJO+2V6eXEG
GHsROs3njeP9DqqqAJaBa4wBeKOdGCWn1/Jp2oY6dyNmNppI4ZNMUH4Tam85S1j6E95u4+1N
uru84OrMIzqvISE2HN/56ebTOWlcrurffade2022O/tUU1gb4jfWCcyvB8czm12FgX/y/lRj
mDbEA08QJNB2729Y+io1IYO3ztveBdvUCIYZojTq/OCR6MvnzS6X72HP0PRLRTiOSEmIDsS5
N5w/8IW1Hva5hEFy6fDAfd9yI+O+IMMAj1KcL/Zo9jzJ16HO5m60ttl1Enk8MQkz/W3JlHae
I5iKFn4UJu1/cP2YHXYPiWf2JyBzsLBrGk1II+3yL8aorYew6CQvdVifC3HtwlSam9V1niiC
fOBe2C12TdKGu05LWIA3ZkFcWJGaNXOZ6Ggyh/TqvXG5v7zmEVDNXFnHn9tFpMpOUvxhcsjy
cBtH0dZ0WrNw6gH+HF8TIhCnH3+zzWuDN0Rk6h9KVkfKehIxggQ1MIIEMQIBATCBrDCBlzEL
MAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2Fs
Zm9yZDEaMBgGA1UEChMRQ09NT0RPIENBIExpbWl0ZWQxPTA7BgNVBAMTNENPTU9ETyBSU0Eg
Q2xpZW50IEF1dGhlbnRpY2F0aW9uIGFuZCBTZWN1cmUgRW1haWwgQ0ECECJ5MKv+GKGPYeBL
SYK8AogwDQYJYIZIAWUDBAIBBQCgggJZMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJ
KoZIhvcNAQkFMQ8XDTE3MTAxNjIwNDQwNVowLwYJKoZIhvcNAQkEMSIEIKXsHjpIvs/cxKHt
HDFLCdJVarf+5SI4VAngi/QBltzQMGwGCSqGSIb3DQEJDzFfMF0wCwYJYIZIAWUDBAEqMAsG
CWCGSAFlAwQBAjAKBggqhkiG9w0DBzAOBggqhkiG9w0DAgICAIAwDQYIKoZIhvcNAwICAUAw
BwYFKw4DAgcwDQYIKoZIhvcNAwICASgwgb0GCSsGAQQBgjcQBDGBrzCBrDCBlzELMAkGA1UE
BhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEa
MBgGA1UEChMRQ09NT0RPIENBIExpbWl0ZWQxPTA7BgNVBAMTNENPTU9ETyBSU0EgQ2xpZW50
IEF1dGhlbnRpY2F0aW9uIGFuZCBTZWN1cmUgRW1haWwgQ0ECECJ5MKv+GKGPYeBLSYK8Aogw
gb8GCyqGSIb3DQEJEAILMYGvoIGsMIGXMQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRl
ciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQKExFDT01PRE8gQ0EgTGlt
aXRlZDE9MDsGA1UEAxM0Q09NT0RPIFJTQSBDbGllbnQgQXV0aGVudGljYXRpb24gYW5kIFNl
Y3VyZSBFbWFpbCBDQQIQInkwq/4YoY9h4EtJgrwCiDANBgkqhkiG9w0BAQEFAASCAQCtHVJr
ZSe4T/oDr4WoWrFL50USQIvDSvsBRhtTHEvx3Q/VJbZgQlKNjArSy12B9RhxK7RR/mx1RkaP
0agK7rkwzJeuv6RSNFvM2oWKngsPfqfZgx+2I545TJmMjTBpWn0+8DTVvle5td3bpokMx/Ib
csgb2CsxsXlMoOGM7HilM+QxPqxQ2zpxgwepwVI++w6zYoySXPUs0ALShqz44baTx5FiWNos
CVu+SBv4mTPe+mGWk8+Rj/oUEHEwgEzcw+UZS9665Q9Dtz9q44vsHpEw71e5OIT/xAr0kCKA
tVULs1ssFmjFj5VaV+YNVqCG3UeYNlLfrps7cet4p1wbhAoVAAAAAAAA

--------------ms070206060004010509080702--
