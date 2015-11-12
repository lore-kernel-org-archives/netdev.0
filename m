From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [linux-4.4-mw] BUG: unable to handle kernel paging request
 ip_vs_out.constprop
Date: Thu, 12 Nov 2015 06:09:13 -0800
Message-ID: <1447337353.22599.14.camel@edumazet-glaptop2.roam.corp.google.com>
References: <06dc952f98f54da2c4d85b31e5fa9826@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36416 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932079AbbKLOJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2015 09:09:15 -0500
In-Reply-To: <06dc952f98f54da2c4d85b31e5fa9826@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-11-12 at 11:08 +0100, Sander Eikelenboom wrote:
> Hi All,
> 
> Just got a crash with a linux-4.4-mw kernel.
> I'm using a routed bridge and apart from the splat below i have got some 
> interesting other messages that aren't there in 4.3 (and perhaps are of 
> interest for the crash as well):
> [  207.033768] vif vif-1-0 vif1.0: set_features() failed (-1); wanted 
> 0x0000000400004803, left 0x0000000400114813
> [  207.033780] vif vif-1-0 vif1.0: set_features() failed (-1); wanted 
> 0x0000000400004803, left 0x0000000400114813
> [  207.245435] xen_bridge: error setting offload STP state on port 
> 1(vif1.0)
> [  207.245442] vif vif-1-0 vif1.0: failed to set HW ageing time
> [  207.245443] xen_bridge: error setting offload STP state on port 
> 1(vif1.0)
> [  207.245491] vif vif-1-0 vif1.0: set_features() failed (-1); wanted 
> 0x0000000400004803, left 0x0000000400114813
> 
> The commit message for the commit that introduced the "set HW ageing 
> time" error message, doesn't seem to tell
> me much about it's purpose. If it's not related i can reported as a 
> seperate issue.
> 
> --
> Sander
> 
> The crash:
> [  354.328687] BUG: unable to handle kernel paging request at 
> ffff880049aa8000
> [  354.350206] IP: [<ffffffff81a074a7>] ip_vs_out.constprop.25+0x47/0x60
> [  354.360882] PGD 2212067 PUD 25b4067 PMD 5ffb6067 PTE 0
> [  354.371587] Oops: 0000 [#1] SMP
> [  354.382143] Modules linked in:
> [  354.392537] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 
> 4.3.0-mw-20151111-linus-doflr+ #1
> [  354.403105] Hardware name: MSI MS-7640/890FXA-GD70 (MS-7640)  , BIOS 
> V1.8B1 09/13/2010
> [  354.413666] task: ffffffff82218580 ti: ffffffff82200000 task.ti: 
> ffffffff82200000
> [  354.424255] RIP: e030:[<ffffffff81a074a7>]  [<ffffffff81a074a7>] 
> ip_vs_out.constprop.25+0x47/0x60
> [  354.434742] RSP: e02b:ffff88005f6034b0  EFLAGS: 00010246
> [  354.445006] RAX: 0000000000000001 RBX: ffff88005f6034f8 RCX: 
> ffff880049aa7ce0
> [  354.455262] RDX: ffff88003c0e5500 RSI: 0000000000000003 RDI: 
> ffff880004e0e800
> [  354.465422] RBP: ffff88005f6034b8 R08: 0000000000000014 R09: 
> 0000000000000003
> [  354.475508] R10: 0000000000000001 R11: ffff880040f394cc R12: 
> ffff88005f603528
> [  354.485567] R13: ffff88003c0e5500 R14: ffffffff822da2e8 R15: 
> ffff88003c0e5500
> [  354.495595] FS:  00007f0243c2b700(0000) GS:ffff88005f600000(0000) 
> knlGS:0000000000000000
> [  354.505474] CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  354.515135] CR2: ffff880049aa8000 CR3: 0000000059271000 CR4: 
> 0000000000000660
> [  354.524794] Stack:
> [  354.534319]  ffffffff81a074fc ffff88005f6034e8 ffffffff8199e138 
> ffff88003c0e5500
> [  354.543981]  ffff88005f603528 ffff88003c0e5500 0000000000000000 
> ffff88005f603518
> [  354.553577]  ffffffff8199e1af ffff880005300048 ffff88003c0e5500 
> ffffffff822da2e8
> [  354.563160] Call Trace:
> [  354.572418]  <IRQ>
> [  354.572480]  [<ffffffff81a074fc>] ? ip_vs_local_reply4+0x1c/0x20
> [  354.590458]  [<ffffffff8199e138>] nf_iterate+0x58/0x70
> [  354.599372]  [<ffffffff8199e1af>] nf_hook_slow+0x5f/0xb0
> [  354.608245]  [<ffffffff81a1c73e>] __ip_local_out+0x9e/0xb0
> [  354.617036]  [<ffffffff81a1a940>] ? ip_forward_options+0x1a0/0x1a0
> [  354.625874]  [<ffffffff81a1c767>] ip_local_out+0x17/0x40
> [  354.634383]  [<ffffffff81a1c8d8>] ip_build_and_send_pkt+0x148/0x1c0
> [  354.642715]  [<ffffffff81a39796>] tcp_v4_send_synack+0x56/0xa0
> [  354.650893]  [<ffffffff81a22b88>] ? 
> inet_csk_reqsk_queue_hash_add+0x68/0x90
> [  354.659083]  [<ffffffff81a2b98d>] tcp_conn_request+0x95d/0x970
> [  354.667196]  [<ffffffff810ccfa6>] ? __local_bh_enable_ip+0x26/0x90
> [  354.675246]  [<ffffffff81a38bc7>] tcp_v4_conn_request+0x47/0x50
> [  354.683254]  [<ffffffff81a30663>] tcp_rcv_state_process+0x183/0xca0
> [  354.691004]  [<ffffffff81a37a7c>] tcp_v4_do_rcv+0x5c/0x1f0
> [  354.698533]  [<ffffffff81a3a2b7>] tcp_v4_rcv+0x987/0x9a0
> [  354.705968]  [<ffffffff81a5deb8>] ? ipv4_confirm+0x78/0xf0
> [  354.713370]  [<ffffffff81a172f4>] ip_local_deliver_finish+0x84/0x120
> [  354.720739]  [<ffffffff81a17842>] ip_local_deliver+0x42/0xd0
> [  354.728029]  [<ffffffff81a17270>] ? inet_del_offload+0x40/0x40
> [  354.735270]  [<ffffffff81a17496>] ip_rcv_finish+0x106/0x320
> [  354.742413]  [<ffffffff81a17ae1>] ip_rcv+0x211/0x370
> [  354.749268]  [<ffffffff81a17390>] ? 
> ip_local_deliver_finish+0x120/0x120
> [  354.755929]  [<ffffffff8196cd9b>] 
> __netif_receive_skb_core+0x2cb/0x970
> [  354.762535]  [<ffffffff819bb75a>] ? nf_nat_setup_info+0x7a/0x2f0
> [  354.769131]  [<ffffffff8196f381>] __netif_receive_skb+0x11/0x70
> [  354.775481]  [<ffffffff8196f3fe>] 
> netif_receive_skb_internal+0x1e/0x80
> [  354.781638]  [<ffffffff8199e1af>] ? nf_hook_slow+0x5f/0xb0
> [  354.787771]  [<ffffffff8196f469>] netif_receive_skb+0x9/0x10
> [  354.793916]  [<ffffffff81a7a1a8>] br_handle_frame_finish+0x178/0x4b0
> [  354.800077]  [<ffffffff81a5ec07>] ? nf_nat_ipv4_fn+0x167/0x1e0
> [  354.806260]  [<ffffffff81a7a020>] ? br_handle_local_finish+0x50/0x50
> [  354.812405]  [<ffffffff81a85193>] 
> br_nf_pre_routing_finish+0x183/0x360
> [  354.818574]  [<ffffffff81a7a030>] ? br_netif_receive_skb+0x10/0x10
> [  354.824775]  [<ffffffff81a85707>] br_nf_pre_routing+0x2a7/0x380
> [  354.830780]  [<ffffffff81a85010>] ? br_nf_forward_ip+0x3f0/0x3f0
> [  354.836567]  [<ffffffff8199e138>] nf_iterate+0x58/0x70
> [  354.842281]  [<ffffffff8199e1af>] nf_hook_slow+0x5f/0xb0
> [  354.847886]  [<ffffffff81a7a682>] br_handle_frame+0x1a2/0x290
> [  354.853520]  [<ffffffff81a7a030>] ? br_netif_receive_skb+0x10/0x10
> [  354.859206]  [<ffffffff81a7a4e0>] ? 
> br_handle_frame_finish+0x4b0/0x4b0
> [  354.864824]  [<ffffffff8196cbfb>] 
> __netif_receive_skb_core+0x12b/0x970
> [  354.870350]  [<ffffffff810fe841>] ? 
> __raw_callee_save___pv_queued_spin_unlock+0x11/0x20
> [  354.875880]  [<ffffffff8196f381>] __netif_receive_skb+0x11/0x70
> [  354.881293]  [<ffffffff8196f3fe>] 
> netif_receive_skb_internal+0x1e/0x80
> [  354.886653]  [<ffffffff8196f469>] netif_receive_skb+0x9/0x10
> [  354.891918]  [<ffffffff8173c693>] xenvif_tx_action+0x693/0x820
> [  354.897170]  [<ffffffff8173ebf9>] xenvif_poll+0x29/0x70
> [  354.902426]  [<ffffffff819706e7>] net_rx_action+0x1f7/0x300
> [  354.907636]  [<ffffffff810ccda3>] __do_softirq+0x103/0x210
> [  354.912837]  [<ffffffff810cd0ab>] irq_exit+0x4b/0xa0
> [  354.917940]  [<ffffffff814de7d0>] xen_evtchn_do_upcall+0x30/0x40
> [  354.923051]  [<ffffffff81af173e>] 
> xen_do_hypervisor_callback+0x1e/0x40
> [  354.928089]  <EOI>
> [  354.928175]  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
> [  354.938047]  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
> [  354.942985]  [<ffffffff81009420>] ? xen_safe_halt+0x10/0x20
> [  354.947859]  [<ffffffff810193c3>] ? default_idle+0x13/0x20
> [  354.952664]  [<ffffffff810198fa>] ? arch_cpu_idle+0xa/0x10
> [  354.957470]  [<ffffffff810fc25e>] ? default_idle_call+0x2e/0x50
> [  354.962291]  [<ffffffff810fc4f2>] ? cpu_startup_entry+0x272/0x2e0
> [  354.967063]  [<ffffffff81ae89c7>] ? rest_init+0x77/0x80
> [  354.971854]  [<ffffffff82316f43>] ? start_kernel+0x438/0x445
> [  354.976640]  [<ffffffff823164ef>] ? 
> x86_64_start_reservations+0x2a/0x2c
> [  354.981457]  [<ffffffff82319fad>] ? xen_start_kernel+0x555/0x561
> [  354.986277] Code: 48 f7 42 58 fe ff ff ff b8 01 00 00 00 74 13 8b 4f 
> 04 85 c9 74 0a 55 48 89 e5 e8 05 fa ff ff 5d f3 c3 f3 c3 66 83 79 10 02 
> 75 d5 <80> b9 20 03 00 00 00 79 cc c3 66 66 66 66 66 66 2e 0f 1f 84 00
> [  354.996803] RIP  [<ffffffff81a074a7>] 
> ip_vs_out.constprop.25+0x47/0x60
> [  355.002021]  RSP <ffff88005f6034b0>
> [  355.007159] CR2: ffff880049aa8000
> [  355.012294] ---[ end trace 5b3b3b699aee4fc6 ]---
> [  355.017424] Kernel panic - not syncing: Fatal exception in interrupt
> [  355.022732] Kernel Offset: disabled
> (XEN) [2015-11-11 15:45:14.718] Hardware Dom0 crashed: rebooting machine 
> in 5 seconds.
> 
> (gdb) list *0xffffffff81a074a7
> 0xffffffff81a074a7 is in ip_vs_out 
> (net/netfilter/ipvs/ip_vs_core.c:1192).
> 1187		if (unlikely(skb->sk != NULL && hooknum == NF_INET_LOCAL_OUT &&
> 1188			     af == AF_INET)) {
> 1189			struct sock *sk = skb->sk;
> 1190			struct inet_sock *inet = inet_sk(skb->sk);
> 1191
> 1192			if (inet && sk->sk_family == PF_INET && inet->nodefrag)
> 1193				return NF_ACCEPT;
> 1194		}
> 1195
> 1196		if (unlikely(!skb_dst(skb)))
> 

Thanks for the report, please try following patch :

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 1e24fff53e4b..f57b4dcdb233 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1176,6 +1176,7 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
 	struct ip_vs_conn *cp;
+	struct sock *sk;
 
 	EnterFunction(11);
 
@@ -1183,13 +1184,12 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
 	if (skb->ipvs_property)
 		return NF_ACCEPT;
 
+	sk = skb_to_full_sk(skb);
 	/* Bad... Do not break raw sockets */
-	if (unlikely(skb->sk != NULL && hooknum == NF_INET_LOCAL_OUT &&
+	if (unlikely(sk && hooknum == NF_INET_LOCAL_OUT &&
 		     af == AF_INET)) {
-		struct sock *sk = skb->sk;
-		struct inet_sock *inet = inet_sk(skb->sk);
 
-		if (inet && sk->sk_family == PF_INET && inet->nodefrag)
+		if (sk->sk_family == PF_INET && inet_sk(sk)->nodefrag)
 			return NF_ACCEPT;
 	}
 
@@ -1681,6 +1681,7 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int
 	struct ip_vs_conn *cp;
 	int ret, pkts;
 	int conn_reuse_mode;
+	struct sock *sk;
 
 	/* Already marked as IPVS request or reply? */
 	if (skb->ipvs_property)
@@ -1708,12 +1709,11 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int
 	ip_vs_fill_iph_skb(af, skb, false, &iph);
 
 	/* Bad... Do not break raw sockets */
-	if (unlikely(skb->sk != NULL && hooknum == NF_INET_LOCAL_OUT &&
+	sk = skb_to_full_sk(skb);
+	if (unlikely(sk && hooknum == NF_INET_LOCAL_OUT &&
 		     af == AF_INET)) {
-		struct sock *sk = skb->sk;
-		struct inet_sock *inet = inet_sk(skb->sk);
 
-		if (inet && sk->sk_family == PF_INET && inet->nodefrag)
+		if (sk->sk_family == PF_INET && inet_sk(sk)->nodefrag)
 			return NF_ACCEPT;
 	}
 
