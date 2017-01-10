From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: 4.9.2 panic, __skb_flow_dissect, gro?
Date: Wed, 11 Jan 2017 01:26:52 +0200
Message-ID: <359da98eb44a5a9f9f286cc380143654@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:37574 "EHLO nuclearcat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751861AbdAJX04 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Jan 2017 18:26:56 -0500
Received: from localhost (localhost [127.0.0.1])
        by nuclearcat.com (Postfix) with ESMTP id 7105A67C353B
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 23:26:54 +0000 (UTC)
Received: from nuclearcat.com ([127.0.0.1])
        by localhost (nuclearcat.com [127.0.0.1]) (amavisd-new, port 10024)
        with ESMTP id a91ekQihai6E for <netdev@vger.kernel.org>;
        Tue, 10 Jan 2017 23:26:52 +0000 (UTC)
Received: from germany.nuclearcat.com (localhost [127.0.0.1])
        (Authenticated sender: nuclearcat@nuclearcat.com)
        by nuclearcat.com (Postfix) with ESMTPA id 9FB0C67C0265
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 23:26:52 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Got panic message on 4.9.2 with latest patches from stable-queue, 
probably it affects all 4.9 version

Panic message:

dmesg-erst-6374119981415661569:<6>[   23.110324] ip_set: protocol 6
dmesg-erst-6374119981415661569:<1>[   28.117455] BUG: unable to handle 
kernel NULL pointer dereference at 0000000000000078
dmesg-erst-6374119981415661569:<1>[   28.118036] IP: 
[<ffffffff8188f9de>] __skb_flow_dissect+0x73f/0x931
dmesg-erst-6374119981415661569:<4>[   28.118360] PGD 0
dmesg-erst-6374119981415661569:<4>[   28.118427]
dmesg-erst-6374119981415661569:<4>[   28.118730] Oops: 0000 [#1] SMP
dmesg-erst-6374119981415661569:<4>[   28.118977] Modules linked in: 
xt_TCPMSS xt_connmark ipt_MASQUERADE nf_nat_masquerade_ipv4 xt_nat 
xt_rateest xt_RATEEST nf_conntrack_pptp nf_conntrack_proto_gre xt_CT 
xt_set xt_hl xt_tcpudp ip_set_hash_net ip_set nfnetlink iptable_raw 
iptable_mangle iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 
nf_nat nf_conntrack iptable_filter ip_tables x_tables 8021q garp mrp stp 
llc netconsole configfs bonding ixgbe dca ipmi_watchdog ipmi_si 
acpi_ipmi ipmi_msghandler
dmesg-erst-6374119981415661569:<4>[   28.122784] CPU: 4 PID: 0 Comm: 
swapper/4 Not tainted 4.9.2-build-0127 #3
dmesg-erst-6374119981415661569:<4>[   28.123042] Hardware name: Intel 
Corporation S2600WTT/S2600WTT, BIOS SE5C610.86B.01.01.0019.101220160604 
10/12/2016
dmesg-erst-6374119981415661569:<4>[   28.123488] task: ffff882fa6af24c0 
task.stack: ffffc90031338000
dmesg-erst-6374119981415661569:<4>[   28.123742] RIP: 
0010:[<ffffffff8188f9de>]  [<ffffffff8188f9de>] 
__skb_flow_dissect+0x73f/0x931
dmesg-erst-6374119981415661569:<4>[   28.124243] RSP: 
0018:ffff882fbfb03ce8  EFLAGS: 00010206
dmesg-erst-6374119981415661569:<4>[   28.124497] RAX: 0000000000000130 
RBX: 0000000000000022 RCX: ffff882f9eabb000
dmesg-erst-6374119981415661569:<4>[   28.124756] RDX: 0000000000000010 
RSI: ffff882f9eabb026 RDI: 000000000000002f
dmesg-erst-6374119981415661569:<4>[   28.125015] RBP: ffff882fbfb03d78 
R08: 000000000000000c R09: ffff882f9eabb022
dmesg-erst-6374119981415661569:<4>[   28.125275] R10: 0000000000000140 
R11: 0000000000000001 R12: 0000000000000b88
dmesg-erst-6374119981415661569:<4>[   28.125532] R13: ffff882fbfb03d9c 
R14: 0000000000000000 R15: ffffffff820c11a0
dmesg-erst-6374119981415661569:<4>[   28.125792] FS:  
0000000000000000(0000) GS:ffff882fbfb00000(0000) knlGS:0000000000000000
dmesg-erst-6374119981415661569:<4>[   28.126227] CS:  0010 DS: 0000 ES: 
0000 CR0: 0000000080050033
dmesg-erst-6374119981415661569:<4>[   28.126482] CR2: 0000000000000078 
CR3: 000000607f007000 CR4: 00000000001406e0
dmesg-erst-6374119981415661569:<4>[   28.126741] Stack:
dmesg-erst-6374119981415661569:<4>[   28.126983]  ffff882fbfb03cf8 
ffffffff81885afb 00000001bfb03d88 ffffffff818953b5
dmesg-erst-6374119981415661569:<4>[   28.127675]  ffff882fbfb03d9c 
2f00000800000000 ffff882f9eabb000 ffff882fbfb03d48
dmesg-erst-6374119981415661569:<4>[   28.128350]  ffffffff818ef3e4 
ffff882fa4177400 000000000000004e 0000000000000000
dmesg-erst-6374119981415661569:<4>[   28.129027] Call Trace:
dmesg-erst-6374119981415661569:<4>[   28.129271]  <IRQ>
dmesg-erst-6374119981415661569:<4>[   28.129340]  [<ffffffff81885afb>] ? 
kfree_skb+0x25/0x27
dmesg-erst-6374119981415661569:<4>[   28.129655]  [<ffffffff818953b5>] ? 
__netif_receive_skb_core+0x61b/0x807
dmesg-erst-6374119981415661569:<4>[   28.129917]  [<ffffffff818ef3e4>] ? 
udp4_gro_receive+0x1f6/0x256
dmesg-erst-6374119981415661569:<4>[   28.130174]  [<ffffffff818b43d3>] 
eth_get_headlen+0x4c/0x82
dmesg-erst-6374119981415661569:<4>[   28.130435]  [<ffffffffa003624f>] 
ixgbe_clean_rx_irq+0x546/0x924 [ixgbe]
dmesg-erst-6374119981415661569:<4>[   28.130694]  [<ffffffffa003723a>] 
ixgbe_poll+0x4ef/0x679 [ixgbe]
dmesg-erst-6374119981415661569:<4>[   28.130952]  [<ffffffff81896b60>] 
net_rx_action+0x107/0x27d
dmesg-erst-6374119981415661569:<4>[   28.131207]  [<ffffffff810d18c8>] 
__do_softirq+0xb5/0x1a3
dmesg-erst-6374119981415661569:<4>[   28.131460]  [<ffffffff810d1b2d>] 
irq_exit+0x4d/0x8e
dmesg-erst-6374119981415661569:<4>[   28.131712]  [<ffffffff81016bb7>] 
do_IRQ+0xaa/0xc2
dmesg-erst-6374119981415661569:<4>[   28.131965]  [<ffffffff8191483c>] 
common_interrupt+0x7c/0x7c
dmesg-erst-6374119981415661569:<4>[   28.132217]  <EOI>
dmesg-erst-6374119981415661569:<4>[   28.132286]  [<ffffffff81913936>] ? 
mwait_idle+0x4e/0x61
dmesg-erst-6374119981415661569:<4>[   28.132773]  [<ffffffff8101cb40>] 
arch_cpu_idle+0xa/0xc
dmesg-erst-6374119981415661569:<4>[   28.133026]  [<ffffffff81913a4b>] 
default_idle_call+0x20/0x22
dmesg-erst-6374119981415661569:<4>[   28.133282]  [<ffffffff810fa1a5>] 
cpu_startup_entry+0xde/0x185
dmesg-erst-6374119981415661569:<4>[   28.133539]  [<ffffffff8102bda3>] 
start_secondary+0xe8/0xeb
dmesg-erst-6374119981415661569:<4>[   28.133792] Code: f7 e8 eb 63 ff ff 
85 c0 0f 88 d5 01 00 00 44 8b 45 80 48 8d 75 b0 66 44 8b 66 0c 41 83 c0 
0e e9 87 00 00 00 41 8d 50 04 66 85 c0 <41> 8b 46 78 44 0f 48 c2 41 2b 
46 7c 42 8d 34 03 29 f0 83 f8 03
dmesg-erst-6374119981415661569:<1>[   28.138401] RIP  
[<ffffffff8188f9de>] __skb_flow_dissect+0x73f/0x931
dmesg-erst-6374119981415661569:<4>[   28.138718]  RSP <ffff882fbfb03ce8>
dmesg-erst-6374119981415661569:<4>[   28.138964] CR2: 0000000000000078
dmesg-erst-6374119981415661569:<4>[   28.139215] ---[ end trace 
46fb1cf5af272d67 ]---
