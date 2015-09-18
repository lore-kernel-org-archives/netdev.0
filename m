From: Lothar =?UTF-8?B?V2HDn21hbm4=?= <LW@KARO-electronics.de>
Subject: [linux-next] Regression in net/ipv4/route.c
Date: Fri, 18 Sep 2015 10:11:23 +0200
Message-ID: <20150918101123.77d48b84@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:57471 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751068AbbIRIL3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 04:11:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I experience the following crash with current linux-next when trying
to mount the rootfs via NFS:
<--- snip --->
fec 2188000.ethernet eth0: Freescale FEC PHY driver [SMSC LAN8710/LAN87=
20] (mii_bus:phy_addr=3D2188000.ethernet:00, irq=3D-1)
fec 2188000.ethernet eth0: Link is Up - 100Mbps/Full - flow control rx/=
tx
Sending DHCP requests .
Unable to handle kernel NULL pointer dereference at virtual address 000=
00009
pgd =3D 80004000
[00000009] *pgd=3D00000000
,
Internal error: Oops: 5 [#1] SMP ARM
Modules linked in:
CPU: 0 PID: 0 Comm: swapper/0 Tainted: G        W       4.3.0-rc1-next-=
20150917-karo #364
Hardware name: Freescale i.MX6 Quad/DualLite (Device Tree)
task: 807a2b68 ti: 8079e000 task.ti: 8079e000
PC is at ip_route_input_noref+0x238/0x81c
LR is at dst_alloc+0x70/0x94
pc : [<804ab100>]    lr : [<8048f7fc>]    psr: 20000113
sp : 8079fca0  ip : 8079fc40  fp : 00000010
r10: be22a000  r9 : be2e0000  r8 : 00000001
r7 : 00000000  r6 : be0b2b40  r5 : bd9a3800  r4 : ffffff8f
r3 : 00000001  r2 : 804a96a8  r1 : bd9a3870  r0 : bd9a3800
=46lags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
Control: 10c5387d  Table: 1000404a  DAC: 00000051
Process swapper/0 (pid: 0, stack limit =3D 0x8079e210)
Stack: (0x8079fca0 to 0x807a0000)
fca0: 00000000 00000000 8079fd60 40000193 00035220 00000000 fffffff8 00=
000000
fcc0: 00000100 00070000 00000000 00000000 00000001 bdcb0618 00000000 00=
000004
fce0: 00000000 00000010 20000000 802568cc 00000000 00000000 0164a8c0 5f=
64a8c0
fd00: be22a000 807a2168 bd98e480 bd9d774e be0b2b58 00000000 00000000 be=
0b2b40
fd20: be0b2be4 807c75c0 00000001 804ad534 be22a000 be0b2b40 807a2168 be=
0b2b40
fd40: 807a2168 be22a000 be22a048 00000008 be22a05c 80481268 be01ff40 80=
7a0100
fd60: 807cc340 be0b2b40 be22a590 be0b2b40 807a2160 be22a05c 0000000e 80=
7a124c
fd80: be0b2b40 bf048000 00000000 00000800 00000001 bf048000 be22a000 80=
484cc8
fda0: 00000000 be0b2b40 be22a590 bf048000 00000000 00000800 00000001 be=
0b2b40
fdc0: 00000003 8048581c 00000002 be0b2b40 00000000 8039d784 00000001 00=
1dcd65
fde0: 40000000 00000012 00000040 be22a040 02000022 be2d0000 0000015a 00=
000000
fe00: 00000000 00000002 4d9d7740 bd98e3c0 00000000 00000000 00000000 00=
000000
fe20: be22a524 00000040 be22a4c0 be22a590 8001504c 8007aa70 00000000 be=
22a590
fe40: 8039d30c 00000040 0000012c ffff8d25 8079c4c0 8079fe70 3e81f000 80=
485438
fe60: 62a5cb80 807a0100 8079fe78 befbb4c0 8079fe70 8079fe70 8079fe78 80=
79fe78
fe80: 00000001 00000000 807a008c 00000003 80798248 807a0080 807a0080 00=
000100
fea0: 00000003 80025148 be1975a0 00000000 00000096 0000000a ffff8d24 00=
200000
fec0: 8052edd4 807990d0 00000000 00000000 00000096 be008000 00000001 f4=
001100
fee0: 8052edd4 8002552c 807990d0 8005f074 f4000100 f400010c 807a0770 80=
7af670
ff00: 8079ff28 80009428 80079bc0 8040574c 60000113 ffffffff 8079ff5c 62=
a5d0b5
ff20: 807982a4 80012d14 00000000 befbd740 00000005 00000695 622d2de5 00=
000001
ff40: befba270 00000001 62a5d0b5 00000001 807982a4 8052edd4 021fcf24 80=
79ff78
ff60: 80079bc0 8040574c 60000113 ffffffff 00000051 80405704 00000000 00=
000000
ff80: 62a5d0b5 00000001 befba270 807a0448 befba270 807a43c8 8079b268 80=
7a049c
ffa0: 807a0494 807982a4 8052edd4 80055e58 000000fc 807cc5c0 00000000 80=
751bc4
ffc0: ffffffff ffffffff 00000000 80751674 00000000 807888c0 00000000 80=
7cc854
ffe0: 807a0440 807888bc 807a3b88 1000406a 00000000 1000807c 00000000 00=
000000
[<804ab100>] (ip_route_input_noref) from [<804ad534>] (ip_rcv+0x330/0x7=
70)
[<804ad534>] (ip_rcv) from [<80481268>] (__netif_receive_skb_core+0x2b0=
/0x7b0)
[<80481268>] (__netif_receive_skb_core) from [<80484cc8>] (netif_receiv=
e_skb_internal+0x30/0xa0)
[<80484cc8>] (netif_receive_skb_internal) from [<8048581c>] (napi_gro_r=
eceive+0x78/0xa4)
[<8048581c>] (napi_gro_receive) from [<8039d784>] (fec_enet_rx_napi+0x4=
78/0xbb8)
[<8039d784>] (fec_enet_rx_napi) from [<80485438>] (net_rx_action+0xf4/0=
x2c8)
[<80485438>] (net_rx_action) from [<80025148>] (__do_softirq+0xe8/0x238=
)
[<80025148>] (__do_softirq) from [<8002552c>] (irq_exit+0xa8/0x114)
[<8002552c>] (irq_exit) from [<8005f074>] (__handle_domain_irq+0x58/0xb=
0)
[<8005f074>] (__handle_domain_irq) from [<80009428>] (gic_handle_irq+0x=
40/0x8c)
[<80009428>] (gic_handle_irq) from [<80012d14>] (__irq_svc+0x54/0x70)
Exception stack(0x8079ff28 to 0x8079ff70)
ff20:                   00000000 befbd740 00000005 00000695 622d2de5 00=
000001
ff40: befba270 00000001 62a5d0b5 00000001 807982a4 8052edd4 021fcf24 80=
79ff78
ff60: 80079bc0 8040574c 60000113 ffffffff
[<80012d14>] (__irq_svc) from [<8040574c>] (cpuidle_enter_state+0xd8/0x=
258)
[<8040574c>] (cpuidle_enter_state) from [<80055e58>] (cpu_startup_entry=
+0x174/0x24c)
[<80055e58>] (cpu_startup_entry) from [<80751bc4>] (start_kernel+0x300/=
0x354)
[<80751bc4>] (start_kernel) from [<1000807c>] (0x1000807c)
Code: e5c5205e e59f25c8 e3530000 e585202c (15933008)=20
---[ end trace 48499f217b13223f ]---
Kernel panic - not syncing: Fatal exception in interrupt
CPU1: stopping
CPU: 1 PID: 0 Comm: swapper/1 Tainted: G      D W       4.3.0-rc1-next-=
20150917-karo #364
Hardware name: Freescale i.MX6 Quad/DualLite (Device Tree)
[<8001639c>] (unwind_backtrace) from [<80012260>] (show_stack+0x10/0x14=
)
[<80012260>] (show_stack) from [<80251918>] (dump_stack+0x78/0x94)
[<80251918>] (dump_stack) from [<800151f8>] (handle_IPI+0x170/0x1ac)
[<800151f8>] (handle_IPI) from [<80009468>] (gic_handle_irq+0x80/0x8c)
[<80009468>] (gic_handle_irq) from [<80012d14>] (__irq_svc+0x54/0x70)
Exception stack(0xbe08bf60 to 0xbe08bfa8)
bf60: 00000000 80812130 00000002 0000069f 7a3b2c82 00000001 befc6270 00=
000001
bf80: 7ab9e738 00000001 807982a4 8052edd4 00000000 be08bfb0 8007b290 80=
40574c
bfa0: 60000113 ffffffff
[<80012d14>] (__irq_svc) from [<8040574c>] (cpuidle_enter_state+0xd8/0x=
258)
[<8040574c>] (cpuidle_enter_state) from [<80055e58>] (cpu_startup_entry=
+0x174/0x24c)
[<80055e58>] (cpu_startup_entry) from [<1000950c>] (0x1000950c)
<--- snap ---> =20

I bisected it down to: commit b7503e0cdb5d (net: Add FIB table id to rt=
able)

There may be other ways to produce the same crash too, but I did not
test any further.


Lothar Wa=C3=9Fmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=C3=9Fe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=C3=A4ftsf=C3=BChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
