From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: BUG: ping without route segfaults in dst_release
Date: Tue, 29 Mar 2011 01:18:48 +0200
Message-ID: <4D911758.3010608@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigF3E0530C9657FA1A4857D45A"
Cc: David Miller <davem@davemloft.net>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: Netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49520 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932184Ab1C1XSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 19:18:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigF3E0530C9657FA1A4857D45A
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello,

I just found this breakage in current mainline (v2.6.38-8876-g036a982)

root@ptx:~ ifconfig
eth0      Link encap:Ethernet  HWaddr 00:04:9F:01:7E:E9
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

root@ptx:~ ping 130.75.1.32
PING 130.75.1.32 (130.75[   10.160000] Unable to handle kernel paging req=
uest at virtual address ffffffdb
[   10.160000] pgd =3D c7998000
[   10.160000] [ffffffdb] *pgd=3D47ffe831, *pte=3D00000000, *ppte=3D00000=
000
[   10.160000] Internal error: Oops: 1 [#1]
[   10.160000] last sysfs file: /sys/kernel/uevent_seqnum
[   10.160000] Modules linked in:
[   10.160000] CPU: 0    Not tainted  (2.6.38+ #10)
[   10.160000] PC is at dst_release+0x1c/0x80
[   10.160000] LR is at raw_sendmsg+0x68c/0x714
[   10.160000] pc : [<c017a3fc>]    lr : [<c01ae0d0>]    psr: a0000093
[   10.160000] sp : c7965d70  ip : 8220014b  fp : 00000000
[   10.160000] r10: 00000000  r9 : 00000000  r8 : 20014b82
[   10.160000] r7 : 00000001  r6 : c78e1b40  r5 : ffffff9b  r4 : ffffff9b=

[   10.160000] r3 : a0000093  r2 : a0000013  r1 : 6b006b83  r0 : ffffff9b=

[   10.160000] Flags: NzCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segm=
ent user
[   10.160000] Control: 0005317f  Table: 47998000  DAC: 00000015
[   10.160000] Process ping (pid: 102, stack limit =3D 0xc7964270)
[   10.160000] Stack: (0xc7965d70 to 0xc7966000)
[   10.160000] 5d60:                                     00000000 ffffff9=
b c7965f5c c01ae0d0
[   10.160000] 5d80: 60000013 c7994fc0 00000000 80000093 00000040 0000000=
0 00000000 00000000
[   10.160000] 5da0: 00000000 04010000 00000000 20014b82 00000000 0000000=
8 20014b82 00000000
[   10.160000] 5dc0: 00000000 c791f500 c7965dec ffffff9b 00000062 c78e1b4=
0 00000040 c7965e10
[   10.160000] 5de0: c7965f5c 00085cc8 c7964000 0000001c be8b4e54 c01b785=
8 00000000 00000000
[   10.160000] 5e00: 00000000 00000000 c7965edc c0163810 c03d8e60 0000000=
0 00000000 00000001
[   10.160000] 5e20: ffffffff 00000000 00000000 00000000 00000000 0000000=
0 c7994fc0 00000200
[   10.160000] 5e40: 00000000 00000000 0006a000 c03d8e60 c7965e88 0000000=
0 c7998000 c791f580
[   10.160000] 5e60: c79761a8 0006a000 c7998000 00000000 c7a16000 c007a8c=
8 00000062 00000000
[   10.160000] 5e80: 00000000 c03cf7e0 00000000 c006b76c c03cf7e0 0000004=
0 c74752c0 00000000
[   10.160000] 5ea0: 00000000 c7965f5c c7998000 c74752c0 00000000 c7965ed=
c 00085cc8 c7965edc
[   10.160000] 5ec0: 0000001c 00000000 00000040 c74752c0 00000000 c016414=
4 80000005 00000002
[   10.160000] 5ee0: 20014b82 00000000 00000000 00000000 00000000 0000000=
0 00000005 c7965fb0
[   10.160000] 5f00: 0006a2bc be8b4e54 00085c70 c0021220 c02a4408 c01f13b=
4 00000000 c008e684
[   10.160000] 5f20: c7965f58 00000000 00000001 c78e1b40 00001c70 c74752c=
0 00000000 c0168020
[   10.160000] 5f40: c7965f4c c016456c c0296310 be8b4968 00000002 000000a=
e c0022088 c7965edc
[   10.160000] 5f60: 0000001c c7965f78 00000001 00000000 00000000 0000000=
0 00ad80f8 00000040
[   10.160000] 5f80: 00000000 00000000 00000000 00085cc8 0000001c 00085c7=
0 00000122 c0022088
[   10.160000] 5fa0: 00000000 c0021ee0 00085cc8 0000001c 00000003 00ad80f=
8 00000040 00000000
[   10.160000] 5fc0: 00085cc8 0000001c 00085c70 00000122 00000000 be8b4e5=
4 00085c70 be8b4e54
[   10.160000] 5fe0: 000179d4 be8b4b70 0000da90 401a7f28 60000010 0000000=
3 00000001 0000000a
[   10.160000] [<c017a3fc>] (dst_release+0x1c/0x80) from [<c01ae0d0>] (ra=
w_sendmsg+0x68c/0x714)
[   10.160000] [<c01ae0d0>] (raw_sendmsg+0x68c/0x714) from [<c01b7858>] (=
inet_sendmsg+0x68/0x74)
[   10.160000] [<c01b7858>] (inet_sendmsg+0x68/0x74) from [<c0163810>] (s=
ock_sendmsg+0x88/0xa8)
[   10.160000] [<c0163810>] (sock_sendmsg+0x88/0xa8) from [<c0164144>] (s=
ys_sendto+0xb4/0xd8)
[   10.160000] [<c0164144>] (sys_sendto+0xb4/0xd8) from [<c0021ee0>] (ret=
_fast_syscall+0x0/0x2c)
[   10.160000] Code: 0a000017 e10f2000 e3823080 e121f003 (e5953040)
=2E1.32): 56 data bytes
[   10.470000] ---[ end trace 6d4174e1407fa33f ]---
Segmentation fault

2.6.38 works:

root@ptx:~ ping 130.75.1.32
PING 130.75.1.32 (130.75.1.32): 56 data bytes
ping: sendto: Network is unreachable

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigF3E0530C9657FA1A4857D45A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk2RF1sACgkQjTAFq1RaXHM8OwCfUnjt0ULV8Pa/XiIs00j7Jb0+
JYIAniGMRjjXug5injBDAUNHNNhccWZI
=PuXh
-----END PGP SIGNATURE-----

--------------enigF3E0530C9657FA1A4857D45A--
