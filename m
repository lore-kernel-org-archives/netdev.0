From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler (v2)
Date: Wed, 02 Mar 2011 18:31:27 +0100
Message-ID: <1299087087.2920.27.camel@edumazet-laptop>
References: <20110228171738.2cc8c9a0@nehalam>
	 <20110302020610.GD1005@gandalf.sssup.it>
	 <1299064667.2920.4.camel@edumazet-laptop> <20110302081108.689571d8@nehalam>
	 <1299082728.2920.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fabio Checconi <fchecconi@gmail.com>,
	David Miller <davem@davemloft.net>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:56016 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103Ab1CBRbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 12:31:32 -0500
Received: by bwz15 with SMTP id 15so368318bwz.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 09:31:31 -0800 (PST)
In-Reply-To: <1299082728.2920.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 mars 2011 =C3=A0 17:18 +0100, Eric Dumazet a =C3=A9crit =
:
> Le mercredi 02 mars 2011 =C3=A0 08:11 -0800, Stephen Hemminger a =C3=A9=
crit :
>=20
> > I put the iproute2 code into the repository in the experimental bra=
nch.
> >=20
>=20
> Thanks
>=20
> It seems as soon as packets are dropped, qdisc is frozen (no more
> packets dequeued)
>=20
> Hmm...
>=20

It seems class deletes are buggy.

After one "tc class del dev $ETH classid 11:1 ..."

a "tc -s -d qdisc show dev $ETH" triggers an Oops

[  414.517709] general protection fault: 0000 [#1] SMP=20
[  414.517894] last sysfs file: /sys/devices/virtual/net/gre34/ifindex
[  414.517956] CPU 3=20
[  414.517995] Modules linked in: sch_qfq sch_cbq ip_gre gre dummy ipmi=
_devintf ipmi_si ipmi_msghandler dm_mod video tg3 libphy sg [last unloa=
ded: ip_tables]
[  414.518663]=20
[  414.518717] Pid: 4692, comm: tc Not tainted 2.6.38-rc5-02726-gd486b8=
c-dirty #554 HP ProLiant BL460c G6
[  414.518905] RIP: 0010:[<ffffffff8145118e>]  [<ffffffff8145118e>] tc_=
fill_qdisc+0xbe/0x300
[  414.519025] RSP: 0018:ffff88011a123878  EFLAGS: 00010283
[  414.519085] RAX: a00e6660ffffffff RBX: 0000000000000002 RCX: 0000000=
000000024
[  414.519149] RDX: ffff880078683334 RSI: 0000000000000000 RDI: ffff880=
07867b400
[  414.519212] RBP: ffff88011a123928 R08: ffff880078683000 R09: 0000000=
000000002
[  414.519276] R10: 00000000000001f0 R11: 00000000000001e0 R12: ffff880=
07867b400
[  414.519340] R13: ffff88011cb1779c R14: ffff880078683324 R15: 0000000=
000001254
[  414.519405] FS:  0000000000000000(0000) GS:ffff88007fc40000(0063) kn=
lGS:00000000f77778e0
[  414.519486] CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
[  414.519553] CR2: 00000000005ffc80 CR3: 0000000078087000 CR4: 0000000=
0000006e0
[  414.519616] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000=
000000000
[  414.519680] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000=
000000400
[  414.519744] Process tc (pid: 4692, threadinfo ffff88011a122000, task=
 ffff88011a1715d0)
[  414.519823] Stack:
[  414.519876]  ffff88011bbfb570 000000004d6e7c8e ffff880078683324 0000=
000000000000
[  414.520095]  ffff88011cb1789c ffff88007867b400 ffff8800786832bc 0000=
000400000003
[  414.520312]  0000000000000000 0000000000000000 0000000000000000 0000=
000000000000
[  414.520531] Call Trace:
[  414.520602]  [<ffffffff81451469>] tc_dump_qdisc_root+0x99/0x100
[  414.520666]  [<ffffffff81452680>] tc_dump_qdisc+0x80/0x100
[  414.520729]  [<ffffffff8146a50b>] netlink_dump+0x6b/0x1e0
[  414.520791]  [<ffffffff810f5d16>] ? kmem_cache_alloc_trace+0xb6/0x10=
0
[  414.520855]  [<ffffffff8146d2ef>] netlink_dump_start+0x16f/0x190
[  414.520918]  [<ffffffff81452600>] ? tc_dump_qdisc+0x0/0x100
[  414.520981]  [<ffffffff81443b36>] rtnetlink_rcv_msg+0xb6/0x270
[  414.521043]  [<ffffffff81443a80>] ? rtnetlink_rcv_msg+0x0/0x270
[  414.521106]  [<ffffffff8146b609>] netlink_rcv_skb+0x99/0xc0
[  414.521167]  [<ffffffff81443a65>] rtnetlink_rcv+0x25/0x40
[  414.521229]  [<ffffffff8146b379>] netlink_unicast+0x2a9/0x2b0
[  414.521292]  [<ffffffff8142c3e3>] ? memcpy_fromiovec+0x63/0x80
[  414.521354]  [<ffffffff8146c30d>] netlink_sendmsg+0x24d/0x390
[  414.521418]  [<ffffffff81421510>] sock_sendmsg+0xc0/0xf0
[  414.521482]  [<ffffffff810b699a>] ? unlock_page+0x2a/0x40
[  414.521545]  [<ffffffff81421262>] ? move_addr_to_kernel+0x62/0x70
[  414.521608]  [<ffffffff8144d59f>] ? verify_compat_iovec+0x8f/0x100
[  414.521685]  [<ffffffff814222b0>] sys_sendmsg+0x180/0x300
[  414.521747]  [<ffffffff810d682c>] ? __pte_alloc+0xdc/0x100
[  414.521809]  [<ffffffff810d6992>] ? handle_mm_fault+0x142/0x1c0
[  414.521872]  [<ffffffff81569594>] ? do_page_fault+0x274/0x490
[  414.521935]  [<ffffffff81421f41>] ? sys_getsockname+0xa1/0xb0
[  414.521997]  [<ffffffff81421909>] ? sys_recvmsg+0x49/0x80
[  414.522059]  [<ffffffff8144d164>] compat_sys_sendmsg+0x14/0x20
[  414.522121]  [<ffffffff8144e08d>] compat_sys_socketcall+0x19d/0x1f0
[  414.522185]  [<ffffffff8102d640>] sysenter_dispatch+0x7/0x2e
[  414.522246] Code: 06 49 8d 56 10 45 89 7e 0c 66 41 89 46 04 8b 85 58=
 ff ff ff 41 c6 46 10 00 41 89 46 08 c6 42 01 00 66 c7 42 02 00 00 49 8=
b 45 68 <48> 8b 00 8b 80 c0 00 00 00 89 42 04 8b 85 5c ff ff ff 89 42 0=
c=20
[  414.524636] RIP  [<ffffffff8145118e>] tc_fill_qdisc+0xbe/0x300
[  414.524734]  RSP <ffff88011a123878>
[  414.524799] ---[ end trace 513a4307e5c34d00 ]---


