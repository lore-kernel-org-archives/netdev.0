From: Dave Jones <davej@codemonkey.org.uk>
Subject: suspicious rcu_dereference in tcp_v6_send_synack
Date: Thu, 7 Jan 2016 10:32:48 -0500
Message-ID: <20160107153248.GA30472@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:48622 "EHLO
	arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752849AbcAGPcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 10:32:50 -0500
Received: from [209.6.119.210] (helo=wopr.kernelslacker.org)
	by arcturus.aphlor.org with esmtpsa (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256)
	(Exim 4.86)
	(envelope-from <davej@codemonkey.org.uk>)
	id 1aHCYT-0008I8-CT
	for netdev@vger.kernel.org; Thu, 07 Jan 2016 15:32:49 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

===============================
[ INFO: suspicious RCU usage. ]
4.4.0-rc8-firewall+ #1 Not tainted
-------------------------------
net/ipv6/tcp_ipv6.c:465 suspicious rcu_dereference_check() usage!

other info that might help us debug this:


rcu_scheduler_active = 1, debug_locks = 1
1 lock held by swapper/1/0:
 #0:  (((&req->rsk_timer))){+.-...}, at: [<ffffffff99113285>] call_timer_fn+0x5/0x3f0

stack backtrace:
CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.4.0-rc8-firewall+ #1
 0000000000000000 ffff8801d7a07b28 ffffffff9948b3b5 ffff8801d6046500
 ffff8801d7a07b58 ffffffff990e9b7a ffff8801cd356240 0000000000000000
 ffff8801d23b1698 ffff8801d23b0c40 ffff8801d7a07ba8 ffffffff99b635d2
Call Trace:
 <IRQ>  [<ffffffff9948b3b5>] dump_stack+0x4e/0x79
 [<ffffffff990e9b7a>] lockdep_rcu_suspicious+0xea/0x110
 [<ffffffff99b635d2>] tcp_v6_send_synack+0x2c2/0x350
 [<ffffffff99a8550d>] tcp_rtx_synack+0xdd/0x180
 [<ffffffff99a85430>] ? tcp_send_probe0+0x1a0/0x1a0
 [<ffffffff99a5f0a4>] reqsk_timer_handler+0x4c4/0x530
 [<ffffffff99a5ebe0>] ? inet_csk_reqsk_queue_drop+0x3a0/0x3a0
 [<ffffffff990e0f2b>] ? __lock_is_held+0x9b/0xd0
 [<ffffffff991133b2>] call_timer_fn+0x132/0x3f0
 [<ffffffff99113285>] ? call_timer_fn+0x5/0x3f0
 [<ffffffff99a5ebe0>] ? inet_csk_reqsk_queue_drop+0x3a0/0x3a0
 [<ffffffff99113280>] ? process_timeout+0x10/0x10
 [<ffffffff990e44d2>] ? trace_hardirqs_on_caller+0x192/0x2a0
 [<ffffffff990b52ea>] ? preempt_count_sub+0x1a/0x130
 [<ffffffff99113cab>] run_timer_softirq+0x47b/0x590
 [<ffffffff99a5ebe0>] ? inet_csk_reqsk_queue_drop+0x3a0/0x3a0
 [<ffffffff99113830>] ? internal_add_timer+0x110/0x110
 [<ffffffff990e0eb8>] ? __lock_is_held+0x28/0xd0
 [<ffffffff99076fd2>] __do_softirq+0x1b2/0x5c0
 [<ffffffff9907762c>] irq_exit+0xfc/0x110
 [<ffffffff99c12abf>] smp_apic_timer_interrupt+0x5f/0x70
 [<ffffffff99c112bb>] apic_timer_interrupt+0x8b/0x90
 <EOI>  [<ffffffff998dd547>] ? cpuidle_enter_state+0x1c7/0x460
 [<ffffffff998dd542>] ? cpuidle_enter_state+0x1c2/0x460
 [<ffffffff99107289>] ? rcu_eqs_enter_common+0x139/0x280
 [<ffffffff998dd847>] cpuidle_enter+0x17/0x20
 [<ffffffff990dbd92>] cpu_startup_entry+0x4d2/0x5b0
 [<ffffffff990db8c0>] ? default_idle_call+0x60/0x60
 [<ffffffff9912d714>] ? clockevents_config_and_register+0x64/0x70
 [<ffffffff9904d785>] ? setup_APIC_timer+0x115/0x120
 [<ffffffff9904be1a>] start_secondary+0x23a/0x2a0
 [<ffffffff9904bbe0>] ? set_cpu_sibling_map+0x9c0/0x9c0
