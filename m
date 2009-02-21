From: Michael Buesch <mb@bu3sch.de>
Subject: Net watchdog triggering on r8169
Date: Sat, 21 Feb 2009 16:25:55 +0100
Message-ID: <200902211625.55377.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:59880 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753235AbZBUP2i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Feb 2009 10:28:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The watchdog just triggered on a machine running 2.6.28.6 with
compat-wireless-2009-02-20. the realtek device shares a bridge with a b43
wireless AP.

So well, I'm not 100% sure whose fault this is, but I'd almost certainly say it's
not b43's fault.
At the time this happened, the b43 interface was completely idle and the r8169
interface was loaded with about 10kiB/sec on the TX side.

After the watchdog triggered and reset the interface, traffic resumed and it's
still working properly without a reboot.


[97355.804023] ------------[ cut here ]------------
[97355.804063] WARNING: at net/sched/sch_generic.c:226 dev_watchdog+0x22e/0x240()
[97355.804099] NETDEV WATCHDOG: eth0 (r8169): transmit timed out
[97355.804122] Modules linked in: b43 ssb mac80211 cfg80211 [last unloaded: cfg80211]
[97355.804173] Pid: 0, comm: swapper Not tainted 2.6.28.6 #8
[97355.804196] Call Trace:
[97355.804214]  <IRQ>  [<ffffffff80240abd>] warn_slowpath+0xcd/0x110
[97355.804250]  [<ffffffff8072e42f>] br_dev_queue_push_xmit+0x5f/0x90
[97355.804276]  [<ffffffff8072d6e3>] br_dev_xmit+0x73/0xa0
[97355.804301]  [<ffffffff8060e94c>] dev_queue_xmit+0xfc/0x570
[97355.804326]  [<ffffffff8023778c>] find_busiest_group+0x1dc/0x970
[97355.804351]  [<ffffffff80236ca8>] enqueue_task_fair+0x178/0x180
[97355.804378]  [<ffffffff80235042>] activate_task+0x22/0x30
[97355.804403]  [<ffffffff80239ea6>] try_to_wake_up+0xf6/0x1a0
[97355.804429]  [<ffffffff8040ba21>] strlcpy+0x41/0x50
[97355.804453]  [<ffffffff80629dbe>] dev_watchdog+0x22e/0x240
[97355.804478]  [<ffffffff80235a73>] __wake_up+0x43/0x70
[97355.804503]  [<ffffffff80253870>] delayed_work_timer_fn+0x0/0x40
[97355.804529]  [<ffffffff80629b90>] dev_watchdog+0x0/0x240
[97355.804554]  [<ffffffff8024b1be>] run_timer_softirq+0x12e/0x200
[97355.804580]  [<ffffffff8025accc>] ktime_get+0xc/0x50
[97355.804604]  [<ffffffff80246803>] __do_softirq+0x93/0x160
[97355.804629]  [<ffffffff8020d49c>] call_softirq+0x1c/0x30
[97355.804654]  [<ffffffff8020ee45>] do_softirq+0x35/0x70
[97355.804677]  [<ffffffff802464f5>] irq_exit+0x95/0xa0
[97355.804703]  [<ffffffff802200b6>] smp_apic_timer_interrupt+0x86/0xd0
[97355.804729]  [<ffffffff8020ceeb>] apic_timer_interrupt+0x6b/0x70
[97355.804752]  <EOI>  [<ffffffff8021f7e0>] lapic_next_event+0x0/0x20
[97355.804785]  [<ffffffff8021468c>] mwait_idle+0x3c/0x50
[97355.804808]  [<ffffffff8020b34e>] cpu_idle+0x5e/0xb0
[97355.804831] ---[ end trace 5bbed3ec50983ad4 ]---
[97355.822193] r8169: eth0: link up
[97457.822002] r8169: eth0: link up

-- 
Greetings, Michael.
