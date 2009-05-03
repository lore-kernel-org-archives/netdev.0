From: "Jann Traschewski" <jann@gmx.de>
Subject: [BUG][AX25] 2.6.28.5 "inconsistent lock state" (2 CPUs / SMP enabled)
Date: Sun, 3 May 2009 10:06:23 +0200
Message-ID: <4152EA8442834D52AA9C100377B9ABE2@A050313B>
Mime-Version: 1.0
Content-Type: multipart/signed;
	protocol="application/x-pkcs7-signature";
	micalg=SHA1;
	boundary="----=_NextPart_000_0009_01C9CBD6.CF44EB10"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:45963 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754234AbZECIGf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 May 2009 04:06:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

------=_NextPart_000_0009_01C9CBD6.CF44EB10
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

the AX.25 code has still some problems with SMP and locking. I turned on
lock debugging on my machine with a lot of AX.25 traffic. Although it did
take serveral days until I got this:

=================================
[ INFO: inconsistent lock state ]
2.6.28.5-dg8ngn #1
---------------------------------
inconsistent {softirq-on-R} -> {in-softirq-W} usage.
swapper/0 [HC0[0]:SC1[2]:HE1:SE0] takes:
 (clock-AF_AX25){-+-?}, at: [<f859ed33>] ax25_destroy_socket+0xb6/0x1c4
[ax25]
{softirq-on-R} state was registered at:
  [<c013a751>] __lock_acquire+0x4e4/0x65e
  [<c0124d14>] local_bh_enable+0xa5/0xa9
  [<c013a914>] lock_acquire+0x49/0x61
  [<c025a221>] sock_def_wakeup+0x11/0x3d
  [<c02ca449>] _read_lock+0x19/0x24
  [<c025a221>] sock_def_wakeup+0x11/0x3d
  [<c025a221>] sock_def_wakeup+0x11/0x3d
  [<f859fb9c>] ax25_release+0x17e/0x1ab [ax25]
  [<c025847f>] sock_release+0x11/0x59
  [<c0258883>] sock_close+0x19/0x1c
  [<c0165ced>] __fput+0xbe/0x169
  [<c0163a43>] filp_close+0x4d/0x53
  [<c0121df6>] put_files_struct+0x5f/0xa7
  [<c0122ddc>] do_exit+0x187/0x669
  [<c0103840>] restore_nocheck_notrace+0x0/0xe
  [<c012331a>] do_group_exit+0x5c/0x85
  [<c0123350>] sys_exit_group+0xd/0x10
  [<c01037f6>] syscall_call+0x7/0xb
  [<ffffffff>] 0xffffffff
irq event stamp: 369633930
hardirqs last  enabled at (369633930): [<c02ca650>]
_spin_unlock_irqrestore+0x34/0x39
hardirqs last disabled at (369633929): [<c02ca595>]
_spin_lock_irqsave+0xc/0x31
softirqs last  enabled at (369633898): [<c01245e4>] do_softirq+0x37/0x4d
softirqs last disabled at (369633911): [<c01245e4>] do_softirq+0x37/0x4d

other info that might help us debug this:
1 lock held by swapper/0:
 #0:  (slock-AF_AX25){-+..}, at: [<f859dbfb>]
ax25_std_heartbeat_expiry+0x16/0xbb [ax25]

stack backtrace:
Pid: 0, comm: swapper Not tainted 2.6.28.5-dg8ngn #1
Call Trace:
 [<c01381f4>] print_usage_bug+0x13c/0x145
 [<c0138cb9>] mark_lock+0x33e/0x7bc
 [<c013a6d6>] __lock_acquire+0x469/0x65e
 [<c013a914>] lock_acquire+0x49/0x61
 [<f859ed33>] ax25_destroy_socket+0xb6/0x1c4 [ax25]
 [<c02ca3d2>] _write_lock_bh+0x1e/0x29
 [<f859ed33>] ax25_destroy_socket+0xb6/0x1c4 [ax25]
 [<f859ed33>] ax25_destroy_socket+0xb6/0x1c4 [ax25]
 [<f859e2ee>] ax25_heartbeat_expiry+0x0/0x29 [ax25]
 [<f859dc30>] ax25_std_heartbeat_expiry+0x4b/0xbb [ax25]
 [<c01278ca>] run_timer_softirq+0xf6/0x14b
 [<c01244ff>] __do_softirq+0x82/0x130
 [<c01245e4>] do_softirq+0x37/0x4d
 [<c010f8f9>] smp_apic_timer_interrupt+0x6e/0x78
 [<c0104455>] apic_timer_interrupt+0x2d/0x34
 [<c0108e76>] default_idle+0x2f/0x4c
 [<c0102561>] cpu_idle+0x63/0x77

Greetings,
Jann
DG8NGN


--
Jann Traschewski, Drosselstr.1, D-90513 Zirndorf, Germany
Tel.: +49-911-696971, Mobile: +49-170-1045937, E-Mail: jann@gmx.de
Ham: DG8NGN / DB0VOX, http://www.qsl.net/dg8ngn, ICQ UIN: 4130182 
 

------=_NextPart_000_0009_01C9CBD6.CF44EB10
Content-Type: application/x-pkcs7-signature;
	name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="smime.p7s"

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIJIzCCAqsw
ggIUoAMCAQICEB2SMP74/Vgg2jqGvXHx9B8wDQYJKoZIhvcNAQEFBQAwYjELMAkGA1UEBhMCWkEx
JTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMTI1RoYXd0ZSBQ
ZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBMB4XDTA5MDMxODE1NTUzOFoXDTEwMDMxODE1NTUz
OFowgYMxFDASBgNVBAQTC1RyYXNjaGV3c2tpMQ0wCwYDVQQqEwRKYW5uMRkwFwYDVQQDExBKYW5u
IFRyYXNjaGV3c2tpMRowGAYJKoZIhvcNAQkBFgtqYW5uQGdteC5kZTElMCMGCSqGSIb3DQEJARYW
ZGc4bmduQGRiMGZobi5hbXByLm9yZzCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAv22v4KYn
WbXTLALHr2etQeEUozEhUuHN3JtB3PKTxANnQkYwKgccRVcJ2oyG/Hs8oyxyKLZ18KSjV5QnJTN0
GF0F8tfxc/9v8AGKNHkvZTemIqgBhwT0oBP1pfXb8VbjPF5EEGC0zgsDo9bNEg0je2SSoDgASKO8
cBw1HANobyECAwEAAaNAMD4wLgYDVR0RBCcwJYELamFubkBnbXguZGWBFmRnOG5nbkBkYjBmaG4u
YW1wci5vcmcwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQUFAAOBgQAdd6gq3b5gvXazFzdJi2jC
TYmhGXCyIBIyvFJtOp3b2R9NJVa865wmQUgtxGXT/UdHb8D1kXo/0dv0OvHMV97S0fiazvnaGFKn
a+NmplYW56KfGVwINHwR+SX2OawhoxtKC8rnlSjbfOqJnsuQaIqblyVjs3zl5Fy5srJgRe4E9zCC
Ay0wggKWoAMCAQICAQAwDQYJKoZIhvcNAQEEBQAwgdExCzAJBgNVBAYTAlpBMRUwEwYDVQQIEwxX
ZXN0ZXJuIENhcGUxEjAQBgNVBAcTCUNhcGUgVG93bjEaMBgGA1UEChMRVGhhd3RlIENvbnN1bHRp
bmcxKDAmBgNVBAsTH0NlcnRpZmljYXRpb24gU2VydmljZXMgRGl2aXNpb24xJDAiBgNVBAMTG1Ro
YXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBDQTErMCkGCSqGSIb3DQEJARYccGVyc29uYWwtZnJlZW1h
aWxAdGhhd3RlLmNvbTAeFw05NjAxMDEwMDAwMDBaFw0yMDEyMzEyMzU5NTlaMIHRMQswCQYDVQQG
EwJaQTEVMBMGA1UECBMMV2VzdGVybiBDYXBlMRIwEAYDVQQHEwlDYXBlIFRvd24xGjAYBgNVBAoT
EVRoYXd0ZSBDb25zdWx0aW5nMSgwJgYDVQQLEx9DZXJ0aWZpY2F0aW9uIFNlcnZpY2VzIERpdmlz
aW9uMSQwIgYDVQQDExtUaGF3dGUgUGVyc29uYWwgRnJlZW1haWwgQ0ExKzApBgkqhkiG9w0BCQEW
HHBlcnNvbmFsLWZyZWVtYWlsQHRoYXd0ZS5jb20wgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGB
ANRp19SwlGRbcelH2AxRtupykbCEXn0tDY97Et+FJXUodDpCLGMnn5V7S+9+GYcdhuqj3bnOlmQa
whRuRKx85o/oTQ9xH0A4pgCjh3j2+ZSGXq3qwF5269kUo11uenwMpUtVfwYZKX+emibVars4JAhq
mMex2qOYkf152+VaxBy5AgMBAAGjEzARMA8GA1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQEEBQAD
gYEAx+ySfk749ZalZ2IqpPBNEWDQb41gWGGsJrtSNVwIzzD7qEqWih9iQiOMFw/0umScF6xHKd+d
mF7SbGBxXKKs3Hnj524ARx+1DSjoAp3kmv0T9KbZfLH43F8jJgmRgHPQFBveQ6mDJfLmnC8Vyv6m
q4oHdYsM3VGEa+T40c53ooEwggM/MIICqKADAgECAgENMA0GCSqGSIb3DQEBBQUAMIHRMQswCQYD
VQQGEwJaQTEVMBMGA1UECBMMV2VzdGVybiBDYXBlMRIwEAYDVQQHEwlDYXBlIFRvd24xGjAYBgNV
BAoTEVRoYXd0ZSBDb25zdWx0aW5nMSgwJgYDVQQLEx9DZXJ0aWZpY2F0aW9uIFNlcnZpY2VzIERp
dmlzaW9uMSQwIgYDVQQDExtUaGF3dGUgUGVyc29uYWwgRnJlZW1haWwgQ0ExKzApBgkqhkiG9w0B
CQEWHHBlcnNvbmFsLWZyZWVtYWlsQHRoYXd0ZS5jb20wHhcNMDMwNzE3MDAwMDAwWhcNMTMwNzE2
MjM1OTU5WjBiMQswCQYDVQQGEwJaQTElMCMGA1UEChMcVGhhd3RlIENvbnN1bHRpbmcgKFB0eSkg
THRkLjEsMCoGA1UEAxMjVGhhd3RlIFBlcnNvbmFsIEZyZWVtYWlsIElzc3VpbmcgQ0EwgZ8wDQYJ
KoZIhvcNAQEBBQADgY0AMIGJAoGBAMSmPFVzVftOucqZWh5owHUEcJ3f6f+jHuy9zfVb8hp2vX8M
OmHyv1HOAdTlUAow1wJjWiyJFXCO3cnwK4Vaqj9xVsuvPAsH5/EfkTYkKhPPK9Xzgnc9A74r/rsY
Pge/QIACZNenprufZdHFKlSFD0gEf6e20TxhBEAeZBlyYLf7AgMBAAGjgZQwgZEwEgYDVR0TAQH/
BAgwBgEB/wIBADBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLnRoYXd0ZS5jb20vVGhhd3Rl
UGVyc29uYWxGcmVlbWFpbENBLmNybDALBgNVHQ8EBAMCAQYwKQYDVR0RBCIwIKQeMBwxGjAYBgNV
BAMTEVByaXZhdGVMYWJlbDItMTM4MA0GCSqGSIb3DQEBBQUAA4GBAEiM0VCD6gsuzA2jZqxnD3+v
rL7CF6FDlpSdf0whuPg2H6otnzYvwPQcUCCTcDz9reFhYsPZOhl+hLGZGwDFGguCdJ4lUJRix9sn
cVcljd2pnDmOjCBPZV+V2vf3h9bGCE6u9uo05RAaWzVNd+NWIXiC3CEZNd4ksdMdRv9dX2VPMYIC
+DCCAvQCAQEwdjBiMQswCQYDVQQGEwJaQTElMCMGA1UEChMcVGhhd3RlIENvbnN1bHRpbmcgKFB0
eSkgTHRkLjEsMCoGA1UEAxMjVGhhd3RlIFBlcnNvbmFsIEZyZWVtYWlsIElzc3VpbmcgQ0ECEB2S
MP74/Vgg2jqGvXHx9B8wCQYFKw4DAhoFAKCCAdgwGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAc
BgkqhkiG9w0BCQUxDxcNMDkwNTAzMDgwNjIxWjAjBgkqhkiG9w0BCQQxFgQUe6/K/9v90vUCKDHo
jKvxwtvCWHgwZwYJKoZIhvcNAQkPMVowWDAKBggqhkiG9w0DBzAOBggqhkiG9w0DAgICAIAwDQYI
KoZIhvcNAwICAUAwBwYFKw4DAgcwDQYIKoZIhvcNAwICASgwBwYFKw4DAhowCgYIKoZIhvcNAgUw
gYUGCSsGAQQBgjcQBDF4MHYwYjELMAkGA1UEBhMCWkExJTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0
aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMTI1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5n
IENBAhAdkjD++P1YINo6hr1x8fQfMIGHBgsqhkiG9w0BCRACCzF4oHYwYjELMAkGA1UEBhMCWkEx
JTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMTI1RoYXd0ZSBQ
ZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBAhAdkjD++P1YINo6hr1x8fQfMA0GCSqGSIb3DQEB
AQUABIGArXi0uK3XImffFNSJD7D0+9MBGVdMCGP+utIUpY+cDduDBaY7HVlFS9U+aMw23fpvsNZl
2UT40Pp4+x0wyA0P04pob3h90/g68Aw6N16clG0yYzGcmHr2Q0HT/Ip2HSrPa8/l/bQaccU5YEnq
wBJjbUYm1ae/EFMnAgMsmep+WZQAAAAAAAA=

------=_NextPart_000_0009_01C9CBD6.CF44EB10--

