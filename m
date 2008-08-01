From: Dave Jones <davej@codemonkey.org.uk>
Subject: _xmit_ETHER lockdep warning. (-git8)
Date: Fri, 1 Aug 2008 15:29:47 -0400
Message-ID: <20080801192947.GA26210@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from testure.choralone.org ([194.9.77.134]:40717 "EHLO
	testure.choralone.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934AbYHAT3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 15:29:16 -0400
Received: from davej by testure.choralone.org with local (Exim 4.69)
	(envelope-from <davej@codemonkey.org.uk>)
	id 1KP0Jv-0001PB-LB
	for netdev@vger.kernel.org; Fri, 01 Aug 2008 20:29:47 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A week or so old, but possibly still valid..

https://bugzilla.redhat.com/show_bug.cgi?id=456521


=============================================
[ INFO: possible recursive locking detected ]
2.6.27-0.166.rc0.git8.fc10.x86_64 #1
---------------------------------------------
swapper/0 is trying to acquire lock:
 (_xmit_ETHER){-+..}, at: [<ffffffff812828a3>] dev_watchdog+0x41/0x1a7

but task is already holding lock:
 (_xmit_ETHER){-+..}, at: [<ffffffff812828a3>] dev_watchdog+0x41/0x1a7

other info that might help us debug this:
1 lock held by swapper/0:
 #0:  (_xmit_ETHER){-+..}, at: [<ffffffff812828a3>] dev_watchdog+0x41/0x1a7

stack backtrace:
Pid: 0, comm: swapper Not tainted 2.6.27-0.166.rc0.git8.fc10.x86_64 #1

Call Trace:
 <IRQ>  [<ffffffff81061b46>] __lock_acquire+0x790/0xaa7
 [<ffffffff81060d80>] ? trace_hardirqs_on+0xd/0xf
 [<ffffffff812828a3>] ? dev_watchdog+0x41/0x1a7
 [<ffffffff81061ef3>] lock_acquire+0x96/0xc3
 [<ffffffff812828a3>] ? dev_watchdog+0x41/0x1a7
 [<ffffffff812f5eb8>] _spin_lock+0x2b/0x58
 [<ffffffff812828a3>] dev_watchdog+0x41/0x1a7
 [<ffffffff81282862>] ? dev_watchdog+0x0/0x1a7
 [<ffffffff81048ba6>] run_timer_softirq+0x17f/0x1f7
 [<ffffffff810450eb>] __do_softirq+0x83/0x110
 [<ffffffff8100dcbc>] call_softirq+0x1c/0x28
 [<ffffffff8100ef81>] do_softirq+0x52/0xb5
 [<ffffffff81044c95>] irq_exit+0x53/0xa0
 [<ffffffff8101d160>] smp_apic_timer_interrupt+0x94/0xad
 [<ffffffff8100d4c8>] apic_timer_interrupt+0x88/0x90
 <EOI>  [<ffffffff81022880>] ? native_safe_halt+0x6/0x8
 [<ffffffff81060d80>] ? trace_hardirqs_on+0xd/0xf
 [<ffffffff81013537>] ? default_idle+0x2f/0x51
 [<ffffffff81013661>] ? c1e_idle+0x108/0x10f
 [<ffffffff812f9204>] ? atomic_notifier_call_chain+0x14/0x16
 [<ffffffff8100b2d6>] ? cpu_idle+0x92/0xeb
 [<ffffffff812efbef>] ? start_secondary+0x1a1/0x1a3

-- 
http://www.codemonkey.org.uk
