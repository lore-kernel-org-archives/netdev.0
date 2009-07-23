From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: ixgbe: panic in ixgbe_clean_rx_irq()
Date: Thu, 23 Jul 2009 17:21:33 +0200
Message-ID: <1248362493.17215.45.camel@localhost.localdomain>
References: <1248266678.17215.15.camel@localhost.localdomain>
	 <Pine.WNT.4.64.0907221110550.9360@ppwaskie-MOBL2.amr.corp.intel.com>
	 <1248338779.17215.23.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:38103 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913AbZGWPVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 11:21:35 -0400
In-Reply-To: <1248338779.17215.23.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-07-23 at 10:46 +0200, Jesper Dangaard Brouer wrote:
> > > Hi Peter,
> > > 
> > > Got a panic from the ixgbe driver on my 82599 based NICs, while
> running
> > > two pktgen tests (1500 bytes packets) against the machine.
> > > 
> > > Kernel: 2.6.31-rc1-net-2.6-00122-ge594e96 with preemption
> 
> Got a new panic.  The strange thing its not happening in the same
> place... and the anoying thing is that its hard to reproduce, as I
> have to run pktgen a very long time before it dies.

Got yet another panic... now its in skb_put() in the line
SKB_LINEAR_ASSERT(skb).

I'm going to run a test with a no-preempt kernel over night...

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer

[  531.614873] ------------[ cut here ]------------
[  531.628869] kernel BUG at net/core/skbuff.c:1014!
[  531.643116] invalid opcode: 0000 [#1] PREEMPT SMP 
[  531.657774] last sysfs file: /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor
[  531.680753] CPU 2 
[  531.686970] Modules linked in: asus_atk0110 ixgbe hwmon mdio r8169
[  531.705922] Pid: 0, comm: swapper Not tainted 2.6.31-rc1-net-2.6-00122-ge594e96 #8 System Product Name
[  531.734109] RIP: 0010:[<ffffffff81382538>]  [<ffffffff81382538>] skb_put+0x1d/0x89
[  531.757137] RSP: 0000:ffff8800018b1d90  EFLAGS: 00010286
[  531.773208] RAX: 0000000000000000 RBX: ffff8800a11b6200 RCX: 000000000000002a
[  531.794752] RDX: 0000000000000022 RSI: 000000000000002a RDI: ffff8800a11b6200
[  531.816292] RBP: ffff8800018b1db0 R08: ffff8800a107f400 R09: ffff880080000000
[  531.837833] R10: ffff8800a107d948 R11: 0100880000000000 R12: ffffc90011a90710
[  531.859375] R13: ffff8800376430c0 R14: ffff8800bb442580 R15: 0000000040000073
[  531.880916] FS:  0000000000000000(0000) GS:ffff8800018ae000(0000) knlGS:0000000000000000
[  531.905458] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
[  531.922825] CR2: 0000000000607000 CR3: 00000000a9ca7000 CR4: 00000000000006a0
[  531.944370] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  531.965909] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  531.987452] Process swapper (pid: 0, threadinfo ffff8800beec8000, task ffff8800bee94380)
[  532.011995] Stack:
[  532.018162]  ffff8800018b1db0 ffffffff8138a699 ffff8800a11b6600 ffffc90011a906e8
[  532.040107] <0> ffff8800018b1e50 ffffffffa001a677 00000040018b1de0 ffff8800018b1e6c
[  532.063587] <0> ffff8800bbd47b00 ffff8800be5aa000 ffff8800bd790fa0 ffff8800bd790fa0
[  532.087770] Call Trace:
[  532.095243]  <IRQ> 
[  532.101724]  [<ffffffff8138a699>] ? napi_gro_receive+0x2a/0x2f
[  532.119359]  [<ffffffffa001a677>] ixgbe_clean_rx_irq+0x17f/0x53b [ixgbe]
[  532.139599]  [<ffffffffa001aa81>] ixgbe_clean_rxonly+0x4e/0xd2 [ixgbe]
[  532.159314]  [<ffffffff8138a7b5>] net_rx_action+0xb2/0x234
[  532.175908]  [<ffffffff8103fb35>] __do_softirq+0x10c/0x211
[  532.192503]  [<ffffffff8100cc2c>] call_softirq+0x1c/0x28
[  532.208577]  [<ffffffff8100de84>] do_softirq+0x34/0x72
[  532.224131]  [<ffffffff8103f83f>] irq_exit+0x36/0x85
[  532.239164]  [<ffffffff8100d75f>] do_IRQ+0xa6/0xbd
[  532.253677]  [<ffffffff8100c493>] ret_from_intr+0x0/0xa
[  532.273123]  <EOI> 
[  532.279611]  [<ffffffff81012355>] ? mwait_idle+0x89/0x9f
[  532.295681]  [<ffffffff81012348>] ? mwait_idle+0x7c/0x9f
[  532.311755]  [<ffffffff8142c948>] ? atomic_notifier_call_chain+0xf/0x11
[  532.331737]  [<ffffffff8100aedb>] ? cpu_idle+0x4f/0xb3
[  532.347288]  [<ffffffff81424478>] ? start_secondary+0x17f/0x184
[  532.365185] Code: e8 04 58 0a 00 0f 0b eb fe 48 89 c8 c9 c3 55 89 f1 48 89 e5 48 83 ec 20 4c 8b 87 d0 00 00 00 8b 97 c4 00 00 00 83 7f
 64 00 74 04 <0f> 0b eb fe 8d 04 11 01 77 60 89 87 c4 00 00 00 3b 87 c8 00 00 
[  532.425076] RIP  [<ffffffff81382538>] skb_put+0x1d/0x89
[  532.440935]  RSP <ffff8800018b1d90>
[  532.451539] ---[ end trace 2bb373a2a0219cb4 ]---
[  532.465527] Kernel panic - not syncing: Fatal exception in interrupt
[  532.484728] Pid: 0, comm: swapper Tainted: G      D    2.6.31-rc1-net-2.6-00122-ge594e96 #8
[  532.510052] Call Trace:
[  532.517535]  <IRQ>  [<ffffffff81427c6b>] panic+0xaa/0x155
[  532.533924]  [<ffffffff8103f88c>] ? irq_exit+0x83/0x85
[  532.549483]  [<ffffffff8100c493>] ? ret_from_intr+0x0/0xa
[  532.565815]  [<ffffffff8142b039>] ? oops_end+0x6b/0xba
[  532.581369]  [<ffffffff8142b078>] oops_end+0xaa/0xba
[  532.596403]  [<ffffffff8100f0d1>] die+0x55/0x5e
[  532.610136]  [<ffffffff8142aad9>] do_trap+0x110/0x11f
[  532.625430]  [<ffffffff8100d44f>] do_invalid_op+0x91/0x9a
[  532.641764]  [<ffffffff81382538>] ? skb_put+0x1d/0x89
[  532.657058]  [<ffffffff813b4d2a>] ? ip_forward+0x288/0x2e2
[  532.673652]  [<ffffffff813b36ec>] ? ip_rcv_finish+0x37c/0x396
[  532.691030]  [<ffffffff8100c8c5>] invalid_op+0x15/0x20
[  532.706582]  [<ffffffff81382538>] ? skb_put+0x1d/0x89
[  532.721876]  [<ffffffff8138a699>] ? napi_gro_receive+0x2a/0x2f
[  532.739518]  [<ffffffffa001a677>] ixgbe_clean_rx_irq+0x17f/0x53b [ixgbe]
[  532.759759]  [<ffffffffa001aa81>] ixgbe_clean_rxonly+0x4e/0xd2 [ixgbe]
[  532.779474]  [<ffffffff8138a7b5>] net_rx_action+0xb2/0x234
[  532.796068]  [<ffffffff8103fb35>] __do_softirq+0x10c/0x211
[  532.812664]  [<ffffffff8100cc2c>] call_softirq+0x1c/0x28
[  532.828738]  [<ffffffff8100de84>] do_softirq+0x34/0x72
[  532.844291]  [<ffffffff8103f83f>] irq_exit+0x36/0x85
[  532.859324]  [<ffffffff8100d75f>] do_IRQ+0xa6/0xbd
[  532.873838]  [<ffffffff8100c493>] ret_from_intr+0x0/0xa
[  532.889651]  <EOI>  [<ffffffff81012355>] ? mwait_idle+0x89/0x9f
[  532.907599]  [<ffffffff81012348>] ? mwait_idle+0x7c/0x9f
[  532.923676]  [<ffffffff8142c948>] ? atomic_notifier_call_chain+0xf/0x11
[  532.943658]  [<ffffffff8100aedb>] ? cpu_idle+0x4f/0xb3
[  532.959210]  [<ffffffff81424478>] ? start_secondary+0x17f/0x184

