From: Nigel Kukard <nkukard@lbsd.net>
Subject: [PATCH] iproute2 - Fix tc stats when using -batch mode
Date: Mon, 14 Oct 2013 22:16:36 +0000
Message-ID: <sig.1999aa60cf.525C6D44.9040207@lbsd.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha1; boundary="------------ms020701040905090801090001"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from uk.eu.mailhost.iitsp.com ([217.147.85.13]:50349 "EHLO
	uk.eu.mailhost.iitsp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757047Ab3JNWQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 18:16:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms020701040905090801090001
Content-Type: multipart/mixed;
 boundary="------------070400020001080200010901"

This is a multi-part message in MIME format.
--------------070400020001080200010901
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable

Hi,

There are two global variables in tc/tc_class.c:
__u32 filter_qdisc;
__u32 filter_classid;

These are not re-initialized for each line received in -batch mode:
# tc -force -batch -
class show dev eth0 parent 1: classid 1:1
class show dev eth0 parent 1: classid 1:1
Error: duplicate "classid": "1:1" is the second value.

This patch fixes the issue by initializing the two globals when we
enter print_class().


Attached a patch which fixes this by initializing them when=20
print_class() is called.


-N

--------------070400020001080200010901
Content-Type: text/x-patch;
 name="batchfix.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="batchfix.patch"

commit d04acab5a8c0267610e9ea21f8a42e54ed4585dc
Author: Nigel Kukard <nkukard@lbsd.net>
Date:   Mon Oct 14 22:10:16 2013 +0000

    Fix tc stats when using -batch mode
   =20
    There are two global variables in tc/tc_class.c:
    __u32 filter_qdisc;
    __u32 filter_classid;
   =20
    These are not re-initialized for each line received in -batch mode:
    class show dev eth0 parent 1: classid 1:1
    class show dev eth0 parent 1: classid 1:1
    Error: duplicate "classid": "1:1" is the second value.
   =20
    This patch fixes the issue by initializing the two globals when we
    enter print_class().

diff --git a/tc/tc_class.c b/tc/tc_class.c
index 9d4eea5..8043448 100644
--- a/tc/tc_class.c
+++ b/tc/tc_class.c
@@ -241,6 +241,9 @@ int tc_class_list(int argc, char **argv)
 	t.tcm_family =3D AF_UNSPEC;
 	memset(d, 0, sizeof(d));
=20
+	filter_qdisc =3D 0;
+	filter_classid =3D 0;
+
 	while (argc > 0) {
 		if (strcmp(*argv, "dev") =3D=3D 0) {
 			NEXT_ARG();

--------------070400020001080200010901--

--------------ms020701040905090801090001
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIILejCC
BRowggQCoAMCAQICEG0Z6qcZT2ozIuYiMnqqcd4wDQYJKoZIhvcNAQEFBQAwga4xCzAJBgNV
BAYTAlVTMQswCQYDVQQIEwJVVDEXMBUGA1UEBxMOU2FsdCBMYWtlIENpdHkxHjAcBgNVBAoT
FVRoZSBVU0VSVFJVU1QgTmV0d29yazEhMB8GA1UECxMYaHR0cDovL3d3dy51c2VydHJ1c3Qu
Y29tMTYwNAYDVQQDEy1VVE4tVVNFUkZpcnN0LUNsaWVudCBBdXRoZW50aWNhdGlvbiBhbmQg
RW1haWwwHhcNMTEwNDI4MDAwMDAwWhcNMjAwNTMwMTA0ODM4WjCBkzELMAkGA1UEBhMCR0Ix
GzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEaMBgGA1UE
ChMRQ09NT0RPIENBIExpbWl0ZWQxOTA3BgNVBAMTMENPTU9ETyBDbGllbnQgQXV0aGVudGlj
YXRpb24gYW5kIFNlY3VyZSBFbWFpbCBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
ggEBAJKEhFtLV5jUXi+LpOFAyKNTWF9mZfEyTvefMn1V0HhMVbdClOD5J3EHxcZppLkyxPFA
GpDMJ1Zifxe1cWmu5SAb5MtjXmDKokH2auGj/7jfH0htZUOMKi4rYzh337EXrMLaggLW1DJq
1GdvIBOPXDX65VSAr9hxCh03CgJQU2yVHakQFLSZlVkSMf8JotJM3FLb3uJAAVtIaN3FSrTg
7SQfOq9xXwfjrL8UO7AlcWg99A/WF1hGFYE8aIuLgw9teiFX5jSw2zJ+40rhpVJyZCaRTqWS
D//gsWD9Gm9oUZljjRqLpcxCm5t9ImPTqaD8zp6Q30QZ9FxbNboW86eb/8ECAwEAAaOCAUsw
ggFHMB8GA1UdIwQYMBaAFImCZ33EnSZwAEu0UEh83j2uBG59MB0GA1UdDgQWBBR6E04AdFvG
eGNkJ8Ev4qBbvHnFezAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIBADARBgNV
HSAECjAIMAYGBFUdIAAwWAYDVR0fBFEwTzBNoEugSYZHaHR0cDovL2NybC51c2VydHJ1c3Qu
Y29tL1VUTi1VU0VSRmlyc3QtQ2xpZW50QXV0aGVudGljYXRpb25hbmRFbWFpbC5jcmwwdAYI
KwYBBQUHAQEEaDBmMD0GCCsGAQUFBzAChjFodHRwOi8vY3J0LnVzZXJ0cnVzdC5jb20vVVRO
QWRkVHJ1c3RDbGllbnRfQ0EuY3J0MCUGCCsGAQUFBzABhhlodHRwOi8vb2NzcC51c2VydHJ1
c3QuY29tMA0GCSqGSIb3DQEBBQUAA4IBAQCF1r54V1VtM39EUv5C1QaoAQOAivsNsv1Kv/av
QUn1G1rF0q0bc24+6SZ85kyYwTAo38v7QjyhJT4KddbQPTmGZtGhm7VNm2+vKGwdr+XqdFqo
2rHA8XV6L566k3nK/uKRHlZ0sviN0+BDchvtj/1gOSBH+4uvOmVIPJg9pSW/ve9g4EnlFsjr
P0OD8ODuDcHTzTNfm9C9YGqzO/761Mk6PB/tm/+bSTO+Qik5g+4zaS6CnUVNqGnagBsePdIa
XXxHmaWbCG0SmYbWXVcHG6cwvktJRLiQfsrReTjrtDP6oDpdJlieYVUYtCHVmdXgQ0BCML7q
peeU0rD+83X5f27nMIIGWDCCBUCgAwIBAgIRANiA4C7vOx6M46Rmg48Ovx4wDQYJKoZIhvcN
AQEFBQAwgZMxCzAJBgNVBAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAO
BgNVBAcTB1NhbGZvcmQxGjAYBgNVBAoTEUNPTU9ETyBDQSBMaW1pdGVkMTkwNwYDVQQDEzBD
T01PRE8gQ2xpZW50IEF1dGhlbnRpY2F0aW9uIGFuZCBTZWN1cmUgRW1haWwgQ0EwHhcNMTEx
MDI1MDAwMDAwWhcNMTQxMDI0MjM1OTU5WjCCAWsxCzAJBgNVBAYTAlpBMQ0wCwYDVQQREwQ3
NDQxMRUwEwYDVQQIEwxXZXN0ZXJuIENhcGUxEjAQBgNVBAcTCU1pbG5lcnRvbjEVMBMGA1UE
CRMMQ2VudHVyeSBDaXR5MRYwFAYDVQQJEw1UaGUgQ29sb3NzZXVtMR0wGwYDVQQJExRGaXJz
dCBGbG9vciwgRm95ZXIgMzEwMC4GA1UEChMnTGludXggQmFzZWQgU3lzdGVtcyBEZXNpZ24g
U0EgKFB0eSkgTHRkMUkwRwYDVQQLE0BJc3N1ZWQgdGhyb3VnaCBMaW51eCBCYXNlZCBTeXN0
ZW1zIERlc2lnbiBTQSAoUHR5KSBMdGQgRS1QS0kgTWFuMR8wHQYDVQQLExZDb3Jwb3JhdGUg
U2VjdXJlIEVtYWlsMRUwEwYDVQQDEwxOaWdlbCBLdWthcmQxHzAdBgkqhkiG9w0BCQEWEG5r
dWthcmRAbGJzZC5uZXQwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC+YRHpNKky
TiAKs+gjZ8SS4UEpvqBV1DM7WxLv8+p8xQ6byUoII2YdCVGQsbQAt9OsgVwQdPeC+ALBrx1x
QLN+U2W8bu4d46KROYOmJbESi9G2ltUJO2FyxYPYNgOt9chaFy/PsRo71/kOLacrv/2zluxE
+CmrtMlsvZ7Pk3r5hTBI74wn6eE/TSN62L+lOuOtcMDLhbRxiCdNlPKWu1CFlVSzIV53A4wa
MEpPRx6Y99iyXRbLk20qa+9468OZAkThm0CoHYqeqQLrzihIy09uBGLbx/gVunDIIqbaKSAk
ukpCQffKzt/b0s5ZK5S8HF7GjOvn8B0aE3aJVzWPSLifAgMBAAGjggHKMIIBxjAfBgNVHSME
GDAWgBR6E04AdFvGeGNkJ8Ev4qBbvHnFezAdBgNVHQ4EFgQUZ5R3NEGen1Qp4WYR+aJ+/a6K
mg0wDgYDVR0PAQH/BAQDAgWgMAwGA1UdEwEB/wQCMAAwHQYDVR0lBBYwFAYIKwYBBQUHAwQG
CCsGAQUFBwMCMEYGA1UdIAQ/MD0wOwYMKwYBBAGyMQECAQMFMCswKQYIKwYBBQUHAgEWHWh0
dHBzOi8vc2VjdXJlLmNvbW9kby5uZXQvQ1BTMFcGA1UdHwRQME4wTKBKoEiGRmh0dHA6Ly9j
cmwuY29tb2RvY2EuY29tL0NPTU9ET0NsaWVudEF1dGhlbnRpY2F0aW9uYW5kU2VjdXJlRW1h
aWxDQS5jcmwwgYgGCCsGAQUFBwEBBHwwejBSBggrBgEFBQcwAoZGaHR0cDovL2NydC5jb21v
ZG9jYS5jb20vQ09NT0RPQ2xpZW50QXV0aGVudGljYXRpb25hbmRTZWN1cmVFbWFpbENBLmNy
dDAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuY29tb2RvY2EuY29tMBsGA1UdEQQUMBKBEG5r
dWthcmRAbGJzZC5uZXQwDQYJKoZIhvcNAQEFBQADggEBAH9X3u/2BbEvZ6g29eVp6qmTB7I3
kFpjvEyMvguCwrUcS3xtofI7IFD51iK4sNgYpyHYpAKkr6deuOCEvhJgWzU/5owmoFaUKEAc
uHHSrzGsLrA+d9yJeLrLo5OnL/A7s+obL6DiIX1m4QRJWBgaBdJB13DKOTNoZpuerSEW0H6a
2yyk9UroYEn2fVi4opRzLTJzvdTMSo7lRmlHwjVXSQnaxDtW3hjiLkuh2/a+5YfMxMz2TE7T
7Bt7M3FuA9Xy0FM6TE1VBykGdElhWwM+5WZlRArFm63dUj0HR5ze19j+iya/STIIXdCna846
mgyqrXxTHMtGxIsCijqxUn8SlIIxggQcMIIEGAIBATCBqTCBkzELMAkGA1UEBhMCR0IxGzAZ
BgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEaMBgGA1UEChMR
Q09NT0RPIENBIExpbWl0ZWQxOTA3BgNVBAMTMENPTU9ETyBDbGllbnQgQXV0aGVudGljYXRp
b24gYW5kIFNlY3VyZSBFbWFpbCBDQQIRANiA4C7vOx6M46Rmg48Ovx4wCQYFKw4DAhoFAKCC
AkcwGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTMxMDE0MjIx
NjM2WjAjBgkqhkiG9w0BCQQxFgQUmxlzsLobmK5yEUp0Fqln5OLxvEEwbAYJKoZIhvcNAQkP
MV8wXTALBglghkgBZQMEASowCwYJYIZIAWUDBAECMAoGCCqGSIb3DQMHMA4GCCqGSIb3DQMC
AgIAgDANBggqhkiG9w0DAgIBQDAHBgUrDgMCBzANBggqhkiG9w0DAgIBKDCBugYJKwYBBAGC
NxAEMYGsMIGpMIGTMQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVy
MRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQKExFDT01PRE8gQ0EgTGltaXRlZDE5MDcGA1UE
AxMwQ09NT0RPIENsaWVudCBBdXRoZW50aWNhdGlvbiBhbmQgU2VjdXJlIEVtYWlsIENBAhEA
2IDgLu87HozjpGaDjw6/HjCBvAYLKoZIhvcNAQkQAgsxgayggakwgZMxCzAJBgNVBAYTAkdC
MRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGjAYBgNV
BAoTEUNPTU9ETyBDQSBMaW1pdGVkMTkwNwYDVQQDEzBDT01PRE8gQ2xpZW50IEF1dGhlbnRp
Y2F0aW9uIGFuZCBTZWN1cmUgRW1haWwgQ0ECEQDYgOAu7zsejOOkZoOPDr8eMA0GCSqGSIb3
DQEBAQUABIIBAJRAv3LqkMhaw435H/oY7ZbIIUBLZ68zEhQrrPGXKU4yp618l8giPVwRnio7
NDh77i+/fHPeOjk49mp+0pGeWmZRj1G3NPaROacLsm94RDVJ9Kk6K62gWcLSGLg6Jblh6Ih7
qcOWlFXd/oEhJ+sS2ZiJS2miYGHdKXomvY4U0V1ZuPq2XvqcGq5jOdTZgrNyB0XO+15H9WJH
7KTyVf6VtB/GVLuWGMZs1njP+PVzj8Mcqlew49OQw6jWypkplaD8iF/SXrTlPDhLonuF6I9E
4/NxiXPG0C3OzxpIkvj6PsnFBAd+xLWXjPec5rErVpzHjTuYTHFoWCqcs3B/PGqbCPwAAAAA
AAA=
--------------ms020701040905090801090001--
