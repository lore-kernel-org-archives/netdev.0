From: Arturas <arturasl@res.lt>
Subject: NULL pointer deref using bridge and bridge-nf-call-iptables = 1
Date: Thu, 7 Apr 2011 12:32:48 +0300
Message-ID: <B086D18A-441E-4452-B702-FE2E6781C883@res.lt>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: multipart/mixed; boundary=Apple-Mail-12--408462389
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.res.lt ([84.32.72.39]:60825 "EHLO mx.res.lt"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751646Ab1DGJly (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2011 05:41:54 -0400
Received: from localhost (localhost [127.0.0.1])
	by mx.res.lt (Postfix) with ESMTP id 889937F86
	for <netdev@vger.kernel.org>; Thu,  7 Apr 2011 12:32:49 +0300 (EEST)
Received: from [192.168.0.36] (unknown [84.32.134.3])
	by mx.res.lt (Postfix) with ESMTP id A33E97F82
	for <netdev@vger.kernel.org>; Thu,  7 Apr 2011 12:32:48 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail-12--408462389
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Hi,

i'm getting "BUG: unable to handle kernel NULL pointer dereference at =
0000000000000134" when=20
using bridge with bridge-nf-call-iptables =3D 1. When i set =
bridge-nf-call-iptables =3D 0 problem goes away.
I'm using 2.6.38-gentoo-r1, but the same problem was in 2.6.37. 2.6.35 =
hasn't this bug. I can't reproduce=20
this problem, because it happens random, sometimes after a day and =
sometimes after few minutes.=20
So i hope that trace will help. Iptables haven't any rules and br0 =
hasn't any ip address.
 If you need more info just say what do you need.



--Apple-Mail-12--408462389
Content-Disposition: attachment;
	filename=bug
Content-Type: application/octet-stream;
	name="bug"
Content-Transfer-Encoding: 7bit

[173749.190643] BUG: unable to handle kernel NULL pointer dereference at 0000000000000134
[173749.199474] IP: [<ffffffff81365e19>] ip_options_compile+0x2a9/0x5c0
[173749.206557] PGD 0 
[173749.208896] Oops: 0000 [#1] SMP 
[173749.212599] last sysfs file: /sys/devices/system/clocksource/clocksource0/current_clocksource
[173749.222183] CPU 11 
[173749.224418] Modules linked in: iptable_filter xt_conntrack ip_tables x_tables cls_u32 sch_htb ipmi_watchdog ipmi_devintf ipmi_si nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack igb ixgbe mdio
[173749.243629] 
[173749.245381] Pid: 0, comm: kworker/0:1 Not tainted 2.6.38-gentoo-r1 #1 Intel Corporation S5520UR/S5520UR
[173749.255974] RIP: 0010:[<ffffffff81365e19>]  [<ffffffff81365e19>] ip_options_compile+0x2a9/0x5c0
[173749.265764] RSP: 0018:ffff8801efd43b20  EFLAGS: 00010286
[173749.271767] RAX: 0000000000000024 RBX: ffff8801d646b6c0 RCX: ffffffff81718440
[173749.279801] RDX: ffff8801d1646065 RSI: 0000000000000027 RDI: ffffffff81718440
[173749.287836] RBP: ffff8801d646b6e8 R08: ffff8801efd43b50 R09: 1845c8a0ce512957
[173749.295869] R10: 431bde82d7b634db R11: 0000000000000134 R12: ffff8801d1646063
[173749.303904] R13: 0000000000000027 R14: 0000000000000027 R15: ffff8801d164604e
[173749.311939] FS:  0000000000000000(0000) GS:ffff8801efd40000(0000) knlGS:0000000000000000
[173749.321036] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[173749.327523] CR2: 0000000000000134 CR3: 0000000001563000 CR4: 00000000000006e0
[173749.335558] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[173749.343592] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[173749.351627] Process kworker/0:1 (pid: 0, threadinfo ffff88012c3c6000, task ffff88012c3a1000)
[173749.361110] Stack:
[173749.363440]  ffff8801e580a000 ffffffff813ec2b8 ffff880100000001 0000000000000000
[173749.371797]  ffffffff815c7220 ffffffff8135cc94 ffffffff813ec0d0 ffff880180000000
[173749.380155]  0000000000000041 ffff8801d646b6c0 ffff8801d646b6e8 ffff8801eb690000
[173749.388513] Call Trace:
[173749.391326]  <IRQ> 
[173749.393767]  [<ffffffff813ec2b8>] ? br_nf_pre_routing_finish+0x1e8/0x350
[173749.401320]  [<ffffffff8135cc94>] ? nf_hook_slow+0x64/0x110
[173749.407614]  [<ffffffff813ec0d0>] ? br_nf_pre_routing_finish+0x0/0x350
[173749.414969]  [<ffffffff813eb289>] ? br_parse_ip_options+0xd9/0x210
[173749.421940]  [<ffffffff813ec70a>] ? br_nf_pre_routing+0x2ea/0x7e0
[173749.428814]  [<ffffffff8135cc05>] ? nf_iterate+0x85/0xb0
[173749.434821]  [<ffffffffa0036de6>] ? ixgbe_msix_clean_many+0x106/0x110 [ixgbe]
[173749.442857]  [<ffffffff813e6cc0>] ? br_handle_frame_finish+0x0/0x1c0
[173749.450021]  [<ffffffff8135cc94>] ? nf_hook_slow+0x64/0x110
[173749.456316]  [<ffffffff813e6cc0>] ? br_handle_frame_finish+0x0/0x1c0
[173749.463482]  [<ffffffff8107d2e8>] ? handle_edge_irq+0x68/0x160
[173749.470066]  [<ffffffff813e7009>] ? br_handle_frame+0x189/0x240
[173749.476749]  [<ffffffff81332099>] ? __alloc_skb+0x79/0x170
[173749.482948]  [<ffffffff813e6e80>] ? br_handle_frame+0x0/0x240
[173749.489438]  [<ffffffff81338ce2>] ? __netif_receive_skb+0x1a2/0x3d0
[173749.496506]  [<ffffffff81339b18>] ? netif_receive_skb+0x78/0x80
[173749.503187]  [<ffffffff8133a17b>] ? napi_gro_receive+0xbb/0xd0
[173749.509771]  [<ffffffff81339c48>] ? napi_skb_finish+0x38/0x50
[173749.516261]  [<ffffffffa003c5ae>] ? ixgbe_clean_rx_irq+0x50e/0x730 [ixgbe]
[173749.524005]  [<ffffffffa003cb85>] ? ixgbe_clean_rxtx_many+0xe5/0x1e0 [ixgbe]
[173749.531946]  [<ffffffff813fc553>] ? ret_from_intr+0x0/0x15
[173749.538143]  [<ffffffff8133a2ea>] ? net_rx_action+0x9a/0x1c0
[173749.544537]  [<ffffffff8104c929>] ? __do_softirq+0x99/0x130
[173749.550833]  [<ffffffff810033dc>] ? call_softirq+0x1c/0x30
[173749.557030]  [<ffffffff81005225>] ? do_softirq+0x65/0xa0
[173749.563034]  [<ffffffff810047ac>] ? do_IRQ+0x5c/0xd0
[173749.568652]  [<ffffffff813fc553>] ? ret_from_intr+0x0/0x15
[173749.574849]  <EOI> 
[173749.577285]  [<ffffffff8100abba>] ? mwait_idle+0x6a/0x80
[173749.583289]  [<ffffffff81001796>] ? cpu_idle+0x56/0xa0
[173749.589098] Code: 0f b6 44 24 02 49 8d 54 24 02 3c 03 0f 86 a4 00 00 00 0f b6 f0 41 39 f6 7c 27 83 c6 03 41 39 f6 0f 8c 90 00 00 00 48 85 db 74 0f <41> 8b 33 0f b6 c0 41 89 74 04 ff 80 4d 08 04 80 02 04 80 4d 08 
[173749.610788] RIP  [<ffffffff81365e19>] ip_options_compile+0x2a9/0x5c0
[173749.617965]  RSP <ffff8801efd43b20>
[173749.621939] CR2: 0000000000000134
[173749.626162] ---[ end trace 1cb4ae9fb583dc44 ]---
[173749.631392] Kernel panic - not syncing: Fatal exception in interrupt
[173749.638556] Pid: 0, comm: kworker/0:1 Tainted: G      D     2.6.38-gentoo-r1 #1
[173749.646783] Call Trace:
[173749.649596]  <IRQ>  [<ffffffff813f9935>] ? panic+0x92/0x194
[173749.655903]  [<ffffffff810474c1>] ? kmsg_dump+0x41/0x100
[173749.661907]  [<ffffffff81006543>] ? oops_end+0xa3/0xb0
[173749.667721]  [<ffffffff81026ce3>] ? no_context+0x103/0x270
[173749.673918]  [<ffffffff810274c9>] ? do_page_fault+0x289/0x430
[173749.680407]  [<ffffffff813ebd78>] ? br_nf_forward_ip+0x2e8/0x3b0
[173749.687187]  [<ffffffffa0003bec>] ? ____nf_conntrack_find+0xdc/0x120 [nf_conntrack]
[173749.695802]  [<ffffffff8135cc05>] ? nf_iterate+0x85/0xb0
[173749.701808]  [<ffffffff813e5ff0>] ? br_forward_finish+0x0/0x60
[173749.708395]  [<ffffffff813fc7a5>] ? page_fault+0x25/0x30
[173749.714401]  [<ffffffff81365e19>] ? ip_options_compile+0x2a9/0x5c0
[173749.721371]  [<ffffffff813ec2b8>] ? br_nf_pre_routing_finish+0x1e8/0x350
[173749.728923]  [<ffffffff8135cc94>] ? nf_hook_slow+0x64/0x110
[173749.735216]  [<ffffffff813ec0d0>] ? br_nf_pre_routing_finish+0x0/0x350
[173749.742574]  [<ffffffff813eb289>] ? br_parse_ip_options+0xd9/0x210
[173749.749545]  [<ffffffff813ec70a>] ? br_nf_pre_routing+0x2ea/0x7e0
[173749.756420]  [<ffffffff8135cc05>] ? nf_iterate+0x85/0xb0
[173749.762425]  [<ffffffffa0036de6>] ? ixgbe_msix_clean_many+0x106/0x110 [ixgbe]
[173749.770462]  [<ffffffff813e6cc0>] ? br_handle_frame_finish+0x0/0x1c0
[173749.777626]  [<ffffffff8135cc94>] ? nf_hook_slow+0x64/0x110
[173749.783920]  [<ffffffff813e6cc0>] ? br_handle_frame_finish+0x0/0x1c0
[173749.791085]  [<ffffffff8107d2e8>] ? handle_edge_irq+0x68/0x160
[173749.797668]  [<ffffffff813e7009>] ? br_handle_frame+0x189/0x240
[173749.804351]  [<ffffffff81332099>] ? __alloc_skb+0x79/0x170
[173749.810548]  [<ffffffff813e6e80>] ? br_handle_frame+0x0/0x240
[173749.817037]  [<ffffffff81338ce2>] ? __netif_receive_skb+0x1a2/0x3d0
[173749.824105]  [<ffffffff81339b18>] ? netif_receive_skb+0x78/0x80
[173749.830786]  [<ffffffff8133a17b>] ? napi_gro_receive+0xbb/0xd0
[173749.837370]  [<ffffffff81339c48>] ? napi_skb_finish+0x38/0x50
[173749.843859]  [<ffffffffa003c5ae>] ? ixgbe_clean_rx_irq+0x50e/0x730 [ixgbe]
[173749.851605]  [<ffffffffa003cb85>] ? ixgbe_clean_rxtx_many+0xe5/0x1e0 [ixgbe]
[173749.859544]  [<ffffffff813fc553>] ? ret_from_intr+0x0/0x15
[173749.865741]  [<ffffffff8133a2ea>] ? net_rx_action+0x9a/0x1c0
[173749.872133]  [<ffffffff8104c929>] ? __do_softirq+0x99/0x130
[173749.878430]  [<ffffffff810033dc>] ? call_softirq+0x1c/0x30
[173749.884629]  [<ffffffff81005225>] ? do_softirq+0x65/0xa0
[173749.890632]  [<ffffffff810047ac>] ? do_IRQ+0x5c/0xd0
[173749.896251]  [<ffffffff813fc553>] ? ret_from_intr+0x0/0x15
[173749.902447]  <EOI>  [<ffffffff8100abba>] ? mwait_idle+0x6a/0x80
[173749.909140]  [<ffffffff81001796>] ? cpu_idle+0x56/0xa0

--Apple-Mail-12--408462389--
