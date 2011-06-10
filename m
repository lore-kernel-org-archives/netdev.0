From: Charles Bearden <Charles.F.Bearden@uth.tmc.edu>
Subject: Re: TCP keepalives ignored by kernel when the contain timestamps
Date: Fri, 10 Jun 2011 10:10:06 -0500
Message-ID: <4DF233CE.5020000@uth.tmc.edu>
References: <4DF0E638.2010506@uth.tmc.edu> <1307714177.4044.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature";
	micalg=sha1; boundary="------------ms090003040806010504010909"
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta4.uth.tmc.edu ([129.106.163.140]:54329 "EHLO
	mta4.uth.tmc.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757593Ab1FJPTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 11:19:38 -0400
In-Reply-To: <1307714177.4044.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------ms090003040806010504010909
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable

On 06/10/2011 08:56 AM, Eric Dumazet wrote:
> Le jeudi 09 juin 2011 =C3=A0 10:26 -0500, Charles Bearden a =C3=A9crit =
:
>> I have come across a case that looks like it might be a kernel bug. It=
 appears
>> that tcp keepalives sent by a remote system are ignored when they cont=
ain tcp
>> timestamps, but are ACKed when they don't. When they are ignored, the =
remote
>> system resets the connection after a number of retries.
>>
>> I have replicated this problem on both Ubuntu 10.04 with a 2.6.32-32-s=
erver
>> kernel (x86_64) and CentOS 5.6 with a 2.6.18-238.12.1.el5 kernel. I'm =
sorry that
>> I haven't had a chance to try to replicate the bug with a newer kernel=
, though a
>> co-worker has looked through changelogs for more recent kernels and di=
dn't find
>> anything that looked relevant.
>>
>>   From either of these hosts I run an application that connects to a r=
emote host
>> for 2-3 minutes, and that for most of that time sends no application d=
ata back
>> and forth. After 30 seconds of no data from the Linux host, the remote=
 host
>> sends a garden variety keepalive. When the remote host includes tcp ti=
mestamps
>> in the keepalives, they are ignored by the Linux host, and the remote =
host
>> resets the connection after 10 unACKed keepalives. When timestamps are=
 absent
>> from the keepalives, the Linux host ACKs each one, and all is copaceti=
c.
>>
>> Text output of a tcpdump trace of a connection that fails:
>>     http://pastebin.com/v6CpteJ9
>>
>> Text output of a tcpdump trace of a connection that succeeds:
>>     http://pastebin.com/KVLb3Mzh
>>
>> More details, in case you think they are relevant:
>>
>>     My application creates a JDBC connection to a remote MS SQL Server=
 and
>>     executes a statement that does not return a result set, and so it =
doesn't
>>     need to pass application data back and forth while it executes. Th=
e
>>     statement takes 2 or 3 minutes to complete. I connect to two diffe=
rent
>>     remote hosts: a Win2003 machine, and a Win2008R2 machine. The Win2=
003
>>     machine doesn't put timestamps in its keep-alives, so the applicat=
ion
>>     completes successfully when connecting to that host. If tcp timest=
amps
>>     are enabled on the Linux host, the Win2008 host includes them in i=
ts
>>     keepalives, and they are unACKed, so the connection is reset; if t=
hey
>>     are disabled on the Linux host, the Win2008 host doesn't include t=
hem in
>>     the keepalives, and the application completes successfully. I use =
(as
>>     you might expect) sysctl to disable tcp timestamps on the Linux ho=
sts.
>>
>> I have dumps for all permutations of CentOS/Ubuntu, Win200[38], and +/=
-
>> timestamps on the Linux side, and I will post them if the developers t=
hink that
>> they would be useful.
>
> Hi Charles
>
> I could not reproduce the problem here, even using a quite old kernel a=
s
> receiver (2.6.9)
>
> 15:54:33.566192 IP 192.168.20.108.55926>  192.168.20.124.777: SWE
> 479814493:479814493(0) win 14600<mss 1460,sackOK,timestamp 151666
> 0,nop,wscale 7>
> 15:54:33.566265 IP 192.168.20.124.777>  192.168.20.108.55926: S
> 3714869381:3714869381(0) ack 479814494 win 5792<mss
> 1460,sackOK,timestamp 54553041 151666,nop,wscale 2>
> 15:54:33.566274 IP 192.168.20.108.55926>  192.168.20.124.777: . ack 1
> win 115<nop,nop,timestamp 151666 54553041>
> 15:54:33.566281 IP 192.168.20.108.55926>  192.168.20.124.777: P 1:5(4)
> ack 1 win 115<nop,nop,timestamp 151666 54553041>
> 15:54:33.566351 IP 192.168.20.124.777>  192.168.20.108.55926: . ack 5
> win 1448<nop,nop,timestamp 54553041 151666>
> 15:54:33.566375 IP 192.168.20.124.777>  192.168.20.108.55926: P 1:5(4)
> ack 5 win 1448<nop,nop,timestamp 54553041 151666>
> 15:54:33.566380 IP 192.168.20.108.55926>  192.168.20.124.777: . ack 5
> win 115<nop,nop,timestamp 151666 54553041>
> 15:54:43.577945 IP 192.168.20.108.55926>  192.168.20.124.777: . 4:5(1)
> ack 5 win 115<nop,nop,timestamp 152668 54553041>
> 15:54:43.578012 IP 192.168.20.124.777>  192.168.20.108.55926: . ack 5
> win 1448<nop,nop,timestamp 54563053 152668,nop,nop,sack sack 1 {4:5}>
> 15:54:53.597946 IP 192.168.20.108.55926>  192.168.20.124.777: . 4:5(1)
> ack 5 win 115<nop,nop,timestamp 153670 54563053>
> 15:54:53.598012 IP 192.168.20.124.777>  192.168.20.108.55926: . ack 5
> win 1448<nop,nop,timestamp 54573073 153670,nop,nop,sack sack 1 {4:5}>
>
>
> Are you sure frame tcp checksums are OK when the 'faulty' linux receive=

> them ?   (tcpdump -v)

I will check when I get into the office and let you know.


--------------ms090003040806010504010909
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIOkjCC
A/AwggNZoAMCAQICECvsJV556vX0vt2D0bDTS1EwDQYJKoZIhvcNAQEFBQAwgcExCzAJBgNV
BAYTAlVTMRcwFQYDVQQKEw5WZXJpU2lnbiwgSW5jLjE8MDoGA1UECxMzQ2xhc3MgMiBQdWJs
aWMgUHJpbWFyeSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eSAtIEcyMTowOAYDVQQLEzEoYykg
MTk5OCBWZXJpU2lnbiwgSW5jLiAtIEZvciBhdXRob3JpemVkIHVzZSBvbmx5MR8wHQYDVQQL
ExZWZXJpU2lnbiBUcnVzdCBOZXR3b3JrMB4XDTk5MDMzMTAwMDAwMFoXDTEyMDMzMDIzNTk1
OVowggEBMScwJQYDVQQKEx5UaGUgVW5pdmVyc2l0eSBvZiBUZXhhcyBTeXN0ZW0xHzAdBgNV
BAsTFlZlcmlTaWduIFRydXN0IE5ldHdvcmsxOzA5BgNVBAsTMlRlcm1zIG9mIHVzZSBhdCBo
dHRwczovL3d3dy52ZXJpc2lnbi5jb20vcnBhIChjKTk5MTIwMAYDVQQLEylDbGFzcyAyIENB
IC0gT25TaXRlIEluZGl2aWR1YWwgU3Vic2NyaWJlcjFEMEIGA1UEAxM7VGhlIFVuaXZlcnNp
dHkgb2YgVGV4YXMgSGVhbHRoIFNjaWVuY2UgQ2VudGVyIGF0IEhvdXN0b24gQ0EwgZ8wDQYJ
KoZIhvcNAQEBBQADgY0AMIGJAoGBAMYZu7ND40kLWbOvYuQPb8PFktqYhTIXhsUC6+ORnSLB
JBjGbM9kh17samWncixNITwgkX/nfuvY6Mw/jEIGjs+0TNYdxYrcJBc23FLrMRgXSngtiYAY
gVI4e6kqo8sMHV93Wbpgb/dXYS9ZKenjgBv9KbGILA7+5GXNyS++j7TrAgMBAAGjgaUwgaIw
KQYDVR0RBCIwIKQeMBwxGjAYBgNVBAMTEVByaXZhdGVMYWJlbDEtMTQyMBEGCWCGSAGG+EIB
AQQEAwIBBjBEBgNVHSAEPTA7MDkGC2CGSAGG+EUBBwEBMCowKAYIKwYBBQUHAgEWHGh0dHBz
Oi8vd3d3LnZlcmlzaWduLmNvbS9SUEEwDwYDVR0TBAgwBgEB/wIBADALBgNVHQ8EBAMCAQYw
DQYJKoZIhvcNAQEFBQADgYEAXGsbxBJsSYJvZ0JXPkrU13f1i6bGO2O0+065rXqaqkGxYxR9
Ny+i5ULa/g3wzwgp6Ma+3mASenj5TaOoqET50A8+b+iDaLnoikznZPyIc88KFNXjj++fR7Ti
cC0OmFevQ6Kv88bgBDXojh4FnckSQdmaUIGzlHPCYdnUqsgIfWgwggVLMIIEtKADAgECAhA1
0JQhDLEDoEunhjpaAPiuMA0GCSqGSIb3DQEBBQUAMIIBATEnMCUGA1UEChMeVGhlIFVuaXZl
cnNpdHkgb2YgVGV4YXMgU3lzdGVtMR8wHQYDVQQLExZWZXJpU2lnbiBUcnVzdCBOZXR3b3Jr
MTswOQYDVQQLEzJUZXJtcyBvZiB1c2UgYXQgaHR0cHM6Ly93d3cudmVyaXNpZ24uY29tL3Jw
YSAoYyk5OTEyMDAGA1UECxMpQ2xhc3MgMiBDQSAtIE9uU2l0ZSBJbmRpdmlkdWFsIFN1YnNj
cmliZXIxRDBCBgNVBAMTO1RoZSBVbml2ZXJzaXR5IG9mIFRleGFzIEhlYWx0aCBTY2llbmNl
IENlbnRlciBhdCBIb3VzdG9uIENBMB4XDTEwMDcxNTAwMDAwMFoXDTExMDcxNTIzNTk1OVow
gecxJzAlBgNVBAoUHlRoZSBVbml2ZXJzaXR5IG9mIFRleGFzIFN5c3RlbTEsMCoGA1UECxQj
SGVhbHRoIFNjaWVuY2UgQ2VudGVyIGF0IEhvdXN0b24gQ0ExRjBEBgNVBAsTPXd3dy52ZXJp
c2lnbi5jb20vcmVwb3NpdG9yeS9DUFMgSW5jb3JwLiBieSBSZWYuLExJQUIuTFREKGMpOTkx
GDAWBgNVBAMTD0NoYXJsZXMgQmVhcmRlbjEsMCoGCSqGSIb3DQEJARYdY2hhcmxlcy5mLmJl
YXJkZW5AdXRoLnRtYy5lZHUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDL6PEn
8JW2sJ816agItdzWFdWpy4n2J+5HApDX4Nvm0F/TumWPVe6DVg7MLMl9pHqD2Eca5NwxC5iW
r/ft+j7CxNDc/xxUEb4yHrQXAJmYteUoAn0DPDrmhM/8amCM3zHKNZCHcUm5k+FehpSqTrdZ
ydJHLLpQUF2Jf+/r5uNj3pLR3vCkZUY/OT48NJEkIemYzo0Y/4ZTicDF+D0c0h9l5NdSt6/5
u+lNi8igNzxj23lT4Mo4QT2IUaCZKloyYtL3QFGPR6MyyZ4pKPzHgeqSiS2CcNFLKKxADo4z
pJT/jdNSL1ag1KnErQoOPjcaQLqvm2Y0kF4qn3Db2tU0CVzRAgMBAAGjggFVMIIBUTAJBgNV
HRMEAjAAMIGsBgNVHSAEgaQwgaEwgZ4GC2CGSAGG+EUBBwEBMIGOMCgGCCsGAQUFBwIBFhxo
dHRwczovL3d3dy52ZXJpc2lnbi5jb20vQ1BTMGIGCCsGAQUFBwICMFYwFRYOVmVyaVNpZ24s
IEluYy4wAwIBARo9VmVyaVNpZ24ncyBDUFMgaW5jb3JwLiBieSByZWZlcmVuY2UgbGlhYi4g
bHRkLiAoYyk5NyBWZXJpU2lnbjALBgNVHQ8EBAMCBaAwEQYJYIZIAYb4QgEBBAQDAgeAMHUG
A1UdHwRuMGwwaqBooGaGZGh0dHA6Ly9vbnNpdGVjcmwudmVyaXNpZ24uY29tL1RoZVVuaXZl
cnNpdHlvZlRleGFzU3lzdGVtSGVhbHRoU2NpZW5jZUNlbnRlcmF0SG91c3RvbkNBL0xhdGVz
dENSTC5jcmwwDQYJKoZIhvcNAQEFBQADgYEACj42pCEmLRqHsiyuy4H5mIPMzZKM7YuwJpyq
p/hfb6Mctj2AeUUHSEKqkJmcN5X0FuuS9dnaPyzeQO0Ivp+ePw9Bj4jjRE0vS68lw4a7dOzQ
VmJmjzpatJHnMdYRY9Tvfo/xMaW4qakSVLchqNMLRD61a6k9fKaY/3H31dqmaI0wggVLMIIE
tKADAgECAhA10JQhDLEDoEunhjpaAPiuMA0GCSqGSIb3DQEBBQUAMIIBATEnMCUGA1UEChMe
VGhlIFVuaXZlcnNpdHkgb2YgVGV4YXMgU3lzdGVtMR8wHQYDVQQLExZWZXJpU2lnbiBUcnVz
dCBOZXR3b3JrMTswOQYDVQQLEzJUZXJtcyBvZiB1c2UgYXQgaHR0cHM6Ly93d3cudmVyaXNp
Z24uY29tL3JwYSAoYyk5OTEyMDAGA1UECxMpQ2xhc3MgMiBDQSAtIE9uU2l0ZSBJbmRpdmlk
dWFsIFN1YnNjcmliZXIxRDBCBgNVBAMTO1RoZSBVbml2ZXJzaXR5IG9mIFRleGFzIEhlYWx0
aCBTY2llbmNlIENlbnRlciBhdCBIb3VzdG9uIENBMB4XDTEwMDcxNTAwMDAwMFoXDTExMDcx
NTIzNTk1OVowgecxJzAlBgNVBAoUHlRoZSBVbml2ZXJzaXR5IG9mIFRleGFzIFN5c3RlbTEs
MCoGA1UECxQjSGVhbHRoIFNjaWVuY2UgQ2VudGVyIGF0IEhvdXN0b24gQ0ExRjBEBgNVBAsT
PXd3dy52ZXJpc2lnbi5jb20vcmVwb3NpdG9yeS9DUFMgSW5jb3JwLiBieSBSZWYuLExJQUIu
TFREKGMpOTkxGDAWBgNVBAMTD0NoYXJsZXMgQmVhcmRlbjEsMCoGCSqGSIb3DQEJARYdY2hh
cmxlcy5mLmJlYXJkZW5AdXRoLnRtYy5lZHUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
AoIBAQDL6PEn8JW2sJ816agItdzWFdWpy4n2J+5HApDX4Nvm0F/TumWPVe6DVg7MLMl9pHqD
2Eca5NwxC5iWr/ft+j7CxNDc/xxUEb4yHrQXAJmYteUoAn0DPDrmhM/8amCM3zHKNZCHcUm5
k+FehpSqTrdZydJHLLpQUF2Jf+/r5uNj3pLR3vCkZUY/OT48NJEkIemYzo0Y/4ZTicDF+D0c
0h9l5NdSt6/5u+lNi8igNzxj23lT4Mo4QT2IUaCZKloyYtL3QFGPR6MyyZ4pKPzHgeqSiS2C
cNFLKKxADo4zpJT/jdNSL1ag1KnErQoOPjcaQLqvm2Y0kF4qn3Db2tU0CVzRAgMBAAGjggFV
MIIBUTAJBgNVHRMEAjAAMIGsBgNVHSAEgaQwgaEwgZ4GC2CGSAGG+EUBBwEBMIGOMCgGCCsG
AQUFBwIBFhxodHRwczovL3d3dy52ZXJpc2lnbi5jb20vQ1BTMGIGCCsGAQUFBwICMFYwFRYO
VmVyaVNpZ24sIEluYy4wAwIBARo9VmVyaVNpZ24ncyBDUFMgaW5jb3JwLiBieSByZWZlcmVu
Y2UgbGlhYi4gbHRkLiAoYyk5NyBWZXJpU2lnbjALBgNVHQ8EBAMCBaAwEQYJYIZIAYb4QgEB
BAQDAgeAMHUGA1UdHwRuMGwwaqBooGaGZGh0dHA6Ly9vbnNpdGVjcmwudmVyaXNpZ24uY29t
L1RoZVVuaXZlcnNpdHlvZlRleGFzU3lzdGVtSGVhbHRoU2NpZW5jZUNlbnRlcmF0SG91c3Rv
bkNBL0xhdGVzdENSTC5jcmwwDQYJKoZIhvcNAQEFBQADgYEACj42pCEmLRqHsiyuy4H5mIPM
zZKM7YuwJpyqp/hfb6Mctj2AeUUHSEKqkJmcN5X0FuuS9dnaPyzeQO0Ivp+ePw9Bj4jjRE0v
S68lw4a7dOzQVmJmjzpatJHnMdYRY9Tvfo/xMaW4qakSVLchqNMLRD61a6k9fKaY/3H31dqm
aI0xggVgMIIFXAIBATCCARcwggEBMScwJQYDVQQKEx5UaGUgVW5pdmVyc2l0eSBvZiBUZXhh
cyBTeXN0ZW0xHzAdBgNVBAsTFlZlcmlTaWduIFRydXN0IE5ldHdvcmsxOzA5BgNVBAsTMlRl
cm1zIG9mIHVzZSBhdCBodHRwczovL3d3dy52ZXJpc2lnbi5jb20vcnBhIChjKTk5MTIwMAYD
VQQLEylDbGFzcyAyIENBIC0gT25TaXRlIEluZGl2aWR1YWwgU3Vic2NyaWJlcjFEMEIGA1UE
AxM7VGhlIFVuaXZlcnNpdHkgb2YgVGV4YXMgSGVhbHRoIFNjaWVuY2UgQ2VudGVyIGF0IEhv
dXN0b24gQ0ECEDXQlCEMsQOgS6eGOloA+K4wCQYFKw4DAhoFAKCCAxwwGAYJKoZIhvcNAQkD
MQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTEwNjEwMTUxMDA2WjAjBgkqhkiG9w0B
CQQxFgQUJnkQr2Td+lOdlSUL40gDsxvBA/AwXwYJKoZIhvcNAQkPMVIwUDALBglghkgBZQME
AQIwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFAMAcGBSsOAwIH
MA0GCCqGSIb3DQMCAgEoMIIBKgYJKwYBBAGCNxAEMYIBGzCCARcwggEBMScwJQYDVQQKEx5U
aGUgVW5pdmVyc2l0eSBvZiBUZXhhcyBTeXN0ZW0xHzAdBgNVBAsTFlZlcmlTaWduIFRydXN0
IE5ldHdvcmsxOzA5BgNVBAsTMlRlcm1zIG9mIHVzZSBhdCBodHRwczovL3d3dy52ZXJpc2ln
bi5jb20vcnBhIChjKTk5MTIwMAYDVQQLEylDbGFzcyAyIENBIC0gT25TaXRlIEluZGl2aWR1
YWwgU3Vic2NyaWJlcjFEMEIGA1UEAxM7VGhlIFVuaXZlcnNpdHkgb2YgVGV4YXMgSGVhbHRo
IFNjaWVuY2UgQ2VudGVyIGF0IEhvdXN0b24gQ0ECEDXQlCEMsQOgS6eGOloA+K4wggEsBgsq
hkiG9w0BCRACCzGCARugggEXMIIBATEnMCUGA1UEChMeVGhlIFVuaXZlcnNpdHkgb2YgVGV4
YXMgU3lzdGVtMR8wHQYDVQQLExZWZXJpU2lnbiBUcnVzdCBOZXR3b3JrMTswOQYDVQQLEzJU
ZXJtcyBvZiB1c2UgYXQgaHR0cHM6Ly93d3cudmVyaXNpZ24uY29tL3JwYSAoYyk5OTEyMDAG
A1UECxMpQ2xhc3MgMiBDQSAtIE9uU2l0ZSBJbmRpdmlkdWFsIFN1YnNjcmliZXIxRDBCBgNV
BAMTO1RoZSBVbml2ZXJzaXR5IG9mIFRleGFzIEhlYWx0aCBTY2llbmNlIENlbnRlciBhdCBI
b3VzdG9uIENBAhA10JQhDLEDoEunhjpaAPiuMA0GCSqGSIb3DQEBAQUABIIBAAIIUJCp9DBU
OlpGYHjuhhtpXqpwEseOo2I8igBsOMm5UT6ib0vN4hTLgYvqrcBug0vWdKd/B1sNaqz4N6Vg
y36c/3WDoNG4DMcmulCFz0QKoCgwrhcyKnUBhxKZYeRp4xZ1pRe2z3Nto3EPFEHfSsxD852B
ocve3+AUX8FBhiVJ1IFb8qmSv5c1mUEMczp0T8NMjTPX10sDUwZcr1+faKM80yUGzhbE5QzK
ESN0L6JDNV65GO24FRRPEZZWpY4P/+Gl4woY9KKe5eu6yDIAVJLy5nPwtax+ln2SuE6evJI0
3vBgmFHjhZO9fLzZWRoiFvISNM61J3J5PbO4yKuTcUAAAAAAAAA=
--------------ms090003040806010504010909--
