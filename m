From: Shanker Wang <miao.wang@tuna.tsinghua.edu.cn>
Subject: Re: Bonding MAC address
Date: Sat, 29 Oct 2016 00:39:46 +0800
Message-ID: <C66AAC71-8864-4449-9D4D-1B79E0BEA2A9@tuna.tsinghua.edu.cn>
References: <64717203-D02C-41D0-9D2B-EFEB4CF78146@nfware.com>
Mime-Version: 1.0 (Mac OS X Mail 10.1 \(3251\))
Content-Type: multipart/signed;
 boundary="Apple-Mail=_9BAFA470-6A1E-49D3-A6AF-74A2F376A425";
 protocol="application/pkcs7-signature"; micalg=sha1
Cc: netdev@vger.kernel.org
To: Igor Ryzhov <iryzhov@nfware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36033 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965925AbcJ1Qju (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 12:39:50 -0400
Received: by mail-pf0-f171.google.com with SMTP id e6so39817616pfk.3
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 09:39:50 -0700 (PDT)
In-Reply-To: <64717203-D02C-41D0-9D2B-EFEB4CF78146@nfware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail=_9BAFA470-6A1E-49D3-A6AF-74A2F376A425
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=gb2312

I think it is intentional. Because changing mac address of an=20
interface would cause problems. As a result, if you find it=20
necessary to change the mac address, it should be done manually.

Consider these two example:

* A host is connecting the internet through a bond interface,=20
and obtain ip address from a dhcp server. Changing the mac=20
address automatically would possibly lead to re-assigning a=20
new IP address, which could not be expected.

* A linux-box is acting as a gateway, providing service to=20
hosts in the local lan. Changing mac address and not changing
IP address of an interface would cause other hosts to fail
to communicate with the gateway, since the old mac address is
still in theirs arp cache table. The communication will recover
after arp cache expires, which can be a short or long time.

* The scene is the same to the second one. And consider if =20
arp snooping or other mechanisms to protect hosts from being=20
spoofed by a fake gateway are enabled in the local lan. After=20
changing the mac address, the linux-box itself will be a=20
=A1=B0spoofer=A1=B1 and may get blocked.=20

So changing mac address of an interface could be dangerous and
lead to network malfunction and cannot be done automatically.=20

> =D4=DA 2016=C4=EA10=D4=C228=C8=D5=A3=AC19:09=A3=ACIgor Ryzhov =
<iryzhov@nfware.com> =D0=B4=B5=C0=A3=BA
>=20
> Hello everyone,
>=20
> Studying the bonding driver I found that bonding device doesn't choose =
a new MAC address when the slave which MAC is in use is released.
> This is a warning about that - "the permanent HWaddr of slave is still =
in use by bond - set the HWaddr of slave to a different address to avoid =
conflicts".
> Why not to choose a new MAC for bonding device? Is it intentional or =
just not implemented?
>=20
> Best regards,
> Igor


--Apple-Mail=_9BAFA470-6A1E-49D3-A6AF-74A2F376A425
Content-Disposition: attachment;
	filename=smime.p7s
Content-Type: application/pkcs7-signature;
	name=smime.p7s
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIKCzCCBK8w
ggOXoAMCAQICEQDgI8sVEoNTia1hbnpUZ2shMA0GCSqGSIb3DQEBCwUAMG8xCzAJBgNVBAYTAlNF
MRQwEgYDVQQKEwtBZGRUcnVzdCBBQjEmMCQGA1UECxMdQWRkVHJ1c3QgRXh0ZXJuYWwgVFRQIE5l
dHdvcmsxIjAgBgNVBAMTGUFkZFRydXN0IEV4dGVybmFsIENBIFJvb3QwHhcNMTQxMjIyMDAwMDAw
WhcNMjAwNTMwMTA0ODM4WjCBmzELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hl
c3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEaMBgGA1UEChMRQ09NT0RPIENBIExpbWl0ZWQxQTA/BgNV
BAMTOENPTU9ETyBTSEEtMjU2IENsaWVudCBBdXRoZW50aWNhdGlvbiBhbmQgU2VjdXJlIEVtYWls
IENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAibEN2npTGU5wUh28VqYGJre4SeCW
51Gr8fBaE0kVo7SMG2C8elFCp3mMpCLfF2FOkdV2IwoU00oCf7YdCYBupQQ92bq7Fv6hh6kuQ1JD
FnyvMlDIpk9a6QjYz5MlnHuI6DBk5qT4VoD9KiQUMxeZrETlaYujRgZLwjPU6UCfBrCxrJNAubUI
kzqcKlOjENs9IGE8VQOO2U52JQIhKfqjfHF2T+7hX4Hp+1SA28N7NVK3hN4iPSwwLTF/Wb1SN7Az
aS1D6/rWpfGXd2dRjNnuJ+u8pQc4doykqTj/34z1A6xJvsr3c5k6DzKrnJU6Ez0ORjpXdGFQvsZA
P8vk4p+iIQIDAQABo4IBFzCCARMwHwYDVR0jBBgwFoAUrb2YejS0Jvf6xCZU7wO94CTLVBowHQYD
VR0OBBYEFJJha4LhoqCqT+xn8cKj97SAAMHsMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8ECDAG
AQH/AgEAMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcDBDARBgNVHSAECjAIMAYGBFUdIAAw
RAYDVR0fBD0wOzA5oDegNYYzaHR0cDovL2NybC51c2VydHJ1c3QuY29tL0FkZFRydXN0RXh0ZXJu
YWxDQVJvb3QuY3JsMDUGCCsGAQUFBwEBBCkwJzAlBggrBgEFBQcwAYYZaHR0cDovL29jc3AudXNl
cnRydXN0LmNvbTANBgkqhkiG9w0BAQsFAAOCAQEAGypurFXBOquIxdjtzVXzqmthK8AJECOZD8Vm
am+x9bS1d14PAmEA330F/hKzpICAAPz7HVtqcgIKQbwFusFY1SbC6tVNhPv+gpjPWBvjImOcUvi7
BTarfVil3qs7Y+Xa1XPv7OD7e+Kj//BCI5zKto1NPuRLGAOyqC3U2LtCS5BphRDbpjc06HvgARCl
nMo6x59PiDRuimXQGoq7qdzKyjbR9PzCZCk1r9axp3ER0gNDsY8+muyeMlP0dpLKhjQHuSzK5hxK
2JkNwYbikJL7WkJqIyEQ6WXH9dW7fuqMhSACYurROgcsWcWZM/I4ieW26RZ6H3kU9koQGib6fIr7
mzCCBVQwggQ8oAMCAQICEQCz7bOWGt837yf+2EEgYX7zMA0GCSqGSIb3DQEBCwUAMIGbMQswCQYD
VQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRow
GAYDVQQKExFDT01PRE8gQ0EgTGltaXRlZDFBMD8GA1UEAxM4Q09NT0RPIFNIQS0yNTYgQ2xpZW50
IEF1dGhlbnRpY2F0aW9uIGFuZCBTZWN1cmUgRW1haWwgQ0EwHhcNMTYwOTA3MDAwMDAwWhcNMTcw
OTA3MjM1OTU5WjAvMS0wKwYJKoZIhvcNAQkBFh5taWFvLndhbmdAdHVuYS50c2luZ2h1YS5lZHUu
Y24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDF4JDX+lppNfAKjABahacSSWED1YTS
IR/bmDzwV08VxvbfiQpqHMmsDbaNYHgoAS25JSAU9mN5dRPlfRfKnfLa67pO05FkrYoN2IHbXhqH
lF+0M6MVcTkulUDzCDEviZLRmqZFw4oIlOzEjmZJ0GkhOOnzvuD0B8nfgp0ij4EPkRcNjWjrGDu4
op8kxE3ceN9nF/jDYL1hISJQOuJx3afLt/ISzA7ynaD2MiiiIQviI4Rr1IxfF53smu2tXAwYXtrp
zVlnf0QK5pZy/gxwgp3Mien0YgeeRJpSQ4mAI3L9ftEXXqpGz60R3/XZoRLX+m7TzjTIwZxE6sGP
GxzkIS6zAgMBAAGjggH8MIIB+DAfBgNVHSMEGDAWgBSSYWuC4aKgqk/sZ/HCo/e0gADB7DAdBgNV
HQ4EFgQU1T4lGv6gY6SWm/lc0xv+YsJJDMYwDgYDVR0PAQH/BAQDAgWgMAwGA1UdEwEB/wQCMAAw
IAYDVR0lBBkwFwYIKwYBBQUHAwQGCysGAQQBsjEBAwUCMBEGCWCGSAGG+EIBAQQEAwIFIDBGBgNV
HSAEPzA9MDsGDCsGAQQBsjEBAgEBATArMCkGCCsGAQUFBwIBFh1odHRwczovL3NlY3VyZS5jb21v
ZG8ubmV0L0NQUzBdBgNVHR8EVjBUMFKgUKBOhkxodHRwOi8vY3JsLmNvbW9kb2NhLmNvbS9DT01P
RE9TSEEyNTZDbGllbnRBdXRoZW50aWNhdGlvbmFuZFNlY3VyZUVtYWlsQ0EuY3JsMIGQBggrBgEF
BQcBAQSBgzCBgDBYBggrBgEFBQcwAoZMaHR0cDovL2NydC5jb21vZG9jYS5jb20vQ09NT0RPU0hB
MjU2Q2xpZW50QXV0aGVudGljYXRpb25hbmRTZWN1cmVFbWFpbENBLmNydDAkBggrBgEFBQcwAYYY
aHR0cDovL29jc3AuY29tb2RvY2EuY29tMCkGA1UdEQQiMCCBHm1pYW8ud2FuZ0B0dW5hLnRzaW5n
aHVhLmVkdS5jbjANBgkqhkiG9w0BAQsFAAOCAQEAWaTmII5zqDcKRwWt8TLDuXFiBP1EqE8obR3B
YtWoJ60uQZQbVLH2R9dp1sh2DlHzxMYYOOt8vyMIJUw7gTuQ1KfeRgeGGLyXqIfa/TegUtCQPPQE
fd4kVFBqp4v9wDCt1a1Tg5mphAyJTrppo76Pc6qefn5KvCyKhgoAK2UYeY7uxehe3QF+/tX+MJsa
El1rDLg6mmSnvcTS6r7xets48FmfRkWHK2SrA+/4EBxeg+2TWL7h8+ztxWj/o5Di2V+0KsLqiwu/
JIF3+IPU7AMNE/TqdqiE6nJDYZbe6RyG4c333N+f9ipkPq4jSupvpLGgEl+66dYyu/4fBVA31rlD
WjGCA8YwggPCAgEBMIGxMIGbMQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVz
dGVyMRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQKExFDT01PRE8gQ0EgTGltaXRlZDFBMD8GA1UE
AxM4Q09NT0RPIFNIQS0yNTYgQ2xpZW50IEF1dGhlbnRpY2F0aW9uIGFuZCBTZWN1cmUgRW1haWwg
Q0ECEQCz7bOWGt837yf+2EEgYX7zMAkGBSsOAwIaBQCgggHpMBgGCSqGSIb3DQEJAzELBgkqhkiG
9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2MTAyODE2Mzk0NlowIwYJKoZIhvcNAQkEMRYEFMk31tlt
4BqfM6kTXgiVNiODy0bmMIHCBgkrBgEEAYI3EAQxgbQwgbEwgZsxCzAJBgNVBAYTAkdCMRswGQYD
VQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGjAYBgNVBAoTEUNPTU9E
TyBDQSBMaW1pdGVkMUEwPwYDVQQDEzhDT01PRE8gU0hBLTI1NiBDbGllbnQgQXV0aGVudGljYXRp
b24gYW5kIFNlY3VyZSBFbWFpbCBDQQIRALPts5Ya3zfvJ/7YQSBhfvMwgcQGCyqGSIb3DQEJEAIL
MYG0oIGxMIGbMQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYD
VQQHEwdTYWxmb3JkMRowGAYDVQQKExFDT01PRE8gQ0EgTGltaXRlZDFBMD8GA1UEAxM4Q09NT0RP
IFNIQS0yNTYgQ2xpZW50IEF1dGhlbnRpY2F0aW9uIGFuZCBTZWN1cmUgRW1haWwgQ0ECEQCz7bOW
Gt837yf+2EEgYX7zMA0GCSqGSIb3DQEBAQUABIIBAJqzA/J81jrI3TWT95eVy7k8F76+VIPDGVm1
E/dEBLYoBhsG7EQ6eEl5Qy8462JH+IKkkgjGQ5/5iJvLPJcT2J/AP5wsmOAviNEGQ9//qUSW5+OQ
6DEQfJGuZ0gFo8p3GHn5/55pCKeFzrF2nfzkf7vV+z+hwEFma14G1Qkm+gzi8/tZrXizhGU8uGlx
b4ZErktlXR/rZGMBjbDYD7HIbAXe6rjpkZL7bm8Zs1oH4c31FvYsyLzMY5BOYO0ONzR+BoAYdCs+
6IEVXsYM3zwqpzxF8PBY9wNlaXc/U41iWgKvv/ZaTGkit39v4qXW5cbInppf+K1f0TbFne0tpmzP
tNcAAAAAAAA=
--Apple-Mail=_9BAFA470-6A1E-49D3-A6AF-74A2F376A425--
