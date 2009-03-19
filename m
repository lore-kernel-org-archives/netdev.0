From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Net watchdog triggering on r8169
Date: Thu, 19 Mar 2009 18:35:14 +0100
Message-ID: <200903191835.14571.mb@bu3sch.de>
References: <200902211625.55377.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:60250 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752511AbZCSRhA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2009 13:37:00 -0400
In-Reply-To: <200902211625.55377.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 21 February 2009 16:25:55 Michael Buesch wrote:
> The watchdog just triggered on a machine running 2.6.28.6 with
> compat-wireless-2009-02-20. the realtek device shares a bridge with a b43
> wireless AP.
> 
> So well, I'm not 100% sure whose fault this is, but I'd almost certainly say it's
> not b43's fault.
> At the time this happened, the b43 interface was completely idle and the r8169
> interface was loaded with about 10kiB/sec on the TX side.
> 
> After the watchdog triggered and reset the interface, traffic resumed and it's
> still working properly without a reboot.
> 
> 
> [97355.804023] ------------[ cut here ]------------
> [97355.804063] WARNING: at net/sched/sch_generic.c:226 dev_watchdog+0x22e/0x240()
> [97355.804099] NETDEV WATCHDOG: eth0 (r8169): transmit timed out
> [97355.804122] Modules linked in: b43 ssb mac80211 cfg80211 [last unloaded: cfg80211]
> [97355.804173] Pid: 0, comm: swapper Not tainted 2.6.28.6 #8
> [97355.804196] Call Trace:
> [97355.804214]  <IRQ>  [<ffffffff80240abd>] warn_slowpath+0xcd/0x110
> [97355.804250]  [<ffffffff8072e42f>] br_dev_queue_push_xmit+0x5f/0x90
> [97355.804276]  [<ffffffff8072d6e3>] br_dev_xmit+0x73/0xa0
> [97355.804301]  [<ffffffff8060e94c>] dev_queue_xmit+0xfc/0x570
> [97355.804326]  [<ffffffff8023778c>] find_busiest_group+0x1dc/0x970
> [97355.804351]  [<ffffffff80236ca8>] enqueue_task_fair+0x178/0x180
> [97355.804378]  [<ffffffff80235042>] activate_task+0x22/0x30
> [97355.804403]  [<ffffffff80239ea6>] try_to_wake_up+0xf6/0x1a0
> [97355.804429]  [<ffffffff8040ba21>] strlcpy+0x41/0x50
> [97355.804453]  [<ffffffff80629dbe>] dev_watchdog+0x22e/0x240
> [97355.804478]  [<ffffffff80235a73>] __wake_up+0x43/0x70
> [97355.804503]  [<ffffffff80253870>] delayed_work_timer_fn+0x0/0x40
> [97355.804529]  [<ffffffff80629b90>] dev_watchdog+0x0/0x240
> [97355.804554]  [<ffffffff8024b1be>] run_timer_softirq+0x12e/0x200
> [97355.804580]  [<ffffffff8025accc>] ktime_get+0xc/0x50
> [97355.804604]  [<ffffffff80246803>] __do_softirq+0x93/0x160
> [97355.804629]  [<ffffffff8020d49c>] call_softirq+0x1c/0x30
> [97355.804654]  [<ffffffff8020ee45>] do_softirq+0x35/0x70
> [97355.804677]  [<ffffffff802464f5>] irq_exit+0x95/0xa0
> [97355.804703]  [<ffffffff802200b6>] smp_apic_timer_interrupt+0x86/0xd0
> [97355.804729]  [<ffffffff8020ceeb>] apic_timer_interrupt+0x6b/0x70
> [97355.804752]  <EOI>  [<ffffffff8021f7e0>] lapic_next_event+0x0/0x20
> [97355.804785]  [<ffffffff8021468c>] mwait_idle+0x3c/0x50
> [97355.804808]  [<ffffffff8020b34e>] cpu_idle+0x5e/0xb0
> [97355.804831] ---[ end trace 5bbed3ec50983ad4 ]---
> [97355.822193] r8169: eth0: link up
> [97457.822002] r8169: eth0: link up
> 


It happened again. But b43 was _not_ running this time. So it clearly is r8169's fault.

Is this simply due to r8169 being cheap-ass hardware, or could this
be a real driver bug?


[528699.780019] ------------[ cut here ]------------
[528699.780059] WARNING: at net/sched/sch_generic.c:226 dev_watchdog+0x22e/0x240
()
[528699.780095] NETDEV WATCHDOG: eth0 (r8169): transmit timed out
[528699.780118] Modules linked in: b43 ssb mac80211 cfg80211
[528699.780154] Pid: 0, comm: swapper Tainted: G        W  2.6.28.7 #9
[528699.780178] Call Trace:
[528699.780196]  <IRQ>  [<ffffffff80240aed>] warn_slowpath+0xcd/0x110
[528699.780231]  [<ffffffff806c7372>] ipt_do_table+0x242/0x5c0
[528699.780256]  [<ffffffff8023778c>] find_busiest_group+0x1dc/0x970
[528699.780282]  [<ffffffff80236ca8>] enqueue_task_fair+0x178/0x180
[528699.780309]  [<ffffffff80235042>] activate_task+0x22/0x30
[528699.780335]  [<ffffffff8024b904>] lock_timer_base+0x34/0x70
[528699.780360]  [<ffffffff8024baea>] __mod_timer+0xaa/0xc0
[528699.780385]  [<ffffffff8025d838>] getnstimeofday+0x58/0xe0
[528699.780412]  [<ffffffff8040ba61>] strlcpy+0x41/0x50
[528699.780436]  [<ffffffff80629dfe>] dev_watchdog+0x22e/0x240
[528699.780461]  [<ffffffff8023dba2>] scheduler_tick+0xd2/0x230
[528699.780486]  [<ffffffff80629bd0>] dev_watchdog+0x0/0x240
[528699.780511]  [<ffffffff8024b1ee>] run_timer_softirq+0x12e/0x200
[528699.780536]  [<ffffffff8025acfc>] ktime_get+0xc/0x50
[528699.780561]  [<ffffffff80246833>] __do_softirq+0x93/0x160
[528699.780586]  [<ffffffff8020d49c>] call_softirq+0x1c/0x30
[528699.780611]  [<ffffffff8020ee45>] do_softirq+0x35/0x70
[528699.780635]  [<ffffffff80246525>] irq_exit+0x95/0xa0
[528699.780660]  [<ffffffff802200b6>] smp_apic_timer_interrupt+0x86/0xd0
[528699.780687]  [<ffffffff8020ceeb>] apic_timer_interrupt+0x6b/0x70
[528699.780710]  <EOI>  [<ffffffff8021f7e0>] lapic_next_event+0x0/0x20
[528699.780743]  [<ffffffff8021468c>] mwait_idle+0x3c/0x50
[528699.780767]  [<ffffffff8020b34e>] cpu_idle+0x5e/0xb0
[528699.780789] ---[ end trace 7be3855cebbcf43d ]---
[528699.798309] r8169: eth0: link up
[531183.797758] r8169: eth0: link up
[539655.802759] r8169: eth0: link up

mb@quimby:~$ uname -a
Linux quimby 2.6.28.7 #9 SMP Fri Mar 13 12:32:49 CET 2009 x86_64 GNU/Linux


-- 
Greetings, Michael.
