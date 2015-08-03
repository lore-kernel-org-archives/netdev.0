From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCHv6 RFT] net: fec: Ensure clocks are enabled while using
 mdio bus
Date: Mon, 3 Aug 2015 15:13:40 +0200
Message-ID: <20150803131340.GA9999@pengutronix.de>
References: <1437856682-2338-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Lucas Stach <l.stach@pengutronix.de>, tyler.baker@linaro.org,
	fabio.estevam@freescale.com, shawn.guo@linaro.org,
	kernel@pengutronix.de
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:40707 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791AbbHCNNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 09:13:45 -0400
Content-Disposition: inline
In-Reply-To: <1437856682-2338-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Mon, Aug 03, 2015 at 02:55:40PM +0200, Andrew Lunn wrote:
> v5 was accepted and then reverted, because it broke imx6.  Lucas Stac=
h
> debugged what was going wrong and provided a patch. Thanks Lucas. Thi=
s
> has been squashed into v6.
This fixed-for-i.MX6 patch was included for 4.2-rc5 as commit
8fff755e9f8d0f70a595e79f248695ce6aef5cc3. Unfortunately it breaks
i.MX27 like so:

	Unhandled fault: external abort on non-linefetch (0x808) at 0xf442b014
	pgd =3D c0004000
	[f442b014] *pgd=3D10000452(bad)
	Internal error: : 808 [#1] PREEMPT ARM
	Modules linked in:
	CPU: 0 PID: 5 Comm: kworker/0:0H Not tainted 4.2.0-rc5 #19
	Hardware name: Freescale i.MX27 (Device Tree Support)
	Workqueue: rpciod xs_tcp_setup_socket
	task: c788eb80 ti: c7896000 task.ti: c7896000
	PC is at fec_enet_start_xmit+0x39c/0xe04
	LR is at fec_enet_start_xmit+0x2e8/0xe04
	pc : [<c038ea88>]    lr : [<c038e9d4>]    psr: 80000013
	sp : c7897ad8  ip : 00000018  fp : c71637a0
	r10: c7b4f800  r9 : c781f000  r8 : 00000000
	r7 : 00000001  r6 : c88e5018  r5 : c7b4f800  r4 : c88e5018
	r3 : f442b014  r2 : 00000000  r1 : 00000000  r0 : a7164800
	Flags: Nzcv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
	Control: 0005317f  Table: a0004000  DAC: 00000017
	Process kworker/0:0H (pid: 5, stack limit =3D 0xc7896190)
	Stack: (0xc7897ad8 to 0xc7898000)
	7ac0:                                                       00000001 0=
0000000
	7ae0: c7b4fcc0 c7001fcf 0000cc00 c781e000 00000003 00001800 c7007b37 0=
0000000
	7b00: c7a91880 008976fc 000001a0 c88e5010 00000000 0000002a a7164800 0=
00072d8
	7b20: 00007210 00b43ef2 00000004 00007eac 00000002 00000200 00004000 c=
70eed00
	7b40: c71637a0 c71637a0 0000002a c0766a2c 00000000 c7b4f800 c0766a34 c=
04a59a0
	7b60: 00000000 00000001 00000000 00000001 00000000 00000000 c7a91880 c=
7897bbc
	7b80: c07c1374 00000000 c71637a0 00000000 00000000 c70eed00 c71637a0 c=
7a91880
	7ba0: c7b4f800 00000000 00000000 00000001 00000000 c04c0004 c71637a0 0=
0000010
	7bc0: c71637a0 c70eed00 c7b4f800 00000000 c7a91880 c04a5f60 c70eed68 0=
0000001
	7be0: c70ee322 00000000 00000004 fffffff4 c71637a0 c71637a0 c7b4f800 0=
417a8c0
	7c00: f218a8c0 00000003 c7994300 c7296600 c07b66e0 c04faee0 f218a8c0 0=
0000003
	7c20: c7994300 c7296600 c07b66e0 c04fb534 f218a8c0 00000000 c7b4bc48 c=
70ee200
	7c40: c7b4f800 0417a8c0 f218a8c0 c04fbc90 f218a8c0 00000000 c7b4bc48 0=
0000000
	7c60: c7b4f944 c7292e88 000000a4 c70ee218 c7b4f944 c71638c0 c7163860 c=
04931a0
	7c80: 00000000 c7163860 c70ee200 c7292e88 c70ee218 c7b4f944 00000010 c=
04ad914
	7ca0: 000002c0 c70ee200 00000001 c04b06ac c7292e88 c70ee200 00000000 c=
70ee200
	7cc0: c7b4f944 c04b082c 00000000 c7b4f800 c70fa900 c7b4f800 c70fa900 c=
7292e88
	7ce0: c70ee200 c7b4f944 00000010 c04cfa34 00000000 0417a8c0 c07954b4 c=
7292e88
	7d00: c729f9e0 00000001 00000000 c7b4f800 c70fa900 c7296600 c07b66e0 c=
04d1d5c
	7d20: 00000000 c7ee5bf0 c7891388 00000020 c7292e88 c729f9e0 00000000 c=
729fbbc
	7d40: c7292e88 c729f9e0 00000000 c729fbbc 00a40000 c04cfddc 8d5d04da 0=
0000000
	7d60: 8d4fdf3b c7292de0 8d5d04da c729f9e0 c7292e88 00000000 00000000 0=
00005b4
	7d80: c729fd60 00000020 c07b66e0 c04e7e64 05b4000b 00000004 00000000 f=
fff8c9e
	7da0: 00000000 00000000 00000000 c729f9e0 c7292de0 c729fdb0 c729fd60 c=
7897de4
	7dc0: 00000000 c07707e0 c07b66e0 c04e9b10 00000001 c7897de4 00000000 c=
049d4c0
	7de0: 9c33a999 00000904 fe103136 c729f9e0 0417a8c0 00000002 c70fa900 c=
729fbbc
	7e00: c729fb78 c70fa900 00006f00 c04ec638 c7801280 c729100c 00000000 0=
0000000
	7e20: 000000d0 00020000 00000000 00000000 00000000 6f00e494 f218a8c0 0=
417a8c0
	7e40: 00000000 00000000 00000000 00000000 00000000 00000000 c04e9200 c=
729f9e0
	7e60: 00000800 00000010 c729100c c74052a0 c74052a0 c07c0b7c c076d664 c=
0501888
	7e80: cccccccd 00000000 c729f9e0 c04dabf0 00000000 c0491a78 c07b66e0 0=
0000002
	7ea0: c059a4d8 c74052a0 00000800 00000010 c729100c c74052a0 00000000 c=
07c0b7c
	7ec0: c076d664 c0501948 00000800 c729f9e0 c7291304 c05246d0 c7291000 c=
0526734
	7ee0: 00000004 00000001 0000003c 00000003 00000001 0002bf20 c7291304 c=
7804ca0
	7f00: 00000000 c7ee7c00 c076d664 c002e578 c076d664 c005c310 c077025c c=
7804ca0
	7f20: c076d664 c7804cb8 c7896000 c076d674 00000008 c07c0895 c076d664 c=
002e8f8
	7f40: c7896000 c076d7c4 c7804ca0 c781ddc0 00000000 c7804ca0 c002e8bc 0=
0000000
	7f60: 00000000 00000000 00000000 c0033af0 0000ffff 00000000 0000ffff c=
7804ca0
	7f80: 00000000 c7897f84 c7897f84 00000000 c7897f90 c7897f90 c7897fac c=
781ddc0
	7fa0: c0033a30 00000000 00000000 c000a340 00000000 00000000 00000000 0=
0000000
	7fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 0=
0000000
	7fe0: 00000000 00000000 00000000 00000000 00000013 00000000 0000ffff 0=
0aeffff
	[<c038ea88>] (fec_enet_start_xmit) from [<c04a59a0>] (dev_hard_start_x=
mit+0x244/0x490)
	[<c04a59a0>] (dev_hard_start_xmit) from [<c04c0004>] (sch_direct_xmit+=
0xe0/0x24c)
	[<c04c0004>] (sch_direct_xmit) from [<c04a5f60>] (__dev_queue_xmit+0x2=
58/0x70c)
	[<c04a5f60>] (__dev_queue_xmit) from [<c04faee0>] (arp_xmit+0x7c/0x8c)
	[<c04faee0>] (arp_xmit) from [<c04fbc90>] (arp_solicit+0xc8/0x1a4)
	[<c04fbc90>] (arp_solicit) from [<c04ad914>] (neigh_probe+0x64/0xa0)
	[<c04ad914>] (neigh_probe) from [<c04b06ac>] (__neigh_event_send+0x278=
/0x2e4)
	[<c04b06ac>] (__neigh_event_send) from [<c04b082c>] (neigh_resolve_out=
put+0x114/0x19c)
	[<c04b082c>] (neigh_resolve_output) from [<c04cfa34>] (ip_finish_outpu=
t2+0x128/0x3a4)
	[<c04cfa34>] (ip_finish_output2) from [<c04d1d5c>] (ip_output+0xf0/0x1=
08)
	[<c04d1d5c>] (ip_output) from [<c04cfddc>] (ip_queue_xmit+0x12c/0x370)
	[<c04cfddc>] (ip_queue_xmit) from [<c04e7e64>] (tcp_transmit_skb+0x470=
/0x9c0)
	[<c04e7e64>] (tcp_transmit_skb) from [<c04e9b10>] (tcp_connect+0x5c4/0=
x6f8)
	[<c04e9b10>] (tcp_connect) from [<c04ec638>] (tcp_v4_connect+0x27c/0x4=
08)
	[<c04ec638>] (tcp_v4_connect) from [<c0501888>] (__inet_stream_connect=
+0x264/0x2f0)
	[<c0501888>] (__inet_stream_connect) from [<c0501948>] (inet_stream_co=
nnect+0x34/0x48)
	[<c0501948>] (inet_stream_connect) from [<c0526734>] (xs_tcp_setup_soc=
ket+0x60/0x444)
	[<c0526734>] (xs_tcp_setup_socket) from [<c002e578>] (process_one_work=
+0x144/0x488)
	[<c002e578>] (process_one_work) from [<c002e8f8>] (worker_thread+0x3c/=
0x520)
	[<c002e8f8>] (worker_thread) from [<c0033af0>] (kthread+0xc0/0xdc)
	[<c0033af0>] (kthread) from [<c000a340>] (ret_from_fork+0x14/0x34)
	Code: 03a02f7b 13a02014 e0833002 e3a02000 (e5832000)=20
	---[ end trace 9bc5f5f5fa9af0cb ]---
	Kernel panic - not syncing: Fatal exception in interrupt

The problem is that on i.MX27 there are two clocks involved that both
must be on to send a packet, while on i.MX6 it's only a single one
(abstracted by having ipg-clock =3D ahb-clock). With the suggested patc=
h
only a single one is asserted to be on. This is enough for i.MX6 but
it's not for i.MX27 (and from looking at the device trees also i.MX25,
i.MX28, and i.MX35 are affected).

As I think it would be bold to fix this commit once more for 4.2, I
suggest to revert 8fff755e9f8d0f70a595e79f248695ce6aef5cc3.
(To be honest I wonder why v5 of this commit was even taken for -rc3.)

The straight forward fix for the MDIO issue that was intended to be
addressed by 8fff755e9f8d is to add clk_prepare_enable and matching
_unprepare_disable calls to the mdio callbacks, right?

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
