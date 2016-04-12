From: Daniele Orlandi <daniele@orlandi.com>
Subject: Issue with ping source address display
Date: Tue, 12 Apr 2016 19:52:15 +0200
Message-ID: <570D35CF.9070006@orlandi.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-256; boundary="------------ms090001050702020307090303"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from submission.geniusware.it ([62.212.12.144]:45606 "EHLO
	submission.geniusware.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757242AbcDLSBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 14:01:02 -0400
Received: from localhost (localhost [127.0.0.1])
	by submission.orlandi.com (Postfix) with ESMTP id 9E0F04C0483
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 19:52:16 +0200 (CEST)
Received: from submission.orlandi.com ([127.0.0.1])
	by localhost (submission.orlandi.com [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id 14g120UwesbI for <netdev@vger.kernel.org>;
	Tue, 12 Apr 2016 19:52:15 +0200 (CEST)
Received: from [IPv6:2a02:20:20::20] (unknown [IPv6:2a02:20:20::20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: daniele@orlandi.com)
	by submission.orlandi.com (Postfix) with ESMTPSA id D257B4C002E
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 19:52:15 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms090001050702020307090303
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


Hello,

More than one year ago I posted the following message but it hasn't
received a reply, now I've been stung by a similar issue, you may want
to investigate:


I noticed that when ping receives ICMP messages from different sources
the first IP address is always used and displayed:


vihai@seviolab:~$ ping -V
ping utility, iputils-s20121221

This is a (simulated) flapping route:

vihai@seviolab:~$ ping 10.254.10.140
PING 10.254.10.140 (10.254.10.140) 56(84) bytes of data.
=46rom 192.168.1.1 icmp_seq=3D1 Destination Host Unreachable
=46rom 192.168.1.1 icmp_seq=3D2 Destination Host Unreachable
=46rom 192.168.1.1 icmp_seq=3D3 Destination Host Unreachable
64 bytes from 192.168.1.1: icmp_seq=3D4 ttl=3D61 time=3D24.7 ms
64 bytes from 192.168.1.1: icmp_seq=3D5 ttl=3D61 time=3D25.6 ms
64 bytes from 192.168.1.1: icmp_seq=3D6 ttl=3D61 time=3D69.6 ms
=46rom 192.168.1.1 icmp_seq=3D7 Destination Host Unreachable
=46rom 192.168.1.1 icmp_seq=3D8 Destination Host Unreachable
=46rom 192.168.1.1 icmp_seq=3D9 Destination Host Unreachable
^C
--- 10.254.10.140 ping statistics ---
9 packets transmitted, 3 received, +6 errors, 66% packet loss, time 8001m=
s
rtt min/avg/max/mdev =3D 24.797/40.061/69.692/20.955 ms


The sources, however are different:

vihai@seviolab:~$ sudo tcpdump -n icmp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decod=
e
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
^[OA^[OA^[OA17:09:55.932981 IP 192.168.1.21 > 10.254.10.140: ICMP echo
request, id 9278, seq 1, length 64
17:09:55.933234 IP 192.168.1.1 > 192.168.1.21: ICMP host 10.254.10.140
unreachable, length 92
17:09:56.933169 IP 192.168.1.21 > 10.254.10.140: ICMP echo request, id
9278, seq 2, length 64
17:09:56.933416 IP 192.168.1.1 > 192.168.1.21: ICMP host 10.254.10.140
unreachable, length 92
17:09:57.933160 IP 192.168.1.21 > 10.254.10.140: ICMP echo request, id
9278, seq 3, length 64
17:09:57.933404 IP 192.168.1.1 > 192.168.1.21: ICMP host 10.254.10.140
unreachable, length 92
17:09:58.933163 IP 192.168.1.21 > 10.254.10.140: ICMP echo request, id
9278, seq 4, length 64
17:09:58.957939 IP 10.254.10.140 > 192.168.1.21: ICMP echo reply, id
9278, seq 4, length 64
17:09:59.935050 IP 192.168.1.21 > 10.254.10.140: ICMP echo request, id
9278, seq 5, length 64
17:09:59.960724 IP 10.254.10.140 > 192.168.1.21: ICMP echo reply, id
9278, seq 5, length 64
17:10:00.936177 IP 192.168.1.21 > 10.254.10.140: ICMP echo request, id
9278, seq 6, length 64
17:10:01.005849 IP 10.254.10.140 > 192.168.1.21: ICMP echo reply, id
9278, seq 6, length 64
17:10:01.936313 IP 192.168.1.21 > 10.254.10.140: ICMP echo request, id
9278, seq 7, length 64
17:10:01.936626 IP 192.168.1.1 > 192.168.1.21: ICMP host 10.254.10.140
unreachable, length 92
17:10:02.935321 IP 192.168.1.21 > 10.254.10.140: ICMP echo request, id
9278, seq 8, length 64
17:10:02.935591 IP 192.168.1.1 > 192.168.1.21: ICMP host 10.254.10.140
unreachable, length 92
17:10:03.934322 IP 192.168.1.21 > 10.254.10.140: ICMP echo request, id
9278, seq 9, length 64
17:10:03.934613 IP 192.168.1.1 > 192.168.1.21: ICMP host 10.254.10.140
unreachable, length 92




Tried with a different ping implementation (RouterOS) and the behaviour
seems correct:

[vihai@SevioLab SW1] > ping 10.254.10.140
HOST                                     SIZE TTL TIME  STATUS
192.168.1.1                             84  64 0ms   host unreachable
192.168.1.1                             84  64 0ms   host unreachable
192.168.1.1                             84  64 0ms   host unreachable
10.254.10.140                           56  61 20ms
10.254.10.140                           56  61 46ms
10.254.10.140                           56  61 37ms
192.168.1.1                             84  64 0ms   host unreachable
192.168.1.1                             84  64 0ms   host unreachable
192.168.1.1                             84  64 0ms   host unreachable
    sent=3D9 received=3D3 packet-loss=3D66% min-rtt=3D20ms avg-rtt=3D34ms=
 max-rtt=3D46ms


Recently I was pinging with IPv6, a router in between filtered the
packet, however the shown source address was not the right one:

root@monitor:~# ping6 -i 0.2 www.google.com
PING www.google.com(mil01s25-in-x04.1e100.net) 56 data bytes
=46rom mil01s25-in-x04.1e100.net icmp_seq=3D1 Destination unreachable: No=
 route
=46rom mil01s25-in-x04.1e100.net icmp_seq=3D2 Destination unreachable: No=
 route
=46rom mil01s25-in-x04.1e100.net icmp_seq=3D3 Destination unreachable: No=
 route

19:33:19.589285 IP6 2a01:2d8:aca0:fce:944e:c8ff:fe4d:96de >
mil01s25-in-x04.1e100.net: ICMP6, echo request, seq 1, length 64
19:33:19.611666 IP6 mix-br2.intercom.it >
2a01:2d8:aca0:fce:944e:c8ff:fe4d:96de: ICMP6, destination unreachable,
unreachable route mil01s25-in-x04.1e100.net, length 112


Bye,


--------------ms090001050702020307090303
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExDzANBglghkgBZQMEAgEFADCABgkqhkiG9w0BBwEAAKCC
DLowggY0MIIEHKADAgECAgEhMA0GCSqGSIb3DQEBCwUAMH0xCzAJBgNVBAYTAklMMRYwFAYD
VQQKEw1TdGFydENvbSBMdGQuMSswKQYDVQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0aWZpY2F0
ZSBTaWduaW5nMSkwJwYDVQQDEyBTdGFydENvbSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTAe
Fw0wNzEwMjQyMTAyNTVaFw0xNzEwMjQyMTAyNTVaMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UE
ChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUg
U2lnbmluZzE4MDYGA1UEAxMvU3RhcnRDb20gQ2xhc3MgMiBQcmltYXJ5IEludGVybWVkaWF0
ZSBDbGllbnQgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDLKIVFnAEs+xny
q6UzjCqgDcvQVe1dIoFnRsQPCFO+y92k8RK0Pn3MbQ2Gd+mehh9GBZ+36uUQA7Xj9AGM6wgP
hEE34vKtfpAN5tJ8LcFxveDObCKrL7O5UT9WsnAZHv7OYPYSR68mdmnEnJ83M4wQgKO19b+R
t8sPDAz9ptkQsntCn4GeJzg3q2SVc4QJTg/WHo7wF2ah5LMOeh8xJVSKGEmd6uPkSbj113yK
Mm8vmNptRPmM1+YgmVwcdOYJOjCgFtb2sOP79jji8uhWR91xx7TpM1K3hv/wrBZwffrmmEpU
euXHRs07JqCCvFh9coKF4UQZvfEg+x3/69xRCzb1AgMBAAGjggGtMIIBqTAPBgNVHRMBAf8E
BTADAQH/MA4GA1UdDwEB/wQEAwIBBjAdBgNVHQ4EFgQUrlWDb+wxyrn3HfqvazHzyB3jrLsw
HwYDVR0jBBgwFoAUTgvvGqRAW6UXaYcwyjRoQ9BBrvIwZgYIKwYBBQUHAQEEWjBYMCcGCCsG
AQUFBzABhhtodHRwOi8vb2NzcC5zdGFydHNzbC5jb20vY2EwLQYIKwYBBQUHMAKGIWh0dHA6
Ly93d3cuc3RhcnRzc2wuY29tL3Nmc2NhLmNydDBbBgNVHR8EVDBSMCegJaAjhiFodHRwOi8v
d3d3LnN0YXJ0c3NsLmNvbS9zZnNjYS5jcmwwJ6AloCOGIWh0dHA6Ly9jcmwuc3RhcnRzc2wu
Y29tL3Nmc2NhLmNybDCBgAYDVR0gBHkwdzB1BgsrBgEEAYG1NwECATBmMC4GCCsGAQUFBwIB
FiJodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS9wb2xpY3kucGRmMDQGCCsGAQUFBwIBFihodHRw
Oi8vd3d3LnN0YXJ0c3NsLmNvbS9pbnRlcm1lZGlhdGUucGRmMA0GCSqGSIb3DQEBCwUAA4IC
AQBB+mi5D9vIbTZOKU969dKktLFXsc/vv9Do5sQ6FDd3n4m/Snrivk4c7zgHNBJ3GL19qMWL
+Ak4U1FNYjPy9OO27CyIGRO2s13U83eNJOI8CK14wlUm5u+e8UAxVYhFlpvEMgFCW8V5nl+Q
aPGRQCU50nFPISi7/+lyn6OuesWJE+mJcPeWZn1fPfbALkIsnNQSXFYuWWmD8szgZgEfOcho
5tUPlxhUL9IPhvnLKEejRymyZ6gRhZdU6sztTpsDMJ36w2NQfMbkoO2U8nWX29A3/bufc59k
9NKIO3MHFrdTlc271sKQU9gp4x5Te93qc/AmY3G0M+1W6NWYpXuT+qqZDaW6j+NieG3VW/ad
UrLADg+sZkowPlLA0iCPQhxJD4DAnlxHa8IsTYmqlh0bNwkFQxucdoug7Hnc8wujfQDXqyMf
LonDWfFINcw+WnXwPRmrvwtE4wKJhC2Jxpl+r8AuAGqB/Pj33cu04mtarkYNVb896O5prRQS
aSQtspYNODK9VPh7l7PlZ7qP2v+iQPd7GxWgPzadvcvcWBH6sJ9GlcwnZi3iIIRqZm5dJ+9p
G92VhbL4cspI8HTjiqN2aWQZUnvu6yqrDyNuOZHuLZpiNngOnac5zDl80AxhZF8QJCj+cFoi
pAWMh2pQADYbnxA3NMAdv2OMxrlQFnjpqv7I7TCCBn4wggVmoAMCAQICAl4vMA0GCSqGSIb3
DQEBCwUAMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UE
CxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzE4MDYGA1UEAxMvU3RhcnRD
b20gQ2xhc3MgMiBQcmltYXJ5IEludGVybWVkaWF0ZSBDbGllbnQgQ0EwHhcNMTUwMTI4MDQy
MTE5WhcNMTcwMTI4MDYxNDM5WjCBmTELMAkGA1UEBhMCSVQxFjAUBgNVBAgTDU1vbnphIEJy
aWFuemExDzANBgNVBAcTBlNldmVzbzEjMCEGA1UEChMaVXRpbGl0eSBMaW5lIEl0YWxpYSBT
LlIuTC4xGDAWBgNVBAMTD0RhbmllbGUgT3JsYW5kaTEiMCAGCSqGSIb3DQEJARYTZGFuaWVs
ZUBvcmxhbmRpLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAM/CYgmW+M/5
wwh6h0pblNVzsI6+4eUz62GN9HbYQNRQI2UezbZej6NayjjGXt+Ss+MLY5ihNcIPjSQLAMGG
oKYR5ui9/aIrn/C0fWCSbyvyqkhZlIJ+etWF+bRd7TNPsk3owjkzZIAMWQu2QhAHr//YhP2r
o0RIU7N/NenZ84SMr3p+hydWlTIofHiUMku0hZV73in2KhTVShd0bdEO4w5PxjsGF3AyKNHg
MAYalLFkdhpTx/bDs/5lwnyc5Lfcd2GOnYx5VziS18Rl4os2/z7jw4fRK6mlOpje1Ehu+RKL
YsWqsjYrHajhWVaYacpA5Y1NbtBR6jC5gTGxzHE07VcCAwEAAaOCAtkwggLVMAkGA1UdEwQC
MAAwCwYDVR0PBAQDAgSwMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcDBDAdBgNVHQ4E
FgQUz4wY8XctHBuZ5soJHoA34+PAkaYwHwYDVR0jBBgwFoAUrlWDb+wxyrn3HfqvazHzyB3j
rLswHgYDVR0RBBcwFYETZGFuaWVsZUBvcmxhbmRpLmNvbTCCAUwGA1UdIASCAUMwggE/MIIB
OwYLKwYBBAGBtTcBAgMwggEqMC4GCCsGAQUFBwIBFiJodHRwOi8vd3d3LnN0YXJ0c3NsLmNv
bS9wb2xpY3kucGRmMIH3BggrBgEFBQcCAjCB6jAnFiBTdGFydENvbSBDZXJ0aWZpY2F0aW9u
IEF1dGhvcml0eTADAgEBGoG+VGhpcyBjZXJ0aWZpY2F0ZSB3YXMgaXNzdWVkIGFjY29yZGlu
ZyB0byB0aGUgQ2xhc3MgMiBWYWxpZGF0aW9uIHJlcXVpcmVtZW50cyBvZiB0aGUgU3RhcnRD
b20gQ0EgcG9saWN5LCByZWxpYW5jZSBvbmx5IGZvciB0aGUgaW50ZW5kZWQgcHVycG9zZSBp
biBjb21wbGlhbmNlIG9mIHRoZSByZWx5aW5nIHBhcnR5IG9ibGlnYXRpb25zLjA2BgNVHR8E
LzAtMCugKaAnhiVodHRwOi8vY3JsLnN0YXJ0c3NsLmNvbS9jcnR1Mi1jcmwuY3JsMIGOBggr
BgEFBQcBAQSBgTB/MDkGCCsGAQUFBzABhi1odHRwOi8vb2NzcC5zdGFydHNzbC5jb20vc3Vi
L2NsYXNzMi9jbGllbnQvY2EwQgYIKwYBBQUHMAKGNmh0dHA6Ly9haWEuc3RhcnRzc2wuY29t
L2NlcnRzL3N1Yi5jbGFzczIuY2xpZW50LmNhLmNydDAjBgNVHRIEHDAahhhodHRwOi8vd3d3
LnN0YXJ0c3NsLmNvbS8wDQYJKoZIhvcNAQELBQADggEBAD9sR08GDNQg307JknnSUkN8CWFI
+9yLFonUUpcTWuOqNrL1PUysNX8Jq+PWhyDlvvLv70T38tRTNnLLggt2GFUSYDSjlrmKzIOa
ttBCkr+h83sxCBpm41jQRcsiPHfm9TXn8Oy3QaNOlWZpjToaN8golSKgCR5zvKCw5QZZCRGi
j4twct2UXBSkM6eED1h09CFfUNGExN5FWqP5RZI7S7FccBgxFNG5K12Rm/W2VtesL8cVg6Rj
D71IuoXbUlCY22QyWaww4QTZJVnv6mUiBGXeQn2KTd5Iis+gv4BdQjlQ5zvEmcCCoDSfJLTI
tON1rXXORiuLE+9W67Ce0ddNaZExggPqMIID5gIBATCBkzCBjDELMAkGA1UEBhMCSUwxFjAU
BgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmlj
YXRlIFNpZ25pbmcxODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDIgUHJpbWFyeSBJbnRlcm1l
ZGlhdGUgQ2xpZW50IENBAgJeLzANBglghkgBZQMEAgEFAKCCAicwGAYJKoZIhvcNAQkDMQsG
CSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTYwNDEyMTc1MjE1WjAvBgkqhkiG9w0BCQQx
IgQg7REfAMFRGRrVQinBXFAKGEiDI0+ySy+4hHqNCGt79f8wbAYJKoZIhvcNAQkPMV8wXTAL
BglghkgBZQMEASowCwYJYIZIAWUDBAECMAoGCCqGSIb3DQMHMA4GCCqGSIb3DQMCAgIAgDAN
BggqhkiG9w0DAgIBQDAHBgUrDgMCBzANBggqhkiG9w0DAgIBKDCBpAYJKwYBBAGCNxAEMYGW
MIGTMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMi
U2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzE4MDYGA1UEAxMvU3RhcnRDb20g
Q2xhc3MgMiBQcmltYXJ5IEludGVybWVkaWF0ZSBDbGllbnQgQ0ECAl4vMIGmBgsqhkiG9w0B
CRACCzGBlqCBkzCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzAp
BgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNVBAMTL1N0
YXJ0Q29tIENsYXNzIDIgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENBAgJeLzANBgkq
hkiG9w0BAQEFAASCAQCdlwNnl0iHoczXUAJcT9a6ZBectCHvELZKJwcgkhxYoxblT0W1fRFV
cac0HQke72BzoHAfW+4peN8W/Fum9b4+kXsszg9LCTG9SBjeB2Ya9Jz0s3paHYsMOpYx6faS
k8uhcoGZlm95Qv12dQ1RHTxPbfplMgG6VCgZEITpzlTKYbrDOC862fvBpVb6m3UKzif7w0+C
Ef+nSej7EyvLCMd7YiKz1XzUNnIM9gv+s3sj8jOlz8o/Sth/EFXH6E986AMDG1BkHiAiivhT
eHPtUevHUaaObW9+YjaNXHDvimX/HhWCVT2Rvg9hVvWhp/957jrab98Zf3ncaWSedZz+CwLy
AAAAAAAA
--------------ms090001050702020307090303--
