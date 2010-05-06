From: Lars Eggert <lars.eggert@nokia.com>
Subject: Re: 3 packet TCP window limit?
Date: Thu, 6 May 2010 08:15:03 +0200
Message-ID: <0C1FD143-5588-4455-B08F-85ADD19E0E02@nokia.com>
References: <alpine.LNX.2.00.1005050210230.8544@d>  <4BE171EC.20904@athenacr.com> <alpine.LNX.2.00.1005051239290.28957@d>  <4BE1D3B0.9000207@hp.com> <alpine.LNX.2.00.1005051421010.28957@d>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: multipart/signed; boundary=Apple-Mail-46-614044316; protocol="application/pkcs7-signature"; micalg=sha1
Cc: Rick Jones <rick.jones2@hp.com>, Brian Bloniarz <bmb@athenacr.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: dormando <dormando@rydia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:62065 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751100Ab0EFGPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 02:15:53 -0400
In-Reply-To: <alpine.LNX.2.00.1005051421010.28957@d>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail-46-614044316
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Hi,

On 2010-5-5, at 23:31, dormando wrote:
> The RFC clearly states "around 4k",

no, it doesn't. RFC3390 gives a very precise formula for calculating the =
initial window:

	min (4*MSS, max (2*MSS, 4380 bytes))

Please see the RFC for why. More reading at =
http://www.icir.org/floyd/tcp_init_win.html I believe that Linux =
implements behavior this pretty faithfully.

> but these other OS's/products have an
> extra kilobyte snuck in? Could this be on purpose via rfc
> interpretation, or an off by one on the initcwnd estimator? :)

I'm surprised to hear that OpenBSD doesn't follow the RFC. Can you share =
a measurement? Are you sure the box you are measuring is using the =
default configuration?

I don't think the RFC can be misread (it's pretty clear), and the =
formula is also not exactly complicated. My guess would be that some =
vendors have convinced themselves that using a slightly larger value is =
OK, esp. if they can show customers that "their" TCP is "faster" than =
some competitors' TCPs. An arms race between vendors in this space would =
really not be good for anyone - it's clear that at some point, problems =
due to overshoot will occur.

(We can definitely argue about whether the current RFC-recommended value =
is too low, and Google and others are gathering data in support of =
making a convincing and backed-up argument for increasing the initial =
window to the IETF. Which is exactly the correct way of going about =
this.)

Lars=

--Apple-Mail-46-614044316
Content-Disposition: attachment;
	filename=smime.p7s
Content-Type: application/pkcs7-signature;
	name=smime.p7s
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIGbDCCAyUw
ggKOoAMCAQICEAdjk36sXKbnVn15S0/qUp0wDQYJKoZIhvcNAQEFBQAwYjELMAkGA1UEBhMCWkEx
JTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMTI1RoYXd0ZSBQ
ZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBMB4XDTA5MDYxNTExMjYxNFoXDTEwMDYxNTExMjYx
NFowXDEPMA0GA1UEBBMGRWdnZXJ0MQ0wCwYDVQQqEwRMYXJzMRQwEgYDVQQDEwtMYXJzIEVnZ2Vy
dDEkMCIGCSqGSIb3DQEJARYVbGFycy5lZ2dlcnRAbm9raWEuY29tMIIBIjANBgkqhkiG9w0BAQEF
AAOCAQ8AMIIBCgKCAQEA7mR8A+Pn0/FsUkMX6Pyjw+FL3IFcJk8GaKV5VJ40TMI0Wh8oq20cqA9X
uqnVDW9WztKwH+o+msJenLwWpprbpJm4TImYGbnUJxYyN8gb81aiX1Bw2xCpJ5z3H2+8DsReJLuY
Rdl4bVvaIxLIL4odmfsRwzPyNkOK8LRtfl6OPcaDOlFWzbikULfIVGGu7BqK4lxQSpYwwpZkOMOB
6nnBSfUOtBEmqO+qZG/nL/JxWFV5vxQgg4XHbsMMTxFf6+ji18BD09BUIfDLTuJoCzFmQhrM9vLT
VuRhHWSL20LoafGjXv6mPt3i9IGJHpVb2dMQUgOgRyWHTKiUJVU/rUTdWwIDAQABo14wXDAqBgUr
ZQEEAQQhMB8CAQAwGjAYAgEEBBNMMnVNeWZmQk5VYk5KSmNkWjJzMCAGA1UdEQQZMBeBFWxhcnMu
ZWdnZXJ0QG5va2lhLmNvbTAMBgNVHRMBAf8EAjAAMA0GCSqGSIb3DQEBBQUAA4GBADUx+67n98wt
I1vydB90HeSZP4Y64VCxxb0NxGGFvfc2+JdVKeHJ/xT+l+ygYKsWNwJJprkPi4WZ5G0crkq4VK1H
5drEJIztpSPVfWI05vPidaaGuuuCR+6MvJMtOTEYEvc/6eovBnkrzRf9x5x5EyuJXAWTeuBADg80
QI3vQ1tZMIIDPzCCAqigAwIBAgIBDTANBgkqhkiG9w0BAQUFADCB0TELMAkGA1UEBhMCWkExFTAT
BgNVBAgTDFdlc3Rlcm4gQ2FwZTESMBAGA1UEBxMJQ2FwZSBUb3duMRowGAYDVQQKExFUaGF3dGUg
Q29uc3VsdGluZzEoMCYGA1UECxMfQ2VydGlmaWNhdGlvbiBTZXJ2aWNlcyBEaXZpc2lvbjEkMCIG
A1UEAxMbVGhhd3RlIFBlcnNvbmFsIEZyZWVtYWlsIENBMSswKQYJKoZIhvcNAQkBFhxwZXJzb25h
bC1mcmVlbWFpbEB0aGF3dGUuY29tMB4XDTAzMDcxNzAwMDAwMFoXDTEzMDcxNjIzNTk1OVowYjEL
MAkGA1UEBhMCWkExJTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNV
BAMTI1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBMIGfMA0GCSqGSIb3DQEBAQUA
A4GNADCBiQKBgQDEpjxVc1X7TrnKmVoeaMB1BHCd3+n/ox7svc31W/Iadr1/DDph8r9RzgHU5VAK
MNcCY1osiRVwjt3J8CuFWqo/cVbLrzwLB+fxH5E2JCoTzyvV84J3PQO+K/67GD4Hv0CAAmTXp6a7
n2XRxSpUhQ9IBH+nttE8YQRAHmQZcmC3+wIDAQABo4GUMIGRMBIGA1UdEwEB/wQIMAYBAf8CAQAw
QwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybC50aGF3dGUuY29tL1RoYXd0ZVBlcnNvbmFsRnJl
ZW1haWxDQS5jcmwwCwYDVR0PBAQDAgEGMCkGA1UdEQQiMCCkHjAcMRowGAYDVQQDExFQcml2YXRl
TGFiZWwyLTEzODANBgkqhkiG9w0BAQUFAAOBgQBIjNFQg+oLLswNo2asZw9/r6y+whehQ5aUnX9M
Ibj4Nh+qLZ82L8D0HFAgk3A8/a3hYWLD2ToZfoSxmRsAxRoLgnSeJVCUYsfbJ3FXJY3dqZw5jowg
T2Vfldr394fWxghOrvbqNOUQGls1TXfjViF4gtwhGTXeJLHTHUb/XV9lTzGCAxAwggMMAgEBMHYw
YjELMAkGA1UEBhMCWkExJTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAq
BgNVBAMTI1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBAhAHY5N+rFym51Z9eUtP
6lKdMAkGBSsOAwIaBQCgggFvMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkF
MQ8XDTEwMDUwNjA2MTUwNFowIwYJKoZIhvcNAQkEMRYEFDzh7Pu56vgE5EYlPXpCaWVZJtDWMIGF
BgkrBgEEAYI3EAQxeDB2MGIxCzAJBgNVBAYTAlpBMSUwIwYDVQQKExxUaGF3dGUgQ29uc3VsdGlu
ZyAoUHR5KSBMdGQuMSwwKgYDVQQDEyNUaGF3dGUgUGVyc29uYWwgRnJlZW1haWwgSXNzdWluZyBD
QQIQB2OTfqxcpudWfXlLT+pSnTCBhwYLKoZIhvcNAQkQAgsxeKB2MGIxCzAJBgNVBAYTAlpBMSUw
IwYDVQQKExxUaGF3dGUgQ29uc3VsdGluZyAoUHR5KSBMdGQuMSwwKgYDVQQDEyNUaGF3dGUgUGVy
c29uYWwgRnJlZW1haWwgSXNzdWluZyBDQQIQB2OTfqxcpudWfXlLT+pSnTANBgkqhkiG9w0BAQEF
AASCAQDEDhrbL6jqNqpvexz8MKwta4hMjF4WiSVeGev1SycwByYnOZy4y5iq2BFt/ISERhs7Acct
swzsWRhDqYZUEIlo8kI+maYV8A56ScFa0pD9jD+yJpOH7ESDf5lPa6X9XEbu18myKPjouMiMtksi
wRXwqgwrOAOJrGOF5J3pkMrq4eT5AuuIm6Mpj4ntpUqx6ylqN8gzLGpDSfi9FdHZ1/g5P4bOVh3F
RP1SMN4YYtqhKUHWjBKjSbJNc+FXRPcT+/croJkDe8JUVaRnlB+kP7CB8iwY1HMHqwWANuQJxP0B
XPNvicbXTtpqfiffcsSoqCapjXrtyn7ERqgRU72KmEDQAAAAAAAA

--Apple-Mail-46-614044316--
