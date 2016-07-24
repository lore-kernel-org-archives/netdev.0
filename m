From: nuclearcat@nuclearcat.com
Subject: kernel panic, __neigh_notify, 4.7.0-rc7, Workqueue:
 events_power_efficient neigh_periodic_work
Date: Sun, 24 Jul 2016 21:40:22 +0300
Message-ID: <fca2656caca69658277c685de29576ae@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:52124 "EHLO nuclearcat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751268AbcGXSkZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jul 2016 14:40:25 -0400
Received: from localhost (localhost [127.0.0.1])
	by nuclearcat.com (Postfix) with ESMTP id C947967C002E
	for <netdev@vger.kernel.org>; Sun, 24 Jul 2016 18:40:23 +0000 (UTC)
Received: from nuclearcat.com ([127.0.0.1])
	by localhost (nuclearcat.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id rY3X4U5eu7mO for <netdev@vger.kernel.org>;
	Sun, 24 Jul 2016 18:40:22 +0000 (UTC)
Received: from germany.nuclearcat.com (localhost [127.0.0.1])
	(Authenticated sender: nuclearcat@nuclearcat.com)
	by nuclearcat.com (Postfix) with ESMTPA id 2F06C67C002C
	for <netdev@vger.kernel.org>; Sun, 24 Jul 2016 18:40:22 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Different hardware, but same workload. Seems different bug, happened at 
least twice on this unit (both kernel panic messages here)

First crash:

[45113.975701] general protection fault: 0000 [#1]
SMP

[45113.976110] Modules linked in:
cls_fw
act_police
cls_u32
sch_ingress
sch_sfq
sch_htb
netconsole
configfs
pppoe
pppox
ppp_generic
slhc
xt_nat
ts_bm
xt_string
xt_connmark
xt_TCPMSS
xt_tcpudp
xt_mark
iptable_filter
iptable_nat
nf_conntrack_ipv4
nf_defrag_ipv4
nf_nat_ipv4
nf_nat
nf_conntrack
iptable_mangle
ip_tables
x_tables
8021q
garp
mrp
stp
llc
ixgbe
vxlan
udp_tunnel
dca

[45113.979815] CPU: 2 PID: 924 Comm: kworker/2:1 Not tainted 
4.6.4-build-0106 #3
[45113.980077] Hardware name: Supermicro X10SLM+-LN4F/X10SLM+-LN4F, BIOS 
3.0 04/24/2015
[45113.980528] Workqueue: events_power_efficient neigh_periodic_work

[45113.980862] task: ffff88040c8dde00 ti: ffff88040cff4000 task.ti: 
ffff88040cff4000
[45113.981310] RIP: 0010:[<ffffffff8185bd8a>]
[<ffffffff8185bd8a>] neigh_periodic_work+0x171/0x18a
[45113.981828] RSP: 0018:ffff88040cff7df8  EFLAGS: 00010202
[45113.982088] RAX: ffa0050402118600 RBX: ffff8803f8015600 RCX: 
000000000000000d
[45113.982349] RDX: 0000000102abcd01 RSI: 0000000000000200 RDI: 
ffff8803f8015628
[45113.982615] RBP: ffff88040cff7e20 R08: 0000000000000000 R09: 
ffff88040f003700
[45113.982877] R10: ffffea000fc01e80 R11: 000000000000323a R12: 
ffffffff820a8300
[45113.983142] R13: ffffffff820a83ac R14: 0000000000000253 R15: 
ffff8803d3871298
[45113.983409] FS:  0000000000000000(0000) GS:ffff88041fc80000(0000) 
knlGS:0000000000000000
[45113.983856] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[45113.984118] CR2: 00007ff9b9221763 CR3: 0000000002006000 CR4: 
00000000001406e0
[45113.984382] Stack:
[45113.984631]  ffff88040d253b40
ffff88041fc93a80
0000000000000000
ffffffff820a8300

[45113.985352]  ffff88041fc98300
ffff88040cff7e68
ffffffff810d263c
ffff88041fc93a80

[45113.986066]  000000001fc93a80
ffff88040d253b40
ffff88041fc93a80
ffff88040d253b70

[45113.986781] Call Trace:
[45113.987035]  [<ffffffff810d263c>] process_one_work+0x193/0x2a1
[45113.987302]  [<ffffffff810d2c8b>] worker_thread+0x279/0x362
[45113.987563]  [<ffffffff810d2a12>] ? rescuer_thread+0x29a/0x29a
[45113.987823]  [<ffffffff810d685f>] kthread+0xcd/0xd5
[45113.988083]  [<ffffffff818ca902>] ret_from_fork+0x22/0x40
[45113.988343]  [<ffffffff810d6792>] ? 
kthread_create_on_node+0x177/0x177
[45113.988607] Code:
00
00
00
41
8b
4f
08
44
89
f0
d3
e8
85
c0
0f
85
47
ff
ff
ff
49
8b
17
44
89
f0
4c
8d
3c
c2
eb
bb
48
8b
43
10
48
8b
15
76
92
7a
00

63
40
70
48
29
d0
48
03
83
88
00
00
00
78
87
c6
43
28
00
49

[45113.993643] RIP
[<ffffffff8185bd8a>] neigh_periodic_work+0x171/0x18a
[45113.993972]  RSP <ffff88040cff7df8>
[45113.994247] ---[ end trace 02e34672899d1b2e ]---
[45113.995481] Kernel panic - not syncing: Fatal exception in interrupt
[45113.995750] Kernel Offset: disabled
[45113.997638] Rebooting in 5 seconds..
Jul 24 12:06:57 10.0.253.19
Jul 24 12:06:57 10.0.253.19 [45119.000564] ACPI MEMORY or I/O RESET_REG.

---------
Second crash:



[ 2471.924122] general protection fault: 0000 [#1] SMP
[ 2471.924392] Modules linked in:
cls_fw
act_police
cls_u32
sch_ingress
sch_sfq
sch_htb
netconsole
configfs
pppoe
pppox
ppp_generic
slhc
xt_nat
ts_bm
xt_string
xt_connmark
xt_TCPMSS
xt_tcpudp
xt_mark
iptable_filter
iptable_nat
nf_conntrack_ipv4
nf_defrag_ipv4
nf_nat_ipv4
nf_nat
nf_conntrack
iptable_mangle
ip_tables
x_tables
8021q
garp
mrp
stp
llc
ixgbe
dca

[ 2471.928066] CPU: 2 PID: 2135 Comm: kworker/2:2 Not tainted 
4.7.0-rc7-build-0107 #2
[ 2471.928518] Hardware name: Supermicro X10SLM+-LN4F/X10SLM+-LN4F, BIOS 
3.0 04/24/2015
[ 2471.928970] Workqueue: events_power_efficient neigh_periodic_work
2471.928970] Workqueue: events_power_efficient neigh_periodic_workBIOS 
3.0 04/24/2015
<some data corrupted>
nat_ipv4 nf_nat nf_conntrack iptable_mangle ip_tables x_tables 8021q 
garp mrp stp llc ixgbe vxlan udp_tunnel dca
[ 2471.929312] task: ffff88040d2ec680 ti: ffff88040c828000 task.ti: 
ffff88040c828000
[ 2471.929761] RIP: 0010:[<ffffffff8186747b>]
[<ffffffff8186747b>] __neigh_notify+0x29/0xb3
[ 2471.930293] RSP: 0000:ffff88040c82bdb0  EFLAGS: 00010246
[ 2471.930561] RAX: ffac05040202f000 RBX: ffff8800d4525c00 RCX: 
00000000ffffffff
[ 2471.930828] RDX: 0000000000000000 RSI: 0000000002080020 RDI: 
0000000000000080
[ 2471.931096] RBP: ffff88040c82bdd0 R08: 0000000000000000 R09: 
ffff88040f003700
[ 2471.931364] R10: ffffea00034e5e00 R11: 0000000000019bef R12: 
ffffffff820a90c8
[ 2471.931633] R13: ffffffff820a9174 R14: 0000000000000b8c R15: 
ffff8800d7260a00
[ 2471.931904] FS:  0000000000000000(0000) GS:ffff88041fc80000(0000) 
knlGS:0000000000000000
[ 2471.932355] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 2471.932620] CR2: 00007f2a50c1c840 CR3: 00000003e7682000 CR4: 
00000000001406e0
[ 2471.932889] Stack:
[ 2471.933147]  000000000000001d
ffff8800d4525c00
ffffffff820a90c8
ffffffff820a9174

[ 2471.933878]  ffff88040c82bde8
ffffffff8186935f
ffff8800d4525c00
ffff88040c82be20

[ 2471.934614]  ffffffff81869493
ffff88040d19ba80
ffff88041fc94a00
0000000000000000

[ 2471.935350] Call Trace:
[ 2471.935613]  [<ffffffff8186935f>] neigh_cleanup_and_release+0x26/0x39
[ 2471.935881]  [<ffffffff81869493>] neigh_periodic_work+0x121/0x18a
[ 2471.936149]  [<ffffffff810d312e>] process_one_work+0x193/0x2a1
[ 2471.936417]  [<ffffffff810d377d>] worker_thread+0x279/0x362
[ 2471.936687]  [<ffffffff810d3504>] ? rescuer_thread+0x29a/0x29a
[ 2471.936952]  [<ffffffff810d73af>] kthread+0xcd/0xd5
[ 2471.937215]  [<ffffffff818da6bf>] ret_from_fork+0x1f/0x40
[ 2471.937484]  [<ffffffff810d72e2>] ? 
kthread_create_on_node+0x177/0x177
[ 2471.937753] Code:
5d
c3
55
48
89
e5
41
55
41
54
53
51
48
89
fb
48
8b
87
10
01
00
00
89
75
e0
83
c9
ff
89
55
e4
be
20
00
08
02
31
d2
bf
80
00
00
00
8b
a8
68
04
00
00
e8
75
85
fe
ff
48
85
c0
49
89
c4
74
5a
44

[ 2471.943092] RIP
[<ffffffff8186747b>] __neigh_notify+0x29/0xb3
[ 2471.943428]  RSP <ffff88040c82bdb0>
[ 2471.943702] ---[ end trace e0ab8123c24a71f2 ]---
[ 2471.944784] Kernel panic - not syncing: Fatal exception in interrupt
[ 2471.945059] Kernel Offset: disabled
[ 2471.946954] Rebooting in 5 seconds..
Jul 24 17:16:40 10.0.253.19
Jul 24 17:16:40 10.0.253.19 [ 2476.949935] ACPI MEMORY or I/O RESET_REG.
