From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: null pointer dereference in br_nf_pre_routing_finish (2.6.29.2)
Date: Wed, 3 Jun 2009 13:43:56 +0300
Message-ID: <20090603104355.GA16189@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ee.oulu.fi ([130.231.61.23]:50739 "EHLO ee.oulu.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753432AbZFCLI2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2009 07:08:28 -0400
Received: from tk-cn0002.oulu.fi (tk-cn0002 [130.231.63.2])
	by ee.oulu.fi (8.14.3/8.14.3) with ESMTP id n53Ahu6x019408
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 3 Jun 2009 13:43:56 +0300 (EEST)
Received: (from pp@localhost)
	by tk-cn0002.oulu.fi (8.14.3/8.14.3/Submit) id n53Ahubl016521
	for netdev@vger.kernel.org; Wed, 3 Jun 2009 13:43:56 +0300
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hitting this one every few days on one machine, e1000 bridged to kvm tap
devices.

BUG: unable to handle kernel NULL pointer dereference at 000000008
IP: [<ffffffffa0262a3a>] br_nf_pre_routing_finish+0x2a/0x285 [bridge]
PGD 41b8a9067 PUD 41b8ec067 PMD 0
Oops: 0000 [#1] SMP
last sysfs file: /sys/devices/pci0000:00/0000:00:04.0/0000:0c:00.1/irq
CPU 2
Modules linked in: tun ipt_MASQUERADE iptable_nat nf_nat nfs lockd nfs_acl
auth]
Pid: 0, comm: swapper Not tainted 2.6.29.2-52.fc10.x86_64 #1 PowerEdge 1950
RIP: 0010:[<ffffffffa0262a3a>]  [<ffffffffa0262a3a>]
br_nf_pre_routing_finish+0]
RSP: 0018:ffff88042e53fb50  EFLAGS: 00010286
RAX: 0000000000000000 RBX: ffff88042cc6ff00 RCX: ffff88042cc6ff01
RDX: 0000000000000002 RSI: 0000000000000020 RDI: ffff880422a32000
RBP: ffff88042e53fbd0 R08: ffffffffa0262a10 R09: ffffffff8159a6c0
R10: ffffffff8159b400 R11: 000000022e53f9f0 R12: 0000000000000000
R13: 0000000000000000 R14: ffff88042291e000 R15: ffff88042cc6ff00
FS:  0000000000000000(0000) GS:ffff88042e4c5a00(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 0000000000000018 CR3: 000000041b8de000 CR4: 00000000000026e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffff88042e53a000, task ffff88042e532e00)
Stack:
 ffffffffa0262a10 0000000000000000 ffff88042e53fbd0 ffffffff812f5b8f
 ffffffffa0262a10 ffffffff80000000 ffffffff80000000 00000002a0033a00
 ffff88042291e000 0000000000000246 ffffffff8159a6c0 ffff88042cc6ff00
Call Trace:
 <IRQ> <0> [<ffffffffa0262a10>] ? br_nf_pre_routing_finish+0x0/0x285
[bridge]
 [<ffffffff812f5b8f>] ? nf_hook_slow+0x63/0xc3
 [<ffffffffa0262a10>] ? br_nf_pre_routing_finish+0x0/0x285 [bridge]
 [<ffffffffa0263238>] br_nf_pre_routing+0x5a3/0x5c2 [bridge]
[<ffffffff812f5aef>] nf_iterate+0x43/0x80
 [<ffffffffa025e828>] ? br_handle_frame_finish+0x0/0x14f [bridge]
 [<ffffffff812f5b8f>] nf_hook_slow+0x63/0xc3
 [<ffffffffa025e828>] ? br_handle_frame_finish+0x0/0x14f [bridge]
 [<ffffffff81181e71>] ? cpumask_next_and+0x2b/0x3c
 [<ffffffffa025eb23>] br_handle_frame+0x1ac/0x1d5 [bridge]
 [<ffffffff812d95a7>] netif_receive_skb+0x311/0x42f
 [<ffffffff812d9c34>] napi_gro_receive+0x69/0x7e
 [<ffffffffa011a70b>] e1000_receive_skb+0x57/0x60 [e1000e]
 [<ffffffffa011a8f0>] e1000_clean_rx_irq+0x1dc/0x28a [e1000e]
 [<ffffffff81016e98>] ? read_tsc+0xe/0x24
 [<ffffffffa011bdf3>] e1000_clean+0x94/0x245 [e1000e]
 [<ffffffff81029cef>] ? default_spin_lock_flags+0x9/0xe
 [<ffffffff812d7d9e>] net_rx_action+0xb3/0x1af
 [<ffffffff8104db44>] __do_softirq+0x94/0x150
 [<ffffffff8101274c>] call_softirq+0x1c/0x30
 [<ffffffff81013869>] do_softirq+0x4d/0xb4
 [<ffffffff8104d792>] irq_exit+0x4e/0x88
 [<ffffffff81013b77>] do_IRQ+0x130/0x155
 [<ffffffff81011e93>] ret_from_intr+0x0/0x2e
 <EOI> <0> [<ffffffff81017af1>] ? mwait_idle+0x99/0xc2
 [<ffffffff81017ae8>] ? mwait_idle+0x90/0xc2
 [<ffffffff81376f01>] ? atomic_notifier_call_chain+0x13/0x15
 [<ffffffff81010272>] ? enter_idle+0x22/0x24
 [<ffffffff810102d7>] ? cpu_idle+0x63/0xac
 [<ffffffff8136e17f>] ? start_secondary+0x19a/0x19f
Code: c3 55 48 89 e5 41 56 41 55 41 54 53 48 89 fb 48 83 ec 60 4c 8b ab 98
00 0
RIP  [<ffffffffa0262a3a>] br_nf_pre_routing_finish+0x2a/0x285 [bridge]
 RSP <ffff88042e53fb50>
CR2: 0000000000000018
BUG: scheduling while atomic: swapper/0/0x10000100
Modules linked in: tun ipt_MASQUERADE iptable_nat nf_nat nfs lockd nfs_acl
auth]
CPU 2:
Modules linked in: tun ipt_MASQUERADE iptable_nat nf_nat nfs lockd nfs_acl
auth]
Pid: 0, comm: swapper Not tainted 2.6.29.2-52.fc10.x86_64 #1 PowerEdge 1950
RIP: 0010:[<ffffffff81017af1>]  [<ffffffff81017af1>] mwait_idle+0x99/0xc2
RSP: 0018:ffff88042e53bee8  EFLAGS: 00000246
RAX: 0000000000000000 RBX: ffff88042e53bf08 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff88042e53bee8
RBP: ffffffff81011e8e R08: 0000000000000000 R09: ffffffffffffff10
R10: ffff88042e4df188 R11: ffff88042e52d118 R12: 0000000000000040
R13: ffff8800a694d000 R14: ffff88042e53a000 R15: ffffffff8170c910
FS:  0000000000000000(0000) GS:ffff88042e4c5a00(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 0000000000000018 CR3: 000000041b8de000 CR4: 00000000000026e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Call Trace:
 [<ffffffff81017ae8>] ? mwait_idle+0x90/0xc2
 [<ffffffff81376f01>] ? atomic_notifier_call_chain+0x13/0x15
 [<ffffffff81010272>] ? enter_idle+0x22/0x24
 [<ffffffff810102d7>] ? cpu_idle+0x63/0xac
 [<ffffffff8136e17f>] ? start_secondary+0x19a/0x19f
