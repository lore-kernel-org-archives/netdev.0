From: Ben Greear <greearb@candelatech.com>
Subject: Re: [E1000-devel] 2.6.36-rc7-git2 - panic/GPF: e1000e/vlans?
Date: Fri, 22 Oct 2010 11:15:47 -0700
Message-ID: <4CC1D4D3.7070804@candelatech.com>
References: <20101014052242.GA8998@pcnci.linuxbox.cz> <EA929A9653AAE14F841771FB1DE5A1366027CEFF1C@rrsmsx501.amr.corp.intel.com> <20101020144640.GA3009@pcnci.linuxbox.cz> <20101020163659.GB3009@pcnci.linuxbox.cz> <20101021190208.GA7289@nik-comp.lan> <alpine.WNT.2.00.1010211207220.5208@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nikola Ciprich <extmaillist@linuxbox.cz>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	linux-net maillist <linux-net@vger.kernel.org>,
	e1000-devel list <e1000-devel@lists.sourceforge.net>,
	"nikola.ciprich@linuxbox.cz" <nikola.ciprich@linuxbox.cz>,
	Linux kernel list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:45448 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406Ab0JVSQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Oct 2010 14:16:10 -0400
In-Reply-To: <alpine.WNT.2.00.1010211207220.5208@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/21/2010 12:09 PM, Brandeburg, Jesse wrote:
>
> Adding netdev... beware the top post ordering in the thread.

Is there any more info, like a stack trace?  We just saw this on
one of our more complex setups.  Kernel is 2.6.36, with some patches,
including a proprietary module:

general protection fault: 0000 [#1] PREEMPT SMP
last sysfs file: /sys/devices/pci0000:00/0000:00:1e.0/0000:0f:01.0/class
CPU 2
Modules linked in: 8021q garp bridge veth arc4 michael_mic macvlan wanlink(P) pktgen iscsi_tcp libiscsi_]

Pid: 0, comm: kworker/0:1 Tainted: P            2.6.36-rc8+ #3 X7DBU/X7DBU
RIP: 0010:[<ffffffff813ccc35>]  [<ffffffff813ccc35>] vlan_hwaccel_do_receive+0x64/0xca
RSP: 0018:ffff880001a83c00  EFLAGS: 00010283
RAX: 0000000000000002 RBX: ffff880047c9ee00 RCX: ffff880074c18000
RDX: ffff8800ffffffff RSI: 0000000000004359 RDI: 0000000000000001
RBP: ffff880001a83c20 R08: 00000000000003eb R09: ffffffff810620af
R10: ffff880047c9ee28 R11: 00000000ffffffff R12: ffff880074c18000
R13: ffff1000766988d0 R14: ffffc900037e1dd8 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff880001a80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000462073 CR3: 0000000074219000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kworker/0:1 (pid: 0, threadinfo ffff88007d030000, task ffff88007d76f700)
Stack:
  0000000000014400 ffff880047c9ee00 ffff880074c18948 ffff880047c9ee08
<0> ffff880001a83c90 ffffffff813456ed ffff880001a83c40 ffffffff8100fbba
<0> ffff880001a83c70 ffffffff81061dad ffff880001b102c0 ffff880047c9ee00
Call Trace:
  <IRQ>
  [<ffffffff813456ed>] __netif_receive_skb+0x4b/0x444
  [<ffffffff8100fbba>] ? read_tsc+0x9/0x1b
  [<ffffffff81061dad>] ? getnstimeofday+0x5e/0xb4
  [<ffffffff8134697a>] netif_receive_skb+0x7c/0x83
  [<ffffffff813470b5>] napi_skb_finish+0x24/0x3b
  [<ffffffff813ccf16>] vlan_gro_receive+0x7b/0x7d
  [<ffffffffa02bff4b>] e1000_receive_skb+0x54/0x70 [e1000e]
  [<ffffffffa02c1cc9>] e1000_clean_rx_irq+0x1fe/0x2aa [e1000e]
  [<ffffffff810651de>] ? clockevents_program_event+0x75/0x7e
  [<ffffffff810651de>] ? clockevents_program_event+0x75/0x7e
  [<ffffffffa02c20a7>] e1000_clean+0x75/0x221 [e1000e]
  [<ffffffff81346b67>] net_rx_action+0xad/0x1e9
  [<ffffffff8100fcd0>] ? native_sched_clock+0x3c/0x68
  [<ffffffff81048932>] __do_softirq+0xa8/0x135
  [<ffffffff8100a99c>] call_softirq+0x1c/0x30
  [<ffffffff8100c05d>] do_softirq+0x41/0x7e
  [<ffffffff81048ac4>] irq_exit+0x36/0x85
  [<ffffffff8100b797>] do_IRQ+0xad/0xc4
  [<ffffffff813efa13>] ret_from_intr+0x0/0x11
  <EOI>
  [<ffffffff81010840>] ? mwait_idle+0x7f/0x8c
  [<ffffffff81010833>] ? mwait_idle+0x72/0x8c
  [<ffffffff81008dd5>] cpu_idle+0x59/0xb5
  [<ffffffff813e97d6>] start_secondary+0x1a9/0x1ae
Code: 0d 0f b7 c0 41 8b 44 85 04 66 c7 83 c4 00 00 00 00 00 89 43 78 4d 8b ad d8 00 00 00 e8 11 87 e0 ff
RIP  [<ffffffff813ccc35>] vlan_hwaccel_do_receive+0x64/0xca
  RSP <ffff880001a83c00>
---[ end trace 64a9f9c2bdc31dcd ]---
Kernel panic - not syncing: Fatal exception in interrupt

I re-compiled this kernel with symbols, and the crash points here.  We'll
try to reproduce with this newly compiled kernel, in case that merely compiling
with symbols changes the offsets.

(gdb) l *(vlan_hwaccel_do_receive+0x64)
0xffffffff813ccc55 is in vlan_hwaccel_do_receive (/home/greearb/git/linux-2.6.dev.36.y/net/8021q/vlan_core.c:56).
51		skb->vlan_tci = 0;
52	
53		rx_stats = this_cpu_ptr(vlan_dev_info(dev)->vlan_rx_stats);
54	
55		u64_stats_update_begin(&rx_stats->syncp);
56		rx_stats->rx_packets++;
57		rx_stats->rx_bytes += skb->len;
58	
59		switch (skb->pkt_type) {
60		case PACKET_BROADCAST:
(gdb)


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

