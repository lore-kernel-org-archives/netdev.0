From: Erik Slagter <erik@slagter.name>
Subject: stateless nat *please* tell me how I'm supposed to use it
Date: Mon, 16 May 2011 15:55:56 +0200
Message-ID: <4DD12CEC.1030801@slagter.name>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha1; boundary="------------ms030700020300030709010509"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eriks.xs4all.nl ([83.160.41.216]:45352 "EHLO eriks.xs4all.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755356Ab1EPOJr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2011 10:09:47 -0400
Received: from localhost (nemesis.ipv4.slagter.name [10.1.1.7])
	by nemesis.slagter.name (Postfix) with ESMTP id B0D634E03FB
	for <netdev@vger.kernel.org>; Mon, 16 May 2011 15:55:58 +0200 (CEST)
Received: from eriks.xs4all.nl ([10.1.1.7])
	by localhost (nemesis.slagter.name [10.1.1.7]) (amavisd-new, port 10025)
	with ESMTP id a40PV2tHuKet for <netdev@vger.kernel.org>;
	Mon, 16 May 2011 15:55:57 +0200 (CEST)
Received: from [10.128.0.226] (harp.wlz.nl [194.53.3.19])
	(using TLSv1 with cipher DHE-RSA-CAMELLIA256-SHA (256/256 bits))
	(Client CN "Erik Slagter", Issuer "UTN-USERFirst-Client Authentication and Email" (verified OK))
	(Authenticated sender: erik)
	by eriks.xs4all.nl (Postfix) with ESMTPSA
	for <netdev@vger.kernel.org>; Mon, 16 May 2011 15:55:57 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms030700020300030709010509
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello devs,

Normally I wouldn't dare to ask my question here, but really there is
nothing to be found that explains how to do this.

For a high availability router-cluster I need to do static nat. The only
thing it needs to do is replace a dst ipv4 address or a src ipv4
address, depending on src/dst host ip. It does not need to keep any
state / connection tracking etc. Actually I'd prefer to not have it
tracked. Both routers need to be able to take over routing from the
other at any given moment and therefore cannot transfer state
information to the other one.

These are the approaches I've tried and/or considered:

- use iptables stateful NAT in combination with a NOTRACK target:
doesn't work, as soon as a packet is marked NOTRACK, it doesn't get
NATted at all
- use iptables stateful NAT anyway and hope for the best: this kind of
works, but I am not happy with it
- use stateless nat from "ip route": abandoned because "deprecated"
- use "mangle" from iptables: doesn't work because you can't "mangle"
the addresses (which is kind of stupid imho)
- use conntrackd: that will probably work, but it's way too complex for
something simple I want to do.
- finally: use tc action nat as seem to be recommended of late.

Attempt 1: using "tc filter ... action nat ..." syntax.

# tc filter add dev eth0 parent root protocol ip prio 10 u32 match u32 0
0 action nat ingress 1.2.3.4 4.5.6.7
RTNETLINK answers: Invalid argument

This suggests that the construct is recognised by tc but the kernel
doesn't (fully) understand this. That's weird because devs said earlier
it should work from somewhere 2.6.29 onwards. I've added some printk's
to the act_nat.c file and that learns that this code isn't called at
all, so probably something else (rtnetlink?) already bails out. So...
this doesn't work.

Attempt 2: using "tc action" syntax

This syntax is not described anywere other than in the help, so I'm just
try-and-error-ing.

# tc action add nat egress 1.2.3.4 4.5.6.7

Now this works, well, it doesn't throw errors. It doesn't do anything
either. I guess this action needs to be called from a filter, other than
incorporating it INTO the filter (which doesn't work). There is no
syntax (described) that allows a filter to call an action indirectly.

So my question is, how am I supposed to do something that simple as
replacing a few bytes in an ip header with the effect of a stateless nat.=


Thanks very much.



--------------ms030700020300030709010509
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIPWDCC
BIowggNyoAMCAQICECf06hH0eobEbp27bqkXBwcwDQYJKoZIhvcNAQEFBQAwbzELMAkGA1UE
BhMCU0UxFDASBgNVBAoTC0FkZFRydXN0IEFCMSYwJAYDVQQLEx1BZGRUcnVzdCBFeHRlcm5h
bCBUVFAgTmV0d29yazEiMCAGA1UEAxMZQWRkVHJ1c3QgRXh0ZXJuYWwgQ0EgUm9vdDAeFw0w
NTA2MDcwODA5MTBaFw0yMDA1MzAxMDQ4MzhaMIGuMQswCQYDVQQGEwJVUzELMAkGA1UECBMC
VVQxFzAVBgNVBAcTDlNhbHQgTGFrZSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNUIE5l
dHdvcmsxITAfBgNVBAsTGGh0dHA6Ly93d3cudXNlcnRydXN0LmNvbTE2MDQGA1UEAxMtVVRO
LVVTRVJGaXJzdC1DbGllbnQgQXV0aGVudGljYXRpb24gYW5kIEVtYWlsMIIBIjANBgkqhkiG
9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsjmFpPJ9q0E7YkY3rs3BYHW8OWX5ShpHornMSMxqmNVN
NRm5pELlzkniii8efNIxB8dOtINknS4p1aJkxIW9hVE1eaROaJB7HHqkkqgX8pgV8pPMyaQy
lbsMTzC9mKALi+VuG6JG+ni8om+rWV6lL8/K2m2qL+usobNqqrcuZzWLeeEeaYji5kbNoKXq
vgvOdjp6Dpvq/NonWz1zHyLmSGHGTPNpsaguG7bUMSAsvIKKjqQOpdeJQ/wWWq8dcdcRWdq6
hw2v+vPhwvCkxWeM1tZUOt4KpLoDd7NlyP0e03RiqhjKaJMeoYV+9Udly/hNVyh00jT/MLbu
9mIwFIws6wIDAQABo4HhMIHeMB8GA1UdIwQYMBaAFK29mHo0tCb3+sQmVO8DveAky1QaMB0G
A1UdDgQWBBSJgmd9xJ0mcABLtFBIfN49rgRufTAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/
BAUwAwEB/zB7BgNVHR8EdDByMDigNqA0hjJodHRwOi8vY3JsLmNvbW9kb2NhLmNvbS9BZGRU
cnVzdEV4dGVybmFsQ0FSb290LmNybDA2oDSgMoYwaHR0cDovL2NybC5jb21vZG8ubmV0L0Fk
ZFRydXN0RXh0ZXJuYWxDQVJvb3QuY3JsMA0GCSqGSIb3DQEBBQUAA4IBAQAZ2IkRbyispgCi
54fBm5AD236hEv0e8+LwAamUVEJrmgnEoG3XkJIEA2Z5Q3H8+G+v23ZF4jcaPd3kWQR4rBz0
g0bzes9bhHIt5UbBuhgRKfPLSXmHPLptBZ2kbWhPrXIUNqi5sf2/z3/wpGqUNVCPz4FtVbHd
WTBK322gnGQfSXzvNrv042n0+DmPWq1LhTq3Du3Tzw1EovsEv+QvcI4l+1pUBrPQxLxtjftz
Mizpm4QkLdZ/kXpoAlAfDj9N6cz1u2fo3BwuO/xOzf4CjuOoEwqlJkRl6RDyTVKnrtw+ymsy
XEFs/vVdoOr/0fqbhlhtPZZH5f4ulQTCAMyOofK7MIIFYTCCBEmgAwIBAgIRAIg14yiGxBLB
Nd3nEhie2VcwDQYJKoZIhvcNAQEFBQAwga4xCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJVVDEX
MBUGA1UEBxMOU2FsdCBMYWtlIENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1QgTmV0d29y
azEhMB8GA1UECxMYaHR0cDovL3d3dy51c2VydHJ1c3QuY29tMTYwNAYDVQQDEy1VVE4tVVNF
UkZpcnN0LUNsaWVudCBBdXRoZW50aWNhdGlvbiBhbmQgRW1haWwwHhcNMTAxMDE5MDAwMDAw
WhcNMTExMDE5MjM1OTU5WjBGMQswCQYDVQQGEwJOTDEVMBMGA1UEAxMMRXJpayBTbGFndGVy
MSAwHgYJKoZIhvcNAQkBFhFlcmlrQHNsYWd0ZXIubmFtZTCCASIwDQYJKoZIhvcNAQEBBQAD
ggEPADCCAQoCggEBANbriwH0w2kwn4b2BwVAtiZ0OkHIiwcscx1XIOzD/bp+Sv4tVdjc2bBF
tXTyEpDzP5cLs5V3g1hTxI5V40lgmsiKrDMp8XR6fDwqv0cdoS3ABS/gvlxhwvbJaeR7tjkM
Ni4ofKgEfSWi7hzFyijuwM/SrwJVlpTO7Xah+FKDLVh8FWUHRVxtnFuLaHcZR+4y0c0Zi2AE
gp3CLZQzXCsu/Nsi+0fclP4lbhg+XgAgTKDI2WIm7JuQgMSgoevQ6HFggreTj03tUoKjD4l4
JIoDb5tc/IutLhwXZTZsrdmW2SE29xhRWauNGs9DnJAcmpUJkXHGGL8cgmqWb1Mlh9JBaN8C
AwEAAaOCAd8wggHbMB8GA1UdIwQYMBaAFImCZ33EnSZwAEu0UEh83j2uBG59MB0GA1UdDgQW
BBTK4wFgfa4mmdF0XOGvj3dgyG8ePzAOBgNVHQ8BAf8EBAMCBaAwDAYDVR0TAQH/BAIwADAd
BgNVHSUEFjAUBggrBgEFBQcDBAYIKwYBBQUHAwIwRgYDVR0gBD8wPTA7BgwrBgEEAbIxAQIB
AwUwKzApBggrBgEFBQcCARYdaHR0cHM6Ly9zZWN1cmUuY29tb2RvLm5ldC9DUFMwgaUGA1Ud
HwSBnTCBmjBMoEqgSIZGaHR0cDovL2NybC5jb21vZG9jYS5jb20vVVROLVVTRVJGaXJzdC1D
bGllbnRBdXRoZW50aWNhdGlvbmFuZEVtYWlsLmNybDBKoEigRoZEaHR0cDovL2NybC5jb21v
ZG8ubmV0L1VUTi1VU0VSRmlyc3QtQ2xpZW50QXV0aGVudGljYXRpb25hbmRFbWFpbC5jcmww
bAYIKwYBBQUHAQEEYDBeMDYGCCsGAQUFBzAChipodHRwOi8vY3J0LmNvbW9kb2NhLmNvbS9V
VE5BQUFDbGllbnRDQS5jcnQwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNv
bTANBgkqhkiG9w0BAQUFAAOCAQEAALQg8UqA2KoLGSmq8SsJTddYzpglJrW3mcd55qDBKLBM
J5klHPPWoqdV2dA9X0yV4WlaS/eQHfgmQCjvJ42HDNJW6YBw1MrPFPxXFJsbpY0OlIeLY5oh
VZjuQeI3YfwOB1ZceU4QTkdF636Ljyz3D++PmSw6ww6mm8R8LX18JIYe6vhWZs93sSMQct3R
2s9kGB94lCKbapyq9lBhT/swM51wWTmnrIxrmFzm0+fFnNu9QwoazTn7hwg7G0Tiv2Zqz+Ba
x318aG+gZm1OnQQRPn1hiK5C6GiKrWu9/jTV3UaGePBGslkpopMdLrwQ43P/eHmJJGyXHBLx
87J7yN8HMzCCBWEwggRJoAMCAQICEQCINeMohsQSwTXd5xIYntlXMA0GCSqGSIb3DQEBBQUA
MIGuMQswCQYDVQQGEwJVUzELMAkGA1UECBMCVVQxFzAVBgNVBAcTDlNhbHQgTGFrZSBDaXR5
MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNUIE5ldHdvcmsxITAfBgNVBAsTGGh0dHA6Ly93d3cu
dXNlcnRydXN0LmNvbTE2MDQGA1UEAxMtVVROLVVTRVJGaXJzdC1DbGllbnQgQXV0aGVudGlj
YXRpb24gYW5kIEVtYWlsMB4XDTEwMTAxOTAwMDAwMFoXDTExMTAxOTIzNTk1OVowRjELMAkG
A1UEBhMCTkwxFTATBgNVBAMTDEVyaWsgU2xhZ3RlcjEgMB4GCSqGSIb3DQEJARYRZXJpa0Bz
bGFndGVyLm5hbWUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDW64sB9MNpMJ+G
9gcFQLYmdDpByIsHLHMdVyDsw/26fkr+LVXY3NmwRbV08hKQ8z+XC7OVd4NYU8SOVeNJYJrI
iqwzKfF0enw8Kr9HHaEtwAUv4L5cYcL2yWnke7Y5DDYuKHyoBH0lou4cxcoo7sDP0q8CVZaU
zu12ofhSgy1YfBVlB0VcbZxbi2h3GUfuMtHNGYtgBIKdwi2UM1wrLvzbIvtH3JT+JW4YPl4A
IEygyNliJuybkIDEoKHr0OhxYIK3k49N7VKCow+JeCSKA2+bXPyLrS4cF2U2bK3ZltkhNvcY
UVmrjRrPQ5yQHJqVCZFxxhi/HIJqlm9TJYfSQWjfAgMBAAGjggHfMIIB2zAfBgNVHSMEGDAW
gBSJgmd9xJ0mcABLtFBIfN49rgRufTAdBgNVHQ4EFgQUyuMBYH2uJpnRdFzhr493YMhvHj8w
DgYDVR0PAQH/BAQDAgWgMAwGA1UdEwEB/wQCMAAwHQYDVR0lBBYwFAYIKwYBBQUHAwQGCCsG
AQUFBwMCMEYGA1UdIAQ/MD0wOwYMKwYBBAGyMQECAQMFMCswKQYIKwYBBQUHAgEWHWh0dHBz
Oi8vc2VjdXJlLmNvbW9kby5uZXQvQ1BTMIGlBgNVHR8EgZ0wgZowTKBKoEiGRmh0dHA6Ly9j
cmwuY29tb2RvY2EuY29tL1VUTi1VU0VSRmlyc3QtQ2xpZW50QXV0aGVudGljYXRpb25hbmRF
bWFpbC5jcmwwSqBIoEaGRGh0dHA6Ly9jcmwuY29tb2RvLm5ldC9VVE4tVVNFUkZpcnN0LUNs
aWVudEF1dGhlbnRpY2F0aW9uYW5kRW1haWwuY3JsMGwGCCsGAQUFBwEBBGAwXjA2BggrBgEF
BQcwAoYqaHR0cDovL2NydC5jb21vZG9jYS5jb20vVVROQUFBQ2xpZW50Q0EuY3J0MCQGCCsG
AQUFBzABhhhodHRwOi8vb2NzcC5jb21vZG9jYS5jb20wDQYJKoZIhvcNAQEFBQADggEBAAC0
IPFKgNiqCxkpqvErCU3XWM6YJSa1t5nHeeagwSiwTCeZJRzz1qKnVdnQPV9MleFpWkv3kB34
JkAo7yeNhwzSVumAcNTKzxT8VxSbG6WNDpSHi2OaIVWY7kHiN2H8DgdWXHlOEE5HRet+i48s
9w/vj5ksOsMOppvEfC19fCSGHur4VmbPd7EjEHLd0drPZBgfeJQim2qcqvZQYU/7MDOdcFk5
p6yMa5hc5tPnxZzbvUMKGs05+4cIOxtE4r9mas/gWsd9fGhvoGZtTp0EET59YYiuQuhoiq1r
vf401d1GhnjwRrJZKaKTHS68EONz/3h5iSRslxwS8fOye8jfBzMxggRgMIIEXAIBATCBxDCB
rjELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAlVUMRcwFQYDVQQHEw5TYWx0IExha2UgQ2l0eTEe
MBwGA1UEChMVVGhlIFVTRVJUUlVTVCBOZXR3b3JrMSEwHwYDVQQLExhodHRwOi8vd3d3LnVz
ZXJ0cnVzdC5jb20xNjA0BgNVBAMTLVVUTi1VU0VSRmlyc3QtQ2xpZW50IEF1dGhlbnRpY2F0
aW9uIGFuZCBFbWFpbAIRAIg14yiGxBLBNd3nEhie2VcwCQYFKw4DAhoFAKCCAnAwGAYJKoZI
hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTEwNTE2MTM1NTU2WjAjBgkq
hkiG9w0BCQQxFgQUILGCEIdWjDZqVONq6A+duy6DwoYwXwYJKoZIhvcNAQkPMVIwUDALBglg
hkgBZQMEAQIwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFAMAcG
BSsOAwIHMA0GCCqGSIb3DQMCAgEoMIHVBgkrBgEEAYI3EAQxgccwgcQwga4xCzAJBgNVBAYT
AlVTMQswCQYDVQQIEwJVVDEXMBUGA1UEBxMOU2FsdCBMYWtlIENpdHkxHjAcBgNVBAoTFVRo
ZSBVU0VSVFJVU1QgTmV0d29yazEhMB8GA1UECxMYaHR0cDovL3d3dy51c2VydHJ1c3QuY29t
MTYwNAYDVQQDEy1VVE4tVVNFUkZpcnN0LUNsaWVudCBBdXRoZW50aWNhdGlvbiBhbmQgRW1h
aWwCEQCINeMohsQSwTXd5xIYntlXMIHXBgsqhkiG9w0BCRACCzGBx6CBxDCBrjELMAkGA1UE
BhMCVVMxCzAJBgNVBAgTAlVUMRcwFQYDVQQHEw5TYWx0IExha2UgQ2l0eTEeMBwGA1UEChMV
VGhlIFVTRVJUUlVTVCBOZXR3b3JrMSEwHwYDVQQLExhodHRwOi8vd3d3LnVzZXJ0cnVzdC5j
b20xNjA0BgNVBAMTLVVUTi1VU0VSRmlyc3QtQ2xpZW50IEF1dGhlbnRpY2F0aW9uIGFuZCBF
bWFpbAIRAIg14yiGxBLBNd3nEhie2VcwDQYJKoZIhvcNAQEBBQAEggEAkbAkrLF3ERmLPwXt
9ixbP4jij47XORketiqoH3EU6Uwl/xPyYLUlkfcBrdYv5feDgdJGuJpWbwCSRwNlGLAfTd6v
NeWHbglBNuD8CtUslMb7HvIzNzaHY3wTsEvC9QW4564AszC4igPn9UFltdBvQi3bRphIJYHm
XjXsdP6Q05Uf/Zl1zM8dJnlkeUFtg5uW3TfSkDdwO31WUt4Ld0Rzp6eKOD86E0iiDX/XJ1Jg
vttQBsqhiNqKoDM1zPEZzVr+o3eX6XvliPpJIUXN9JjLRtK8eXEZ/bR51xdntEcvFwnSh8+G
S465EKA/ihvLIlPGccSrUHdRweohUMAXiJYjcAAAAAAAAA==
--------------ms030700020300030709010509--
