From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: BUG: null pointer deref in rt2800usb_get_txwi
Date: Tue, 09 Aug 2011 10:23:33 +0200
Message-ID: <4E40EE85.3020208@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig256405AA90FF3FCF0BE41B46"
Cc: linux-wireless@vger.kernel.org,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:41618 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318Ab1HIIXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 04:23:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig256405AA90FF3FCF0BE41B46
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello,

I'm a running a sheeva plug (ARM/kirkwood) with a rt2800 USB stick in AP =
mode.
Bus 001 Device 002: ID 1737:0071 Linksys WUSB600N v1 Dual-Band Wireless-N=
 Network Adapter [Ralink RT2870]

kernel is v3.0.1 +
00898a47269ae5e6dda04defad00234b96692d95 rt2x00: fix usage of NULL queue
b52398b6e4522176dd125722c72c301015d24520 rt2x00: rt2800: fix zeroing skb =
structure

Which is here for reference:
(http://git.pengutronix.de/?p=3Dmkl/linux-2.6.git;a=3Dshortlog;h=3Drefs/h=
eads/wireless/rt2x00/v3.0.1)

The Kernel crashes after ~1d with this oopses:
(Same oops with stock v3.0.0 and v3.0.1)

[69638.429744] Unable to handle kernel NULL pointer dereference at virtua=
l address 000000ac
[69638.438515] pgd =3D c0004000
[69638.441322] [000000ac] *pgd=3D00000000
[69638.444974] Internal error: Oops: 17 [#1]
[69638.449001] Modules linked in: nfsd nfs lockd fscache auth_rpcgss nfs_=
acl sunrpc bridge ipv6 stp ext2 arc4 rt2800usb rt2800lib crc_ccitt rt2x00=
usb rt2x00
lib mac80211 cfg80211 rfkill hmac sha1_generic mv_cesa aes_generic ext4 m=
bcache jbd2 mmc_block ehci_hcd mvsdio usbcore mmc_core mv643xx_eth libphy=
 inet_lro
[69638.476620] CPU: 0    Not tainted  (3.0.1-100-bs-kirkwood+ #3)
[69638.482489] PC is at rt2800usb_get_txwi+0x10/0x1c [rt2800usb]
[69638.488273] LR is at rt2800_txdone_entry+0x34/0xe0 [rt2800lib]
[69638.494131] pc : [<bf1bb194>]    lr : [<bf1affa4>]    psr: 80000013
[69638.494136] sp : de44df08  ip : 00000001  fp : 00000022
[69638.505672] r10: 0000000e  r9 : 00000001  r8 : 0000003c
[69638.510914] r7 : 00000000  r6 : de6aafc0  r5 : 818c22fd  r4 : de6d99c8=

[69638.517472] r3 : 00000000  r2 : 00000000  r1 : 818c22fd  r0 : de6d99c8=

[69638.524030] Flags: Nzcv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segme=
nt kernel
[69638.531371] Control: 0005397f  Table: 0105c000  DAC: 00000017
[69638.537144] Process kworker/u:0 (pid: 2089, stack limit =3D 0xde44c270=
)
[69638.543614] Stack: (0xde44df08 to 0xde44e000)
[69638.547997] df00:                   00000000 818c22fd 00000000 de6aafc=
0 de6d99c8 818c22fd
[69638.556221] df20: df958eb4 bf1b0128 c041a384 de6aafc0 df959600 de6ab3c=
4 de6ab3c4 c043defc
[69638.564443] df40: 00000089 00000012 00000000 bf1bba00 de6ab3c4 c043def=
c 00000000 df8b86a0
[69638.572666] df60: df959600 bf1bb9e8 de6ab3c4 c043defc 00000089 0000001=
2 00000000 c005beac
[69638.580881] df80: df8b86a0 df959605 00000081 df8b86a0 de44c000 c043def=
c c043def4 df8b86b0
[69638.589103] dfa0: 00000089 c043defc 00000000 c005ca38 de4c7f30 df8b86a=
0 c005c878 00000013
[69638.597325] dfc0: 00000000 00000000 00000000 c005fdcc 00000000 0000000=
0 df8b86a0 00000000
[69638.605542] dfe0: de44dfe0 de44dfe0 de4c7f30 c005fd50 c0030a94 c0030a9=
4 ebfffffe e3500000
[69638.613787] [<bf1bb194>] (rt2800usb_get_txwi+0x10/0x1c [rt2800usb]) fr=
om [<bf1affa4>] (rt2800_txdone_entry+0x34/0xe0 [rt2800lib])
[69638.625518] [<bf1affa4>] (rt2800_txdone_entry+0x34/0xe0 [rt2800lib]) f=
rom [<bf1b0128>] (rt2800_txdone+0xd8/0x124 [rt2800lib])
[69638.636894] [<bf1b0128>] (rt2800_txdone+0xd8/0x124 [rt2800lib]) from [=
<bf1bba00>] (rt2800usb_work_txdone+0x18/0x110 [rt2800usb])
[69638.648522] [<bf1bba00>] (rt2800usb_work_txdone+0x18/0x110 [rt2800usb]=
) from [<c005beac>] (process_one_work+0x240/0x404)
[69638.659451] [<c005beac>] (process_one_work+0x240/0x404) from [<c005ca3=
8>] (worker_thread+0x1c0/0x2e0)
[69638.668722] [<c005ca38>] (worker_thread+0x1c0/0x2e0) from [<c005fdcc>]=
 (kthread+0x7c/0x84)
[69638.677036] [<c005fdcc>] (kthread+0x7c/0x84) from [<c0030a94>] (kernel=
_thread_exit+0x0/0x8)
[69638.685433] Code: e5903008 e5933008 e3530010 e590300c (e59300ac)
[69638.691726] ---[ end trace 99d4053be7f17aef ]---

[69638.699949] Unable to handle kernel paging request at virtual address =
fffffffc
[69638.707210] pgd =3D c0004000
[69638.709930] [fffffffc] *pgd=3D1fffe831, *pte=3D00000000, *ppte=3D00000=
000
[69638.716244] Internal error: Oops: 17 [#2]
[69638.720270] Modules linked in: nfsd nfs lockd fscache auth_rpcgss nfs_=
acl sunrpc bridge ipv6 stp ext2 arc4 rt2800usb rt2800lib crc_ccitt rt2x00=
usb rt2x00lib mac80211 cfg80211 rfkill hmac sha1_generic mv_cesa aes_gene=
ric ext4 mbcache jbd2 mmc_block ehci_hcd mvsdio usbcore mmc_core mv643xx_=
eth libphy inet_lro
[69638.747890] CPU: 0    Tainted: G      D      (3.0.1-100-bs-kirkwood+ #=
3)
[69638.754628] PC is at kthread_data+0x4/0xc
[69638.758650] LR is at wq_worker_sleeping+0xc/0xc0
[69638.763292] pc : [<c005ffbc>]    lr : [<c005cbb8>]    psr: 20000093
[69638.763297] sp : de44dc68  ip : c03f1958  fp : de44dcf4
[69638.774833] r10: de44c000  r9 : de755d2c  r8 : 00000001
[69638.780084] r7 : df819ac0  r6 : de755da8  r5 : c03f1910  r4 : 00000000=

[69638.786641] r3 : 00000000  r2 : 93c085a9  r1 : 00000000  r0 : de755c20=

[69638.793199] Flags: nzCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segm=
ent user
[69638.800454] Control: 0005397f  Table: 1fa78000  DAC: 00000015
[69638.806226] Process kworker/u:0 (pid: 2089, stack limit =3D 0xde44c270=
)
[69638.812696] Stack: (0xde44dc68 to 0xde44e000)
[69638.817079] dc60:                   de755c20 c02d84c8 de7583e0 c01228b=
4 00000000 00000000
[69638.825293] dc80: 00000003 c0048920 00393830 de755c50 0ecbd14a 0000000=
0 0ecbd14a 00000000
[69638.833507] dca0: c03f1dcc c0061c4c 0ecbd14a 00000000 de755c20 debe084=
0 00000001 c041c348
[69638.841722] dcc0: de755c20 c0046ffc de755c20 00000001 00000000 de755c2=
0 ffffffff de44dcfc
[69638.849945] dce0: df819ac0 00000001 de755d2c de755d2c de755c18 c004892=
0 bf1bb194 de44dcfc
[69638.858168] dd00: de44dcfc de755d74 de44dd1c de44dec0 de44c000 0000000=
1 bf1bb196 de44dd72
[69638.866390] dd20: bf1bb194 00000000 00000017 c0033024 de44c270 0000000=
b 00000001 de44c000
[69638.874606] dd40: 65000001 33303935 20383030 33393565 38303033 3533652=
0 31303033 35652030
[69638.882827] dd60: 30333039 28206330 33393565 63613030 00002029 0000001=
7 00000022 000000ac
[69638.891041] dd80: 00000017 00000000 de44dec0 00000000 00000013 0000001=
7 00000022 c02d5af8
[69638.899257] dda0: de755c20 c0036430 40000013 c0038fc0 c0038f74 def7602=
0 00000f40 c0035840
[69638.907479] ddc0: dee26460 df900574 df900400 bf010dac ffdf5000 ffdf56e=
0 00000010 df900524
[69638.915702] dde0: 40000013 df9004e4 00000003 00000010 60000093 c025412=
4 df9004e4 00000006
[69638.923916] de00: 00000017 c03ec210 000000ac de44dec0 0000003c 0000001=
3 0000000e c002a1cc
[69638.932130] de20: 00000080 00000000 df900598 00000000 de6b4418 df9004e=
4 c04196a0 de44c000
[69638.940344] de40: 00000000 00000001 00000080 00000003 0000012c c02541c=
0 c043ccf0 0069ca19
[69638.948558] de60: 00000000 00000001 0000000c de44c000 c043cce4 0000003=
c 00000001 00000003
[69638.956773] de80: 00000001 c004af7c de8960a0 de755c50 c03f1958 c03f5fb=
8 0000000a 00000014
[69638.964987] dea0: df958eb4 0000000b 00000000 ffffffff de44def4 de6aafc=
0 00000000 c002f7ac
[69638.973201] dec0: de6d99c8 818c22fd 00000000 00000000 de6d99c8 818c22f=
d de6aafc0 00000000
[69638.981415] dee0: 0000003c 00000001 0000000e 00000022 00000001 de44df0=
8 bf1affa4 bf1bb194
[69638.989631] df00: 80000013 ffffffff 00000000 818c22fd 00000000 de6aafc=
0 de6d99c8 818c22fd
[69638.997854] df20: df958eb4 bf1b0128 c041a384 de6aafc0 df959600 de6ab3c=
4 de6ab3c4 c043defc
[69639.006076] df40: 00000089 00000012 00000000 bf1bba00 de6ab3c4 c043def=
c 00000000 df8b86a0
[69639.014291] df60: df959600 bf1bb9e8 de6ab3c4 c043defc 00000089 0000001=
2 00000000 c005beac
[69639.022514] df80: df8b86a0 df959605 00000081 df8b86a0 de44c000 c043def=
c c043def4 df8b86b0
[69639.030737] dfa0: 00000089 c043defc 00000000 c005ca38 de4c7f30 df8b86a=
0 c005c878 00000013
[69639.038958] dfc0: 00000000 00000000 00000000 c005fdcc 00000000 0000000=
0 df8b86a0 00000001
[69639.047175] dfe0: de44dfe0 de44dfe0 de4c7f30 c005fd50 c0030a94 c0030a9=
4 ebfffffe e3500000
[69639.055402] [<c005ffbc>] (kthread_data+0x4/0xc) from [<c005cbb8>] (wq_=
worker_sleeping+0xc/0xc0)
[69639.064148] [<c005cbb8>] (wq_worker_sleeping+0xc/0xc0) from [<c02d84c8=
>] (schedule+0xe8/0x4e8)
[69639.072806] [<c02d84c8>] (schedule+0xe8/0x4e8) from [<c0048920>] (do_e=
xit+0x6b8/0x6f8)
[69639.080764] [<c0048920>] (do_exit+0x6b8/0x6f8) from [<c0033024>] (die+=
0x2e4/0x324)
[69639.088378] [<c0033024>] (die+0x2e4/0x324) from [<c02d5af8>] (__do_ker=
nel_fault.part.5+0x54/0x74)
[69639.097301] [<c02d5af8>] (__do_kernel_fault.part.5+0x54/0x74) from [<c=
0036430>] (do_page_fault+0x260/0x27c)
[69639.107091] [<c0036430>] (do_page_fault+0x260/0x27c) from [<c002a1cc>]=
 (do_DataAbort+0x34/0x98)
[69639.115839] [<c002a1cc>] (do_DataAbort+0x34/0x98) from [<c002f7ac>] (_=
_dabt_svc+0x4c/0x60)
[69639.124139] Exception stack(0xde44dec0 to 0xde44df08)
[69639.129219] dec0: de6d99c8 818c22fd 00000000 00000000 de6d99c8 818c22f=
d de6aafc0 00000000
[69639.137433] dee0: 0000003c 00000001 0000000e 00000022 00000001 de44df0=
8 bf1affa4 bf1bb194
[69639.145643] df00: 80000013 ffffffff
[69639.149165] [<c002f7ac>] (__dabt_svc+0x4c/0x60) from [<bf1bb194>] (rt2=
800usb_get_txwi+0x10/0x1c [rt2800usb])
[69639.159060] [<bf1bb194>] (rt2800usb_get_txwi+0x10/0x1c [rt2800usb]) fr=
om [<bf1affa4>] (rt2800_txdone_entry+0x34/0xe0 [rt2800lib])
[69639.170786] [<bf1affa4>] (rt2800_txdone_entry+0x34/0xe0 [rt2800lib]) f=
rom [<bf1b0128>] (rt2800_txdone+0xd8/0x124 [rt2800lib])
[69639.182164] [<bf1b0128>] (rt2800_txdone+0xd8/0x124 [rt2800lib]) from [=
<bf1bba00>] (rt2800usb_work_txdone+0x18/0x110 [rt2800usb])
[69639.193789] [<bf1bba00>] (rt2800usb_work_txdone+0x18/0x110 [rt2800usb]=
) from [<c005beac>] (process_one_work+0x240/0x404)
[69639.204711] [<c005beac>] (process_one_work+0x240/0x404) from [<c005ca3=
8>] (worker_thread+0x1c0/0x2e0)
[69639.213980] [<c005ca38>] (worker_thread+0x1c0/0x2e0) from [<c005fdcc>]=
 (kthread+0x7c/0x84)
[69639.222293] [<c005fdcc>] (kthread+0x7c/0x84) from [<c0030a94>] (kernel=
_thread_exit+0x0/0x8)
[69639.230685] Code: c03f42e8 c02dea14 c02dbd08 e590315c (e5130004)
[69639.237041] ---[ end trace 99d4053be7f17af0 ]---

cheers, Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig256405AA90FF3FCF0BE41B46
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk5A7ogACgkQjTAFq1RaXHOMnwCgiK3VnCgDQFaZa8c8tm7EjzTn
ULEAnAkpjM7rOG874xLkHzmb922H8m4D
=NF+T
-----END PGP SIGNATURE-----

--------------enig256405AA90FF3FCF0BE41B46--
