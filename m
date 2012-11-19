From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: unable to handle paging request, arm, at aio/tcp code, only 3.6
Date: Mon, 19 Nov 2012 11:41:35 -0800
Message-ID: <1353354095.10798.76.camel@edumazet-glaptop>
References: <20121119183222.GI2068@vicerveza.homeunix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Llu=EDs?= Batlle i Rossell <viric@viric.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:43505 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753233Ab2KSTlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 14:41:37 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so3693600pbc.19
        for <netdev@vger.kernel.org>; Mon, 19 Nov 2012 11:41:36 -0800 (PST)
In-Reply-To: <20121119183222.GI2068@vicerveza.homeunix.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-11-19 at 19:32 +0100, Llu=C3=ADs Batlle i Rossell wrote:
> (crosspost from lkml)
> Hello,
>=20
> in a Sheevaplug (armv5tel), if I run the kernels 3.6.3 or 3.6.6, they=
 crash in
> less than 48h. Kernel 3.5.3 runs perfect, as most previous kernels I'=
ve been
> running until 2.6.36.
>=20
> Can anyone suggest what change can be the cause of that?
> Or how could I debug this to fix it?
>=20
> Here is the panic:
> unable to handle kernel paging request at virtual address ffffffab
> pgd =3D d864c000
> [ffffffab] *pgd=3D1fffe831, *pte=3D00000000, *ppte=3D00000000
> Internal error: Oops: 1 [#1] PREEMPT ARM
> Modules linked in: netconsole cbc sg cryptodev(O) fuse ipv6 ums_cypre=
ss dm_mod btrfs ext4 jb
> d2 reiserfs [last unloaded: netconsole]
> CPU: 0    Tainted: G           O  (3.6.6 #1)
> PC is at tcp_v6_mtu_reduced+0x40/0x80 [ipv6]
> LR is at ip6_dst_lookup_tail+0xd8/0xfc [ipv6]
> pc : [<bf2b02f8>]    lr : [<bf28a67c>]    psr: a0000013
> sp : d8649c78  ip : d8649b90  fp : d8649c94
> r10: 00000b50  r9 : fffffff5  r8 : 00000000
> r7 : d2c4a100  r6 : 000032e8  r5 : ffffff9b  r4 : d2c4a100
> r3 : 00000000  r2 : a0000093  r1 : c0c5f460  r0 : ffffff9b
> Flags: NzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
> Control: 0005397f  Table: 1864c000  DAC: 00000015
> Process httpd (pid: 1923, stack limit =3D 0xd8648270)
> Stack: (0xd8649c78 to 0xd864a000)
> 9c60:                                                       bf2b02b8 =
00000020
> 9c80: d2c4a100 000032e8 d8649cac d8649c98 c0439f18 bf2b02c8 d8648000 =
000032e8
> 9ca0: d8649cdc d8649cb0 c03e3dfc c0439e28 00000000 00000040 000032e8 =
000032e8
> 9cc0: d2c4a100 00000000 fffffff5 00000b50 d8649d74 d8649ce0 c042b7ac =
c03e3d0c
> 9ce0: 00000000 c035fac0 00010000 00000000 00000000 d863bd10 d8649d14 =
00000000
> 9d00: 00000000 00000630 00000000 00000001 d8649ee4 d8648000 00000001 =
00000000
> 9d20: d2c4a190 000005a8 00000a28 000032e8 00490cb0 00000040 dfa5a220 =
00000b50
> 9d40: 00000000 00000001 00000000 d2c4a100 d8649e18 d8649e18 00000003 =
d8649db8
> 9d60: 00005000 dafc59a0 d8649d94 d8649d78 c044f37c c042b6d8 c03e2474 =
c0037ee4
> 9d80: 00005000 d8649d98 d8649e04 d8649d98 c03de7e8 c044f338 d2e6001c =
c0044d14
> 9da0: 00000015 00005000 dafc59a0 ccb9e9f4 00000000 d8649db8 00000000 =
00000000
> 9dc0: d8649ed4 00000003 00000000 00000000 00000040 d8649e18 50a95c6c =
00000000
> 9de0: 00000000 fffffdee d8649ed4 00000003 00005000 c03de6e4 d8649ec4 =
d8649e08
> 9e00: c00db170 c03de6f4 00000000 00000000 d868c480 dfa5a220 00000000 =
00000000
> 9e20: 00000000 00000001 ffffffff d868c480 00000000 00000000 00000000 =
00000000
> 9e40: dfa5a220 00000000 00000000 00000000 00000000 00000000 d8649d98 =
00000000
> 9e60: 00005000 00000000 00005000 00000000 00000000 00000000 00000000 =
00000000
> 9e80: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 =
d868c480
> 9ea0: 00005000 d8649ed4 00000001 00000003 d8649f70 00005000 d8649f44 =
d8649ec8
> 9ec0: c00db41c c00db0cc d8649f70 c03de6e4 d8649ef0 004878e8 00001f40 =
0048f908
> 9ee0: 00001f40 0047d8c0 00001180 c050a478 d8649ef0 d8649ef0 d8648000 =
c012184c
> 9f00: 00000000 d8648000 cbac00dc 00000002 d8649fa4 d8649ed4 c012184c =
00000003
> 9f20: beeeb1a0 d8649f70 00000092 00000000 00000000 00000000 d8649f6c =
d8649f48
> 9f40: c00db580 c00db36c d8649f70 c00db6c0 00000003 d868c480 beeeb1a0 =
00000003
> 9f60: d8649fa4 d8649f70 c00db6e4 c00db528 00000000 00000000 d8649fa4 =
00000000
> 9f80: 0001117e 00000003 0000000b beeeb1a0 c0009484 d8648000 00000000 =
d8649fa8
> 9fa0: c0009260 c00db6a8 00000003 0000000b 0000000b beeeb1a0 00000003 =
b6c99000
> 9fc0: 00000003 0000000b beeeb1a0 00000092 beeeb134 00000003 00000000 =
beeeb1a0
> 9fe0: 00000000 beeeb0f8 b6d39ef4 b6c2d768 60000010 0000000b 6c644a76 =
64703347
> [<bf2b02f8>] (tcp_v6_mtu_reduced+0x40/0x80 [ipv6]) from [<c0439f18>] =
(tcp_release_cb+0x100/0x120)
> [<c0439f18>] (tcp_release_cb+0x100/0x120) from [<c03e3dfc>] (release_=
sock+0x100/0x17c)
> [<c03e3dfc>] (release_sock+0x100/0x17c) from [<c042b7ac>] (tcp_sendms=
g+0xe4/0xe8c)
> [<c042b7ac>] (tcp_sendmsg+0xe4/0xe8c) from [<c044f37c>] (inet_sendmsg=
+0x54/0x88)
> [<c044f37c>] (inet_sendmsg+0x54/0x88) from [<c03de7e8>] (sock_aio_wri=
te+0x104/0x114)
> [<c03de7e8>] (sock_aio_write+0x104/0x114) from [<c00db170>] (do_sync_=
readv_writev+0xb4/0xe8)
> [<c00db170>] (do_sync_readv_writev+0xb4/0xe8) from [<c00db41c>] (do_r=
eadv_writev+0xc0/0x1bc)
> [<c00db41c>] (do_readv_writev+0xc0/0x1bc) from [<c00db580>] (vfs_writ=
ev+0x68/0x84)
> [<c00db580>] (vfs_writev+0x68/0x84) from [<c00db6e4>] (sys_writev+0x4=
c/0x78)
> [<c00db6e4>] (sys_writev+0x4c/0x78) from [<c0009260>] (ret_fast_sysca=
ll+0x0/0x2c)
> Code: e59014d0 eb001678 e2505000 0afffffa (e5953010)
> ---[ end trace 8b4363f5e83db74f ]---
> Kernel panic - not syncing: Fatal exception in interrupt
> --

Thanks for the report.

I believe this is a regression of commit
35ad9b9cf7d8a2e6259a0d24022e910adb6f3489
(ipv6: Add helper inet6_csk_update_pmtu().)

I'll prepare a patch to fix this.
