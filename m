From: Wang Shanker <shankerwangmiao@gmail.com>
Subject: [PATCH] net: l2tp: fix reversed udp6 checksum flags
Date: Fri, 29 Apr 2016 01:29:43 +0800
Message-ID: <9A325D67-FED1-4AF6-8ED0-6C93FFE8DC67@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: multipart/signed; boundary="Apple-Mail=_D53B147A-ACEA-4722-8273-5C0916E068B9"; protocol="application/pkcs7-signature"; micalg=sha1
Cc: James Chapman <jchapman@katalix.com>,
	Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34222 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752560AbcD1R3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 13:29:49 -0400
Received: by mail-pa0-f51.google.com with SMTP id r5so34863528pag.1
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 10:29:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail=_D53B147A-ACEA-4722-8273-5C0916E068B9
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii

This patch fixes a bug which causes the behavior of whether to ignore
udp6 checksum of udp6 encapsulated l2tp tunnel contrary to what
userspace program requests.

When the flag `L2TP_ATTR_UDP_ZERO_CSUM6_RX` is set by userspace, it is
expected that udp6 checksums of received packets of the l2tp tunnel
to create should be ignored. In `l2tp_netlink.c`:
`l2tp_nl_cmd_tunnel_create()`, `cfg.udp6_zero_rx_checksums` is set
according to the flag, and then passed to `l2tp_core.c`:
`l2tp_tunnel_create()` and then `l2tp_tunnel_sock_create()`. In
`l2tp_tunnel_sock_create()`, `udp_conf.use_udp6_rx_checksums` is set
the same to `cfg.udp6_zero_rx_checksums`. However, if we want the
checksum to be ignored, `udp_conf.use_udp6_rx_checksums` should be set
to `false`, i.e. be set to the contrary. Similarly, the same should be
done to `udp_conf.use_udp6_tx_checksums`.

Signed-off-by: Miao Wang <shankerwangmiao@gmail.com>
---
 net/l2tp/l2tp_core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index afca2eb..6edfa99 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1376,9 +1376,9 @@ static int l2tp_tunnel_sock_create(struct net *net,
 			memcpy(&udp_conf.peer_ip6, cfg->peer_ip6,
 			       sizeof(udp_conf.peer_ip6));
 			udp_conf.use_udp6_tx_checksums =
-			    cfg->udp6_zero_tx_checksums;
+			  ! cfg->udp6_zero_tx_checksums;
 			udp_conf.use_udp6_rx_checksums =
-			    cfg->udp6_zero_rx_checksums;
+			  ! cfg->udp6_zero_rx_checksums;
 		} else
 #endif
 		{
-- 
2.5.2


--Apple-Mail=_D53B147A-ACEA-4722-8273-5C0916E068B9
Content-Disposition: attachment;
	filename=smime.p7s
Content-Type: application/pkcs7-signature;
	name=smime.p7s
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIMdTCCBjQw
ggQcoAMCAQICAR4wDQYJKoZIhvcNAQEFBQAwfTELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0
Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxKTAn
BgNVBAMTIFN0YXJ0Q29tIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTA3MTAyNDIxMDE1NVoX
DTE3MTAyNDIxMDE1NVowgYwxCzAJBgNVBAYTAklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSsw
KQYDVQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0aWZpY2F0ZSBTaWduaW5nMTgwNgYDVQQDEy9TdGFy
dENvbSBDbGFzcyAxIFByaW1hcnkgSW50ZXJtZWRpYXRlIENsaWVudCBDQTCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAMcJg8zOLdgasSmkLhOrlr6KMoOMpohBllVHrdRvEg/q6r8jR+EK
75xCGhR8ToREoqe7zM9/UnC6TS2y9UKTpT1v7RSMzR0t6ndl0TWBuUr/UXBhPk+Kmy7bI4yW4urC
+y7P3/1/X7U8ocb8VpH/Clt+4iq7nirMcNh6qJR+xjOhV+VHzQMALuGYn5KZmc1NbJQYclsGkDxD
z2UbFqE2+6vIZoL+jb9x4Pa5gNf1TwSDkOkikZB1xtB4ZqtXThaABSONdfmv/Z1pua3FYxnCFmdr
/+N2JLKutIxMYqQOJebr/f/h5t95m4JgrM3Y/w7YX9d7YAL9jvN4SydHsU6n65cCAwEAAaOCAa0w
ggGpMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgEGMB0GA1UdDgQWBBRTcu2SnODaywFc
fH6WNU7y1LhRgjAfBgNVHSMEGDAWgBROC+8apEBbpRdphzDKNGhD0EGu8jBmBggrBgEFBQcBAQRa
MFgwJwYIKwYBBQUHMAGGG2h0dHA6Ly9vY3NwLnN0YXJ0c3NsLmNvbS9jYTAtBggrBgEFBQcwAoYh
aHR0cDovL3d3dy5zdGFydHNzbC5jb20vc2ZzY2EuY3J0MFsGA1UdHwRUMFIwJ6AloCOGIWh0dHA6
Ly93d3cuc3RhcnRzc2wuY29tL3Nmc2NhLmNybDAnoCWgI4YhaHR0cDovL2NybC5zdGFydHNzbC5j
b20vc2ZzY2EuY3JsMIGABgNVHSAEeTB3MHUGCysGAQQBgbU3AQIBMGYwLgYIKwYBBQUHAgEWImh0
dHA6Ly93d3cuc3RhcnRzc2wuY29tL3BvbGljeS5wZGYwNAYIKwYBBQUHAgEWKGh0dHA6Ly93d3cu
c3RhcnRzc2wuY29tL2ludGVybWVkaWF0ZS5wZGYwDQYJKoZIhvcNAQEFBQADggIBAAqDCH14qywG
XLhjjF6uHLkjd02hcdh9hrw+VUsv+q1eeQWB21jWj3kJ96AUlPCoEGZ/ynJNScWy6QMVQjbbMXlt
UfO4n4bGGdKo3awPWp61tjAFgraLJgDk+DsSvUD6EowjMTNx25GQgyYJ5RPIzKKR9tQW8gGK+2+R
HxkUCTbYFnL6kl8Ch507rUdPPipJ9CgJFws3kDS3gOS5WFMxcjO5DwKfKSETEPrHh7p5shuuNktv
sv6hxHTLhiMKX893gxdT3XLS9OKmCv87vkINQcNEcIIoFWbP9HORz9v3vQwR4e3ksLc2JZOAFK+s
sS5XMEoznzpihEP0PLc4dCBYjbvSD7kxgDwZ+Aj8Q9PkbvE9sIPP7ON0fz095HdThKjiVJe6vofq
+n6b1NBc8XdrQvBmunwxD5nvtTW4vtN6VY7mUCmxsCieuoBJ9OlqmsVWQvifIYf40dJPZkk9YgGT
zWLpXDSfLSplbY2LL9C9U0ptvjcDjefLTvqSFc7tw1sEhF0n/qpA2r0GpvkLRDmcSwVyPvmjFBGq
Up/pNy8ZuPGQmHwFi2/14+xeSUDG2bwnsYJQG2EdJCB6luQ57GEnTA/yKZSTKI8dDQa8Sd3zfXb1
9mOgSF0bBdXbuKhEpuP9wirslFe6fQ1t5j5R0xi72MZ8ikMu1RQZKCyDbMwazlHiMIIGOTCCBSGg
AwIBAgIDDv9GMA0GCSqGSIb3DQEBCwUAMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRD
b20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzE4MDYG
A1UEAxMvU3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IEludGVybWVkaWF0ZSBDbGllbnQgQ0EwHhcN
MTUwODExMDk1NjA4WhcNMTYwODEyMDIwODUwWjBOMSIwIAYDVQQDDBlzaGFua2Vyd2FuZ21pYW9A
Z21haWwuY29tMSgwJgYJKoZIhvcNAQkBFhlzaGFua2Vyd2FuZ21pYW9AZ21haWwuY29tMIIBIjAN
BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwB9ZB/Au3Wnciv7VW8oKtPPVbaD7zFAhbWDFrq6N
0mmEBg5xqbEvmsO3KwKmXe9c7C5cxwIXC8XSAPOQCPoWC0mXmCM1cacWnDonHa+pIgEmreoUmwyD
q4x00vODejFtF7oUFeteDwBKxAxeF8PkyCINwGVLloJFJCctDL3+3XZ+H2ZTluRKil/5TvO1hiEt
V7N9kI0K0gJhTnLDG7n+YdWHHCrpBbdJ3Te4eQqpRHegPSEz+kbXDPgCVHI86ze0A11I0mDWOVN/
4Fxw/0voecL2tuh4NHsZ9H/TPZw7AWLKdzlv/vJUOxHqky2gRdaIlheW5uzOvIt6DK4DTi3n9wID
AQABo4IC3zCCAtswCQYDVR0TBAIwADALBgNVHQ8EBAMCBLAwHQYDVR0lBBYwFAYIKwYBBQUHAwIG
CCsGAQUFBwMEMB0GA1UdDgQWBBRrXUiEjuNWrWV2DoY2Y8YuFBl0qzAfBgNVHSMEGDAWgBRTcu2S
nODaywFcfH6WNU7y1LhRgjAkBgNVHREEHTAbgRlzaGFua2Vyd2FuZ21pYW9AZ21haWwuY29tMIIB
TAYDVR0gBIIBQzCCAT8wggE7BgsrBgEEAYG1NwECAzCCASowLgYIKwYBBQUHAgEWImh0dHA6Ly93
d3cuc3RhcnRzc2wuY29tL3BvbGljeS5wZGYwgfcGCCsGAQUFBwICMIHqMCcWIFN0YXJ0Q29tIENl
cnRpZmljYXRpb24gQXV0aG9yaXR5MAMCAQEagb5UaGlzIGNlcnRpZmljYXRlIHdhcyBpc3N1ZWQg
YWNjb3JkaW5nIHRvIHRoZSBDbGFzcyAxIFZhbGlkYXRpb24gcmVxdWlyZW1lbnRzIG9mIHRoZSBT
dGFydENvbSBDQSBwb2xpY3ksIHJlbGlhbmNlIG9ubHkgZm9yIHRoZSBpbnRlbmRlZCBwdXJwb3Nl
IGluIGNvbXBsaWFuY2Ugb2YgdGhlIHJlbHlpbmcgcGFydHkgb2JsaWdhdGlvbnMuMDYGA1UdHwQv
MC0wK6ApoCeGJWh0dHA6Ly9jcmwuc3RhcnRzc2wuY29tL2NydHUxLWNybC5jcmwwgY4GCCsGAQUF
BwEBBIGBMH8wOQYIKwYBBQUHMAGGLWh0dHA6Ly9vY3NwLnN0YXJ0c3NsLmNvbS9zdWIvY2xhc3Mx
L2NsaWVudC9jYTBCBggrBgEFBQcwAoY2aHR0cDovL2FpYS5zdGFydHNzbC5jb20vY2VydHMvc3Vi
LmNsYXNzMS5jbGllbnQuY2EuY3J0MCMGA1UdEgQcMBqGGGh0dHA6Ly93d3cuc3RhcnRzc2wuY29t
LzANBgkqhkiG9w0BAQsFAAOCAQEAe5XhL57HyMjbkRhKggwhTv+Ccl2C16lW37jwl8pDDIEy4xZq
kt0J2T4wAPWOnRjWfMiBC5Y4QqT9IUlWZnE4BfsgbmRSrbXKfafLJkXBJNn+sVbpf6YsKLNoaZwC
Bb+7W2sSs7SIq1v3m8A+kR/VmisqGakqy0LlFrwqddDRmMweuVY4RDYbJi+LQfiRlorhzobOnYKc
/QEiCpbLru5vuKVDF3GoqhFBxuFIUPMtJ9Rzqjtp8PSg8Dp2TTzpEBumc2oCxc7vmsYuNT0duGR+
9k6XIJJEDFvJrUYZM1RnSuyF7mmQi+LTPmlHHCp8u+7PZJaa2rSI1+Oup2lJqD56pDGCA28wggNr
AgEBMIGUMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMi
U2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzE4MDYGA1UEAxMvU3RhcnRDb20gQ2xh
c3MgMSBQcmltYXJ5IEludGVybWVkaWF0ZSBDbGllbnQgQ0ECAw7/RjAJBgUrDgMCGgUAoIIBrzAY
BgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xNjA0MjgxNzI5NDRaMCMG
CSqGSIb3DQEJBDEWBBSUNKi1hl2nQnaUyuhnBUx55A0fITCBpQYJKwYBBAGCNxAEMYGXMIGUMIGM
MQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERp
Z2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzE4MDYGA1UEAxMvU3RhcnRDb20gQ2xhc3MgMSBQcmlt
YXJ5IEludGVybWVkaWF0ZSBDbGllbnQgQ0ECAw7/RjCBpwYLKoZIhvcNAQkQAgsxgZeggZQwgYwx
CzAJBgNVBAYTAklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSswKQYDVQQLEyJTZWN1cmUgRGln
aXRhbCBDZXJ0aWZpY2F0ZSBTaWduaW5nMTgwNgYDVQQDEy9TdGFydENvbSBDbGFzcyAxIFByaW1h
cnkgSW50ZXJtZWRpYXRlIENsaWVudCBDQQIDDv9GMA0GCSqGSIb3DQEBAQUABIIBADryqd7c5rvm
LIJU5lBgyYcqldk5+yR/GRA0wB/9tcaX7sKzsF7h/02VfxTSLu1sEQ91ZfFz0RTpUkf+VWRqkCAH
azwrcpUhv0uywG7ALb+u0GpUVuwGIs1/CLFdQHGdDIXHIpWHGhUoOoCckyYvQCfMPDw4ySVbF8Ig
oTbf6UXRpJyEcDpQ4w95j+h7qUItNTmwQjytVe1BzTX7gF1R8Rc4we8U8bnOkarZfLehWbd2Qihw
mzPpdjuJwlwajbYa6XsbZgPDuoL5lJxYMeHrARbKT9dybVfxqHTaHWzqYv1oXxFJQV7yQOFCAFOI
DegwgVpIm429ZULdXI6G47AR5pIAAAAAAAA=
--Apple-Mail=_D53B147A-ACEA-4722-8273-5C0916E068B9--
