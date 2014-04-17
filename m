From: Michael Maier <m1278468@allmail.net>
Subject: Kernel crash in bridge module: unable to handle kernel paging
 request
Date: Thu, 17 Apr 2014 11:00:02 +0200
Message-ID: <20140417110002.790f7ae1@dualc.maya.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout0.freenet.de ([195.4.92.90]:45464 "EHLO mout0.freenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751209AbaDQJRf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Apr 2014 05:17:35 -0400
Received: from [195.4.92.141] (helo=mjail1.freenet.de)
	by mout0.freenet.de with esmtpa (ID andihartmann@freenet.de) (port 25) (Exim 4.80.1 #4)
	id 1WaiEp-0006lp-O3
	for netdev@vger.kernel.org; Thu, 17 Apr 2014 11:04:07 +0200
Received: from localhost ([::1]:46106 helo=mjail1.freenet.de)
	by mjail1.freenet.de with esmtpa (ID andihartmann@freenet.de) (Exim 4.80.1 #4)
	id 1WaiEp-0004KV-HG
	for netdev@vger.kernel.org; Thu, 17 Apr 2014 11:04:07 +0200
Received: from mx4.freenet.de ([195.4.92.14]:60777)
	by mjail1.freenet.de with esmtpa (ID andihartmann@freenet.de) (Exim 4.80.1 #4)
	id 1WaiAw-0008Bl-MI
	for netdev@vger.kernel.org; Thu, 17 Apr 2014 11:00:06 +0200
Received: from p4fde010c.dip0.t-ipconnect.de ([79.222.1.12]:39968 helo=mail.maya.org)
	by mx4.freenet.de with esmtpsa (ID andihartmann@freenet.de) (TLSv1.2:DHE-RSA-AES256-GCM-SHA384:256) (port 587) (Exim 4.80.1 #4)
	id 1WaiAw-0005au-5z
	for netdev@vger.kernel.org; Thu, 17 Apr 2014 11:00:06 +0200
Received: from dualc.maya.org (dualc.maya.org [192.168.1.6])
	by mail.maya.org (8.14.7/8.13.8) with ESMTP id s3H8x0ow004347
	for <netdev@vger.kernel.org>; Thu, 17 Apr 2014 10:59:00 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

I'm using the following configuration on CentOS 6.5 w/ lt-kernel
(3.10.37) - or any other kernel version.

brctl addbr br0
brctl addif br0 eth0

ip li add vxlan0 type vxlan id 1 group 239.1.1.1 ttl 1 dev ra0

brctl addif br0 vxlan0

This is one end of a vxlan tunnel via WLAN.

At the moment the first package arrives the bridge, the 64 bit-kernel
crashes (32 bit kernel works perfectly). What could be the reason for
the crash w/ 64 bit kernel? Btw: there isn't any problem even w/ 64
bit kernel as long as the bridge code isn't involved.


Thanks for any hint!
Michael


BUG: unable to handle kernel paging request at ffff880077998000
IP: [<ffffffff812a663d>] memcpy+0xd/0x110
PGD 20d9067 PUD 20dc067 PMD 77a85063 PTE 8000000077998161
Oops: 0003 [#1] SMP
Modules linked in: vxlan ip_tunnel bridge stp llc rfkill xt_multiport iptable_filter ip_tables ipv6 acpi_cpufreq freq_table mperf kvm_amd kvm microcode pcspkr sg rt5572sta(O) k10temp hwmon sp5100_tco i2c_piix4 r8169 mii ext4 jbd2 mbcache sd_mod crc_t10dif usb_storage atd
CPU: 1 PID: 0 Comm: swapper/1 Tainted: G           O 3.10.37-1.el6.elrepo.x86_64 #1
Hardware name: PC Engines APU, BIOS unknown 12/24/2013
task: ffff88007a866ad0 ti: ffff88007a86a000 task.ti: ffff88007a86a000
RIP: 0010:[<ffffffff812a663d>]  [<ffffffff812a663d>] memcpy+0xd/0x110
RSP: 0018:ffff88007df03698  EFLAGS: 00010202
RAX: ffff880077992800 RBX: ffff88007a4a24c0 RCX: 000000000f4b42e0
RDX: 0000000000000002 RSI: ffff88007a5ac640 RDI: ffff880077998000
RBP: ffff88007df036e0 R08: 0000000000000000 R09: ffff88007df03848
R10: ffff880079a5a4b0 R11: 0000000000000000 R12: 0000000000000000
R13: 0000000000000020 R14: ffff880077992800 R15: ffff880077992800
FS:  00007fab767fc700(0000) GS:ffff88007df00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: ffff880077998000 CR3: 0000000079db6000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Stack:
 ffffffff81515155 0000000000000000 000002c0a034bd2a 0000000000000000
 ffff88007a4a24c0 000000000000000e ffff88007a6de000 ffffffff81d197a0
 0000000000000002 ffff88007df03700 ffffffffa0365afd ffff88007a4a24c0
Call Trace:
 <IRQ> 
 [<ffffffff81515155>] ? pskb_expand_head+0xb5/0x250
 [<ffffffffa0365afd>] nf_bridge_copy_header+0x14d/0x170 [bridge]
 [<ffffffffa035e375>] br_dev_queue_push_xmit+0xa5/0xd0 [bridge]
 [<ffffffffa036614a>] br_nf_dev_queue_xmit+0x2a/0xa0 [bridge]
 [<ffffffffa0366f18>] br_nf_post_routing+0x2b8/0x2e0 [bridge]
 [<ffffffff8154faa7>] nf_iterate+0x87/0xb0
 [<ffffffffa035e2d0>] ? deliver_clone+0x60/0x60 [bridge]
 [<ffffffff8154fccd>] nf_hook_slow+0x7d/0x150
 [<ffffffffa035e2d0>] ? deliver_clone+0x60/0x60 [bridge]
 [<ffffffffa03661c0>] ? br_nf_dev_queue_xmit+0xa0/0xa0 [bridge]
 [<ffffffffa035e883>] br_forward_finish+0x43/0x60 [bridge]
 [<ffffffffa0366358>] br_nf_forward_finish+0x198/0x1b0 [bridge]
 [<ffffffffa0366bf8>] br_nf_forward_ip+0x3a8/0x410 [bridge]
 [<ffffffff8154faa7>] nf_iterate+0x87/0xb0
 [<ffffffffa035e840>] ? br_flood_deliver+0x20/0x20 [bridge]
 [<ffffffff8154fccd>] nf_hook_slow+0x7d/0x150
 [<ffffffffa035e840>] ? br_flood_deliver+0x20/0x20 [bridge]
 [<ffffffffa035e444>] __br_forward+0xa4/0x100 [bridge]
 [<ffffffff815149b2>] ? skb_clone+0x62/0xc0
 [<ffffffffa035e3a0>] ? br_dev_queue_push_xmit+0xd0/0xd0 [bridge]
 [<ffffffffa035e2ae>] deliver_clone+0x3e/0x60 [bridge]
 [<ffffffffa035e3a0>] ? br_dev_queue_push_xmit+0xd0/0xd0 [bridge]
 [<ffffffffa035e7c4>] br_flood+0x84/0xc0 [bridge]
 [<ffffffffa035f5c0>] ? NF_HOOK.clone.0+0x70/0x70 [bridge]
 [<ffffffffa035e815>] br_flood_forward+0x15/0x20 [bridge]
 [<ffffffffa035f8bf>] br_handle_frame_finish+0x2ff/0x320 [bridge]
 [<ffffffffa0367110>] br_nf_pre_routing_finish+0x1d0/0x350 [bridge]
 [<ffffffffa0366f40>] ? br_nf_post_routing+0x2e0/0x2e0 [bridge]
 [<ffffffffa0365456>] NF_HOOK_THRESH+0x56/0x60 [bridge]
 [<ffffffffa036679f>] br_nf_pre_routing+0x2df/0x390 [bridge]
 [<ffffffff81589ae0>] ? __udp4_lib_rcv+0x390/0x6c0
 [<ffffffff815597a0>] ? ip_rcv+0x350/0x350
 [<ffffffff8154faa7>] nf_iterate+0x87/0xb0
 [<ffffffff815597a0>] ? ip_rcv+0x350/0x350
 [<ffffffffa035f5c0>] ? NF_HOOK.clone.0+0x70/0x70 [bridge]
 [<ffffffff8154fccd>] nf_hook_slow+0x7d/0x150
 [<ffffffffa035f5c0>] ? NF_HOOK.clone.0+0x70/0x70 [bridge]
 [<ffffffffa035faa4>] br_handle_frame+0x1c4/0x260 [bridge]
 [<ffffffffa035f8e0>] ? br_handle_frame_finish+0x320/0x320 [bridge]
 [<ffffffff8152380e>] __netif_receive_skb_core+0x27e/0x6d0
 [<ffffffff81523c87>] __netif_receive_skb+0x27/0x70
 [<ffffffff81523dd3>] process_backlog+0x103/0x200
 [<ffffffff81524612>] net_rx_action+0x112/0x2a0
 [<ffffffff814ccd06>] ? cpuidle_enter_state+0x56/0xd0
 [<ffffffff81063cc7>] __do_softirq+0xf7/0x270
 [<ffffffff8103bc18>] ? ack_apic_level+0x78/0x150
 [<ffffffff815fcf1c>] call_softirq+0x1c/0x30
 [<ffffffff81014535>] do_softirq+0x65/0xa0
 [<ffffffff810639f5>] irq_exit+0xc5/0xd0
 [<ffffffff815fd826>] do_IRQ+0x66/0xe0
 [<ffffffff815f312d>] common_interrupt+0x6d/0x6d
 <EOI> 
 [<ffffffff8101a2e3>] ? native_sched_clock+0x13/0x80
 [<ffffffff814ccd06>] ? cpuidle_enter_state+0x56/0xd0
 [<ffffffff814cccff>] ? cpuidle_enter_state+0x4f/0xd0
 [<ffffffff814cd15d>] cpuidle_idle_call+0xcd/0x160
 [<ffffffff8101ad6e>] arch_cpu_idle+0xe/0x30
 [<ffffffff810aea9e>] cpu_idle_loop+0x9e/0x250
 [<ffffffff810aecc0>] cpu_startup_entry+0x70/0x80
 [<ffffffff815e6a12>] start_secondary+0xcd/0xcf
Code: 0f b6 c0 5b c9 c3 0f 1f 84 00 00 00 00 00 e8 6b f8 ff ff 80 7b 25 00 74 c8 eb d3 90 90 90 48 89 f8 48 89 d1 48 c1 e9 03 83 e2 07 <f3> 48 a5 89 d1 f3 a4 c3 20 4c 8b 06 4c 8b 4e 08 4c 8b 56 10 4c 
RIP  [<ffffffff812a663d>] memcpy+0xd/0x110
 RSP <ffff88007df03698>
CR2: ffff880077998000
---[ end trace d8c8412df40453b6 ]---
Kernel panic - not syncing: Fatal exception in interrupt
