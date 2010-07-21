From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: 2.6.34.1, e1000e, VLAN's and kernel BUG
Date: Wed, 21 Jul 2010 17:03:22 +0300
Message-ID: <201007211703.23093.nuclearcat@nuclearcat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>
To: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:34141 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754568Ab0GUOLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 10:11:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I experience similar issue with router , also e1000e and VLAN's, now crashed 
completely different server, with different job (on  this interface only 
PPPoE) but same was : VLAN's on one of interfaces and e1000e driver for 
network card on this interface.

Old report is at
http://marc.info/?l=linux-netdev&m=127101842721222&w=2

Hardware is very different, old one was 04:00.0 Ethernet controller: Intel 
Corporation 80003ES2LAN Gigabit Ethernet Controller (Copper) (rev 01)
and Sun server with Xeon amd64, new one is just Core 2 Quad with 32-bit 
kernel.

MASTER_PPPOE_WORLDNET ~ # ethtool -i eth1
driver: e1000e
version: 1.0.2-k2
firmware-version: 1.8-5
bus-info: 0000:00:19.0

00:19.0 Ethernet controller: Intel Corporation 82567LF-2 Gigabit Network 
Connection

IRQ's
 24:    1290189    1312386    1289973    1310347   PCI-MSI-edge      eth1


Jul 21 16:45:45 PPPOE kernel: [938915.369647] BUG: unable to handle kernel 
NULL pointer dereference at (null)
Jul 21 16:45:45 PPPOE kernel: [938915.369750] IP: [<c0297733>] 
dev_queue_xmit+0x279/0x410
Jul 21 16:45:45 PPPOE kernel: [938915.369822] *pdpt = 0000000022435001 *pde = 
0000000000000000
Jul 21 16:45:45 PPPOE kernel: [938915.369890] Oops: 0000 [#1] SMP
Jul 21 16:45:45 PPPOE kernel: [938915.369953] last sysfs file: 
/sys/devices/system/cpu/online
Jul 21 16:45:45 PPPOE kernel: [938915.370039] Modules linked in: 
nf_conntrack_netlink nfnetlink rtc_cmos rtc_core rtc_lib act_skbedit 
sch_ingress sch_prio netconsole co
nfigfs cls_flow cls_u32 em_meta cls_basic xt_dscp ipt_REJECT ts_bm xt_string 
xt_hl ifb cl
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  
Jul 21 16:45:45 PPPOE kernel: [938915.370253] Pid: 10, comm: ksoftirqd/2 
Tainted: G        W  2.6.34.1-build-0053 #2 DG45ID/
Jul 21 16:45:45 PPPOE kernel: [938915.370253] EIP: 0060:[<c0297733>] EFLAGS: 
00010202 CPU: 2
Jul 21 16:45:45 PPPOE kernel: [938915.370253] EIP is at 
dev_queue_xmit+0x279/0x410
Jul 21 16:45:45 PPPOE kernel: [938915.370253] EAX: e9f72000 EBX: 00000000 ECX: 
e9f786b0 EDX: f6e8c000
Jul 21 16:45:45 PPPOE kernel: [938915.370253] ESI: f74af180 EDI: 000000eb EBP: 
c5301b74 ESP: c5301b5c
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  DS: 007b ES: 007b FS: 00d8 GS: 
0000 SS: 0068
Jul 21 16:45:45 PPPOE kernel: [938915.370253] Process ksoftirqd/2 (pid: 10, 
ti=c5301000 task=f7480000 task.ti=f7461000)
Jul 21 16:45:45 PPPOE kernel: [938915.370253] Stack:
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  e9f786b0 f6e8c000 f6fabe40 
f614ea00 e9f786b0 000000eb c5301b88 f8817062
Jul 21 16:45:45 PPPOE kernel: [938915.370253] <0> f6184800 e9f786b0 c0410540 
c5301bb0 c0297307 f614ea00 f6184800 f88184cc
Jul 21 16:45:45 PPPOE kernel: [938915.370253] <0> 00000003 00008864 00000002 
f614ea00 00000000 c5301bd0 c029781c e9f786b0
Jul 21 16:45:45 PPPOE kernel: [938915.370253] Call Trace:
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<f8817062>] ? 
vlan_dev_hwaccel_hard_start_xmit+0x58/0x6c [8021q]
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<c0297307>] ? 
dev_hard_start_xmit+0x210/0x2dd
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<c029781c>] ? 
dev_queue_xmit+0x362/0x410
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<c02a48be>] ? 
eth_header+0x0/0x92
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<f8c21e53>] ? 
__pppoe_xmit+0x11c/0x132 [pppoe]
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<f8c21e73>] ? 
pppoe_xmit+0xa/0xc [pppoe]
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<f8c06579>] ? 
ppp_push+0x67/0x4bf [ppp_generic]
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<f88947ae>] ? 
tcp_manip_pkt+0xb4/0xc6 [nf_nat]
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<c02907b5>] ? 
__kfree_skb+0x6e/0x71
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<c02900c1>] ? 
skb_dequeue+0x45/0x4c
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<f8c070e8>] ? 
ppp_xmit_process+0x3c6/0x427 [ppp_generic]
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<c028fff9>] ? 
skb_queue_tail+0x2d/0x32
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<f8c0725c>] ? 
ppp_start_xmit+0x113/0x12c [ppp_generic]
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<c0297307>] ? 
dev_hard_start_xmit+0x210/0x2dd
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<c02a53e2>] ? 
sch_direct_xmit+0x4c/0x122
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<c02a554a>] ? 
__qdisc_run+0x92/0xa8
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<c02977d4>] ? 
dev_queue_xmit+0x31a/0x410
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<c02b60fc>] ? 
ip_finish_output2+0x188/0x1b3
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<c02b6179>] ? 
ip_finish_output+0x52/0x54
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<c02b61fc>] ? 
ip_output+0x81/0x8a
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<c02b5685>] ? 
ip_local_out+0x18/0x1b
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<c02b5e00>] ? 
ip_queue_xmit+0x2c3/0x2f9
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<c01ac33e>] ? 
ep_poll_callback+0x8d/0xa4
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<c0120cb3>] ? 
__wake_up_common+0x35/0x5b
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<c02c82b2>] ? 
tcp_v4_send_check+0x7d/0xb7
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<c02c4db8>] ? 
tcp_transmit_skb+0x623/0x65a
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<c02c4eb8>] ? 
tcp_send_ack+0x25/0xd9
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<c02c4f64>] ? 
tcp_send_ack+0xd1/0xd9
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<c02c29ea>] ? 
__tcp_ack_snd_check+0x5e/0x73
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<c02c3483>] ? 
tcp_rcv_established+0x5b2/0x5e1
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<c02c90fd>] ? 
tcp_v4_do_rcv+0x24/0x171
Jul 21 16:45:45 PPPOE kernel: [938915.370253]  [<c013169b>] ? 
local_bh_enable+0xb/0xd
Jul 21 16:45:45 PPPOE kernel: [938915.374483]  [<c02c95f0>] ? 
tcp_v4_rcv+0x3a6/0x582
Jul 21 16:45:45 PPPOE kernel: [938915.374483]  [<c02b266c>] ? 
ip_local_deliver_finish+0xba/0x10b
Jul 21 16:45:45 PPPOE kernel: [938915.374483]  [<c02b271e>] ? 
ip_local_deliver+0x61/0x6a
Jul 21 16:45:45 PPPOE kernel: [938915.374483]  [<c02b237b>] ? 
ip_rcv_finish+0x25b/0x271
Jul 21 16:45:45 PPPOE kernel: [938915.374483]  [<c02b2593>] ? 
ip_rcv+0x202/0x221
Jul 21 16:45:45 PPPOE kernel: [938915.374483]  [<c0296889>] ? 
netif_receive_skb+0x3e4/0x403
Jul 21 16:45:45 PPPOE kernel: [938915.374483]  [<c029690c>] ? 
process_backlog+0x64/0x8a
Jul 21 16:45:45 PPPOE kernel: [938915.374483]  [<c0296a93>] ? 
net_rx_action+0x8d/0x14a
Jul 21 16:45:45 PPPOE kernel: [938915.374483]  [<c013177c>] ? 
__do_softirq+0x77/0xe7
Jul 21 16:45:45 PPPOE kernel: [938915.374483]  [<c0131705>] ? 
__do_softirq+0x0/0xe7
Jul 21 16:45:45 PPPOE kernel: [938915.374483]  <IRQ>
Jul 21 16:45:45 PPPOE kernel: [938915.374483]  [<c0131365>] ? 
run_ksoftirqd+0x56/0xde
Jul 21 16:45:45 PPPOE kernel: [938915.374483]  [<c013130f>] ? 
run_ksoftirqd+0x0/0xde
Jul 21 16:45:45 PPPOE kernel: [938915.374483]  [<c013d5bd>] ? 
kthread+0x61/0x66
Jul 21 16:45:45 PPPOE kernel: [938915.374483]  [<c013d55c>] ? kthread+0x0/0x66
Jul 21 16:45:45 PPPOE kernel: [938915.374483]  [<c0102c76>] ? 
kernel_thread_helper+0x6/0x10
Jul 21 16:45:45 PPPOE kernel: [938915.374483] Code: 0c 8b 45 e8 0f b7 f2 c1 e6 
07 66 89 50 7c 8b 55 ec 8b 4d e8 03 b2 00 02 00 00 66 8b 41 7a 8b 5e 04 80 e4 
cf 80 cc 20
 66 89 41 7a <83> 3b 00 0f 84 a0 00 00 00 8d 7b 5c 89 f8 e8 5c de 05 00 f6 43
