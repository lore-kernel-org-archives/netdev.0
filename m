From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Question about "prevent dst uses after free" and WARNING in
 nf_xfrm_me_harder / refcnt / 4.13.3
Date: Tue, 03 Oct 2017 00:33:23 +0300
Message-ID: <5fda8b98704f6db99b83b3919407a1a8@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:54078 "EHLO nuclearcat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750936AbdJBVd0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 17:33:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm running now 4.13.3, is this patch required for 4.13 as well?
(it doesnt apply cleanly, as in 4.13 tcp_prequeue use 
skb_dst_force_safe, so i just renamed it there to skb_dst_force )

This is what i get on PPPoE BRAS on this kernel, patch applied
(no idea if its related to patch, but just mentioning i applied it, as 
it's not vanilla 4.13.3)

[ 7858.579600] ------------[ cut here ]------------
[ 7858.579818] WARNING: CPU: 2 PID: 0 at ./include/net/dst.h:254 
nf_xfrm_me_harder+0x61/0xec [nf_nat]
[ 7858.580160] Modules linked in: cls_fw act_police cls_u32 sch_ingress 
sch_htb pppoe pppox ppp_generic slhc netconsole configfs coretemp 
nf_nat_pptp nf_nat_proto_gre nf_conntrack_pptp nf_conntrack_proto_gre 
tun xt_REDIRECT nf_nat_redirect xt_nat xt_TCPMSS ipt_REJECT 
nf_reject_ipv4 xt_set ts_bm xt_string xt_connmark xt_DSCP xt_mark 
xt_tcpudp ip_set_hash_net ip_set_hash_ip ip_set nfnetlink iptable_mangle 
iptable_filter iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 
nf_nat nf_conntrack ip_tables x_tables 8021q garp mrp stp llc ixgbe dca
[ 7858.581255] CPU: 2 PID: 0 Comm: swapper/2 Not tainted 
4.13.3-build-0133 #27
[ 7858.581456] Hardware name: HP ProLiant DL320e Gen8 v2, BIOS P80 
04/02/2015
[ 7858.581659] task: ffff880434e6a700 task.stack: ffffc90001904000
[ 7858.581862] RIP: 0010:nf_xfrm_me_harder+0x61/0xec [nf_nat]
[ 7858.582061] RSP: 0018:ffff880436483bc0 EFLAGS: 00010246
[ 7858.582259] RAX: 0000000000000000 RBX: ffffffff822df000 RCX: 
ffff8803ee9028ce
[ 7858.582461] RDX: 0000000000000014 RSI: ffff88041cd82900 RDI: 
ffff880436483bf8
[ 7858.582661] RBP: ffff880436483c20 R08: ffffffff81e0b400 R09: 
00000000b9160000
[ 7858.582865] R10: ffff8803ee9028e8 R11: 0000000000000000 R12: 
ffff880401e92100
[ 7858.583068] R13: 0000000000000001 R14: ffffffff822df000 R15: 
ffff88042e280078
[ 7858.583269] FS:  0000000000000000(0000) GS:ffff880436480000(0000) 
knlGS:0000000000000000
[ 7858.583608] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 7858.583809] CR2: 00007f9b2886fc9c CR3: 0000000429223000 CR4: 
00000000001406e0
[ 7858.584013] Call Trace:
[ 7858.584209]  <IRQ>
[ 7858.584408]  ? nf_nat_ipv4_fn+0x12e/0x189 [nf_nat_ipv4]
[ 7858.584605]  nf_nat_ipv4_out+0xb6/0xd3 [nf_nat_ipv4]
[ 7858.584807]  iptable_nat_ipv4_out+0x15/0x17 [iptable_nat]
[ 7858.585010]  nf_hook_slow+0x2a/0x9a
[ 7858.585209]  ip_output+0x96/0xb4
[ 7858.585410]  ? ip_fragment.constprop.5+0x7c/0x7c
[ 7858.585610]  ip_forward_finish+0x5b/0x60
[ 7858.585811]  ip_forward+0x36d/0x37a
[ 7858.586010]  ? ip_frag_mem+0x11/0x11
[ 7858.586207]  ip_rcv_finish+0x2f9/0x304
[ 7858.586406]  ip_rcv+0x32a/0x337
[ 7858.586604]  ? ip_local_deliver_finish+0x1bb/0x1bb
[ 7858.586808]  __netif_receive_skb_core+0x4f0/0x847
[ 7858.587009]  __netif_receive_skb+0x18/0x5a
[ 7858.587208]  ? __netif_receive_skb+0x18/0x5a
[ 7858.587407]  process_backlog+0xa4/0x127
[ 7858.587606]  net_rx_action+0x11e/0x2d8
[ 7858.587811]  ? sched_clock_cpu+0x15/0x9b
[ 7858.588013]  __do_softirq+0xe7/0x23a
[ 7858.588210]  irq_exit+0x52/0x93
[ 7858.588408]  smp_call_function_single_interrupt+0x33/0x35
[ 7858.588610]  call_function_single_interrupt+0x83/0x90
[ 7858.588811] RIP: 0010:mwait_idle+0x93/0x13c
[ 7858.589007] RSP: 0018:ffffc90001907eb0 EFLAGS: 00000246 ORIG_RAX: 
ffffffffffffff04
[ 7858.589347] RAX: 0000000000000000 RBX: ffff880434e6a700 RCX: 
0000000000000000
[ 7858.589548] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 
0000000000000000
[ 7858.589750] RBP: ffffc90001907ec0 R08: 0000000000000000 R09: 
0000000000000001
[ 7858.589952] R10: ffffc90001907e58 R11: 000000000000024d R12: 
0000000000000002
[ 7858.590149] R13: 0000000000000000 R14: ffff880434e6a700 R15: 
ffff880434e6a700
[ 7858.590347]  </IRQ>
[ 7858.590541]  arch_cpu_idle+0xf/0x11
[ 7858.590738]  default_idle_call+0x25/0x27
[ 7858.590938]  do_idle+0xb8/0x150
[ 7858.591133]  cpu_startup_entry+0x1f/0x21
[ 7858.591332]  start_secondary+0xe8/0xeb
[ 7858.591531]  secondary_startup_64+0x9f/0x9f
[ 7858.591729] Code: 83 7e 48 00 74 07 48 8b b6 80 01 00 00 8b 86 80 00 
00 00 85 c0 74 14 8d 50 01 f0 0f b1 96 80 00 00 00 0f 94 c2 84 d2 75 04 
eb e8 <0f> ff 49 8b 4c 24 18 48 8d 55 a0 45 31 c0 48 89 df e8 d9 de 95
[ 7858.592239] ---[ end trace c089174999ff4fc3 ]---
[ 7858.592448] dst_release: dst:ffff88041cd82900 refcnt:-1
[ 8139.130003] igb 0000:07:00.0 eth0: igb: eth0 NIC Link is Down
[ 8139.130309] igb 0000:07:00.0 eth0: Reset adapter
[ 8164.431523] igb 0000:07:00.0 eth0: igb: eth0 NIC Link is Up 1000 Mbps 
Full Duplex, Flow Control: RX/TX
[ 9149.190518] perf: interrupt took too long (3132 > 3128), lowering 
kernel.perf_event_max_sample_rate to 63000
[17205.528640] ------------[ cut here ]------------
[17205.528855] WARNING: CPU: 0 PID: 0 at ./include/net/dst.h:254 
nf_xfrm_me_harder+0x61/0xec [nf_nat]
[17205.529197] Modules linked in: cls_fw act_police cls_u32 sch_ingress 
sch_htb pppoe pppox ppp_generic slhc netconsole configfs coretemp 
nf_nat_pptp nf_nat_proto_gre nf_conntrack_pptp nf_conntrack_proto_gre 
tun xt_REDIRECT nf_nat_redirect xt_nat xt_TCPMSS ipt_REJECT 
nf_reject_ipv4 xt_set ts_bm xt_string xt_connmark xt_DSCP xt_mark 
xt_tcpudp ip_set_hash_net ip_set_hash_ip ip_set nfnetlink iptable_mangle 
iptable_filter iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 
nf_nat nf_conntrack ip_tables x_tables 8021q garp mrp stp llc ixgbe dca
[17205.530294] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G        W       
4.13.3-build-0133 #27
[17205.530632] Hardware name: HP ProLiant DL320e Gen8 v2, BIOS P80 
04/02/2015
[17205.530834] task: ffffffff8220e480 task.stack: ffffffff82200000
[17205.531033] RIP: 0010:nf_xfrm_me_harder+0x61/0xec [nf_nat]
[17205.531232] RSP: 0018:ffff880436403bc0 EFLAGS: 00010246
[17205.531434] RAX: 0000000000000000 RBX: ffffffff822df000 RCX: 
ffff8803f5fba0ce
[17205.531636] RDX: 0000000000000014 RSI: ffff8804041ae100 RDI: 
ffff880436403bf8
[17205.531836] RBP: ffff880436403c20 R08: ffffffff81e0b400 R09: 
0000000033d10000
[17205.532035] R10: ffff8803f5fba0e8 R11: 0000000000000000 R12: 
ffff88041e7a3500
[17205.532235] R13: 0000000000000001 R14: ffffffff822df000 R15: 
ffff88042e280078
[17205.532435] FS:  0000000000000000(0000) GS:ffff880436400000(0000) 
knlGS:0000000000000000
[17205.532775] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[17205.532974] CR2: 00007f9b2c6b52b8 CR3: 0000000429223000 CR4: 
00000000001406f0
[17205.533170] Call Trace:
[17205.533361]  <IRQ>
[17205.533555]  ? nf_nat_ipv4_fn+0x12e/0x189 [nf_nat_ipv4]
[17205.533754]  nf_nat_ipv4_out+0xb6/0xd3 [nf_nat_ipv4]
[17205.533953]  iptable_nat_ipv4_out+0x15/0x17 [iptable_nat]
[17205.534151]  nf_hook_slow+0x2a/0x9a
[17205.534344]  ip_output+0x96/0xb4
[17205.534539]  ? ip_fragment.constprop.5+0x7c/0x7c
[17205.534738]  ip_forward_finish+0x5b/0x60
[17205.534939]  ip_forward+0x36d/0x37a
[17205.535137]  ? ip_frag_mem+0x11/0x11
[17205.535337]  ip_rcv_finish+0x2f9/0x304
[17205.535537]  ip_rcv+0x32a/0x337
[17205.535732]  ? ip_local_deliver_finish+0x1bb/0x1bb
[17205.535935]  __netif_receive_skb_core+0x4f0/0x847
[17205.536135]  __netif_receive_skb+0x18/0x5a
[17205.536332]  ? __netif_receive_skb+0x18/0x5a
[17205.536533]  process_backlog+0xa4/0x127
[17205.536731]  net_rx_action+0x11e/0x2d8
[17205.536934]  ? sched_clock_cpu+0x15/0x9b
[17205.537134]  __do_softirq+0xe7/0x23a
[17205.537331]  irq_exit+0x52/0x93
[17205.537530]  smp_call_function_single_interrupt+0x33/0x35
[17205.537730]  call_function_single_interrupt+0x83/0x90
[17205.537934] RIP: 0010:mwait_idle+0x93/0x13c
[17205.538131] RSP: 0018:ffffffff82203e28 EFLAGS: 00000246 ORIG_RAX: 
ffffffffffffff04
[17205.538469] RAX: 0000000000000000 RBX: ffffffff8220e480 RCX: 
0000000000000000
[17205.538668] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 
0000000000000000
[17205.538871] RBP: ffffffff82203e38 R08: 0000000000000000 R09: 
0000000000000001
[17205.539071] R10: ffffffff82203dd0 R11: 000000000000002a R12: 
0000000000000000
[17205.539271] R13: 0000000000000000 R14: ffffffff8220e480 R15: 
ffffffff8220e480
[17205.539472]  </IRQ>
[17205.539670]  arch_cpu_idle+0xf/0x11
[17205.539869]  default_idle_call+0x25/0x27
[17205.540068]  do_idle+0xb8/0x150
[17205.540266]  cpu_startup_entry+0x1f/0x21
[17205.540465]  rest_init+0xb5/0xb7
[17205.540665]  start_kernel+0x3b0/0x3bd
[17205.540864]  x86_64_start_reservations+0x2a/0x2c
[17205.541063]  x86_64_start_kernel+0x16a/0x178
[17205.541262]  secondary_startup_64+0x9f/0x9f
[17205.541458] Code: 83 7e 48 00 74 07 48 8b b6 80 01 00 00 8b 86 80 00 
00 00 85 c0 74 14 8d 50 01 f0 0f b1 96 80 00 00 00 0f 94 c2 84 d2 75 04 
eb e8 <0f> ff 49 8b 4c 24 18 48 8d 55 a0 45 31 c0 48 89 df e8 d9 de 95
[17205.541964] ---[ end trace c089174999ff4fc4 ]---
[17205.542165] dst_release: dst:ffff8804041ae100 refcnt:-1
