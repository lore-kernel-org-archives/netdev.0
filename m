From: nuclearcat@nuclearcat.com
Subject: 4.6.3, pppoe + shaper workload,  skb_panic / skb_push /
 ppp_start_xmit
Date: Mon, 11 Jul 2016 22:45:00 +0300
Message-ID: <c72d23549eaa7aadee1a66a6bb788a4a@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:52662 "EHLO nuclearcat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750950AbcGKTpE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2016 15:45:04 -0400
Received: from localhost (localhost [127.0.0.1])
	by nuclearcat.com (Postfix) with ESMTP id BECF867C0115
	for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 19:45:01 +0000 (UTC)
Received: from nuclearcat.com ([127.0.0.1])
	by localhost (nuclearcat.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id W170lhuelmCz for <netdev@vger.kernel.org>;
	Mon, 11 Jul 2016 19:45:00 +0000 (UTC)
Received: from germany.nuclearcat.com (localhost [127.0.0.1])
	(Authenticated sender: nuclearcat@nuclearcat.com)
	by nuclearcat.com (Postfix) with ESMTPA id 1CA4F67C007A
	for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 19:45:00 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On latest kernel i noticed kernel panic happening 1-2 times per day. It 
is also happening on older kernel (at least 4.5.3).

Panic message received over netconsole:

[42916.416307] skbuff: skb_under_panic: text:ffffffffa00e8ce5 len:581 
put:2 head:ffff8800b0bf2800 data:ffa00500b0bf284c tail:0x291 end:0x6c0 
dev:ppp2828
[42916.416677] ------------[ cut here ]------------
[42916.416876] kernel BUG at net/core/skbuff.c:104!
[42916.417075] invalid opcode: 0000 [#1]
SMP

[42916.417388] Modules linked in:
cls_fw
act_police
cls_u32
sch_ingress
sch_sfq
sch_htb
netconsole
configfs
coretemp
nf_nat_pptp
nf_nat_proto_gre
nf_conntrack_pptp
nf_conntrack_proto_gre
pppoe
pppox
ppp_generic
slhc
tun
xt_REDIRECT
nf_nat_redirect
xt_TCPMSS
ipt_REJECT
nf_reject_ipv4
xt_set
ts_bm
xt_string
xt_connmark
xt_DSCP
xt_mark
xt_tcpudp
ip_set_hash_net
ip_set_hash_ip
ip_set
nfnetlink
iptable_mangle
iptable_filter
iptable_nat
nf_conntrack_ipv4
nf_defrag_ipv4
nf_nat_ipv4
nf_nat
nf_conntrack
ip_tables
x_tables
8021q
garp
mrp
stp
llc


  [42916.421443] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 
4.6.3-build-0105 #4
  [42916.421643] Hardware name: HP ProLiant DL320e Gen8 v2, BIOS P80 
04/02/2015
  [42916.421842] task: ffffffff8200b500 ti: ffffffff82000000 task.ti: 
ffffffff82000000
  [42916.422178] RIP: 0010:[<ffffffff8184374e>]
  [<ffffffff8184374e>] skb_panic+0x49/0x4b
  [42916.422574] RSP: 0018:ffff880447403da8  EFLAGS: 00010296
  [42916.422773] RAX: 0000000000000089 RBX: ffff880422c13900 RCX: 
0000000000000000
  [42916.422974] RDX: ffff88044740df50 RSI: ffff88044740c908 RDI: 
ffff88044740c908
  [42916.423175] RBP: ffff880447403dc8 R08: 0000000000000001 R09: 
0000000000000000
  [42916.423439] R10: ffffffff820050c0 R11: ffff88041c7ee900 R12: 
ffff880423037000
  [42916.423640] R13: 0000000000000000 R14: ffff880423037000 R15: 
0000000000000000
  [42916.423841] FS:  0000000000000000(0000) GS:ffff880447400000(0000) 
knlGS:0000000000000000
  [42916.424179] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  [42916.424379] CR2: 00007effd0814b00 CR3: 0000000430ab2000 CR4: 
00000000001406f0
  [42916.424577] Stack:
  [42916.424772]  ffa00500b0bf284c
  0000000000000291
  00000000000006c0
  ffff880423037000

  [42916.425333]  ffff880447403dd8
  ffffffff81843786
  ffff880447403e00
  ffffffffa00e8ce5

  [42916.425898]  ffff880422c13900
  ffff8800ae7c6c00
  ffffffff820b3210
  ffff880447403e68

  [42916.426463] Call Trace:
  [42916.426658]  <IRQ>

  [42916.426719]  [<ffffffff81843786>] skb_push+0x36/0x37
  [42916.427111]  [<ffffffffa00e8ce5>] ppp_start_xmit+0x10f/0x150 
[ppp_generic]
  [42916.427314]  [<ffffffff81853467>] dev_hard_start_xmit+0x25a/0x2d3
  [42916.427516]  [<ffffffff818530f2>] ? 
validate_xmit_skb.isra.107.part.108+0x11d/0x238
  [42916.427858]  [<ffffffff8186dee3>] sch_direct_xmit+0x89/0x1b5
  [42916.428060]  [<ffffffff8186e142>] __qdisc_run+0x133/0x170
  [42916.428261]  [<ffffffff81850034>] net_tx_action+0xe3/0x148
  [42916.428462]  [<ffffffff810c401a>] __do_softirq+0xb9/0x1a9
  [42916.428663]  [<ffffffff810c4251>] irq_exit+0x37/0x7c
  [42916.428862]  [<ffffffff8102b8f7>] smp_apic_timer_interrupt+0x3d/0x48
  [42916.429063]  [<ffffffff818cb15c>] apic_timer_interrupt+0x7c/0x90
  [42916.429263]  <EOI>

  [42916.429324]  [<ffffffff8101be12>] ? mwait_idle+0x68/0x7e
  [42916.429719]  [<ffffffff810d731c>] ? 
atomic_notifier_call_chain+0x13/0x15
  [42916.429921]  [<ffffffff8101c212>] arch_cpu_idle+0xa/0xc
  [42916.430121]  [<ffffffff810ea333>] default_idle_call+0x27/0x29
  [42916.430323]  [<ffffffff810ea44a>] cpu_startup_entry+0x115/0x1bf
  [42916.430526]  [<ffffffff818c5d7b>] rest_init+0x72/0x74
  [42916.430727]  [<ffffffff820cdd8c>] start_kernel+0x3b7/0x3c4
  [42916.430929]  [<ffffffff820cd422>] 
x86_64_start_reservations+0x2a/0x2c
  [42916.431130]  [<ffffffff820cd4df>] x86_64_start_kernel+0xbb/0xbe
  [42916.431332] Code:
  78
  50
  8b
  87
  c0
  00
  00
  00
  50
  8b
  87
  bc
  00
  00
  00
  50
  ff
  b7
  d0
  00
  00
  00
  31
  c0
  4c
  8b
  8f
  c8
  00
  00
  00
  48
  c7
  c7
  49
  10
  e1
  81
  e8
  0e
  60
  8e
  ff
  0b
  48
  8b
  97
  d0
  00
  00
  00
  89
  f0
  01
  77
  78
  48
  29
  c2
  48
  3b
  97
  c8

  [42916.435514] RIP
  [<ffffffff8184374e>] skb_panic+0x49/0x4b
  [42916.439115]  RSP <ffff880447403da8>
  [42916.439336] ---[ end trace d7bfed0177be96d1 ]---
  [42916.445801] Kernel panic - not syncing: Fatal exception in interrupt
  [42916.446005] Kernel Offset: disabled
  [42916.477266] Rebooting in 5 seconds..
