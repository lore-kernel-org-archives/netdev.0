From: Dave Jones <davej@codemonkey.org.uk>
Subject: net/ipv6/ip6_flowlabel.c:543 suspicious rcu_dereference_check()
 usage!
Date: Tue, 2 Feb 2016 14:59:33 -0500
Message-ID: <20160202195933.GA6302@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:57510 "EHLO
	arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932078AbcBBT7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 14:59:37 -0500
Received: from [209.6.119.210] (helo=wopr.kernelslacker.org)
	by arcturus.aphlor.org with esmtpsa (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256)
	(Exim 4.86)
	(envelope-from <davej@codemonkey.org.uk>)
	id 1aQh6s-0000jq-W7
	for netdev@vger.kernel.org; Tue, 02 Feb 2016 19:59:35 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

===============================
[ INFO: suspicious RCU usage. ]
4.5.0-rc2-think+ #2 Tainted: G        W      
-------------------------------
net/ipv6/ip6_flowlabel.c:543 suspicious rcu_dereference_check() usage!

other info that might help us debug this:


rcu_scheduler_active = 1, debug_locks = 1
2 locks held by trinity-c0/21982:
 #0:  (sk_lock-AF_INET6){+.+.+.}, at: [<ffffffffb1161dec>] do_ipv6_setsockopt.isra.5+0x1bc/0x1c20
 #1:  (ip6_sk_fl_lock){+.....}, at: [<ffffffffb11a2784>] ipv6_flowlabel_opt+0x584/0x1b00

stack backtrace:
CPU: 1 PID: 21982 Comm: trinity-c0 Tainted: G        W       4.5.0-rc2-think+ #2
 ffffffffb1821f20 00000000e98d3751 ffff88032ccaf798 ffffffffb076bd50
 0000000041b58ab3 ffffffffb19d0db1 ffffffffb076bca5 0000000000000001
 ffff8803011308e8 00000000e98d3751 ffff88032ccaf770 0000000000000003
Call Trace:
 [<ffffffffb076bd50>] dump_stack+0xab/0x11b
 [<ffffffffb076bca5>] ? _atomic_dec_and_lock+0x95/0x95
 [<ffffffffb01867f6>] lockdep_rcu_suspicious+0xe6/0x100
 [<ffffffffb11a282b>] ipv6_flowlabel_opt+0x62b/0x1b00
 [<ffffffffb11a2200>] ? ipv6_flowlabel_opt_get+0x6b0/0x6b0
 [<ffffffffb01275ca>] ? preempt_count_sub+0x1a/0x140
 [<ffffffffb018a5d8>] ? mark_held_locks+0xc8/0x140
 [<ffffffffb00ea294>] ? __local_bh_enable_ip+0x64/0xc0
 [<ffffffffb0f08c4a>] ? lock_sock_nested+0x5a/0xe0
 [<ffffffffb018a9ed>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffffb00ea294>] ? __local_bh_enable_ip+0x64/0xc0
 [<ffffffffb0f08c99>] ? lock_sock_nested+0xa9/0xe0
 [<ffffffffb11627f4>] do_ipv6_setsockopt.isra.5+0xbc4/0x1c20
 [<ffffffffb01b642f>] ? debug_lockdep_rcu_enabled.part.34+0x1f/0x40
 [<ffffffffb1161c30>] ? ip6_ra_control+0x1d0/0x1d0
 [<ffffffffb0189974>] ? mark_lock+0xf4/0xc90
 [<ffffffffb0189880>] ? print_usage_bug+0x520/0x520
 [<ffffffffb0189880>] ? print_usage_bug+0x520/0x520
 [<ffffffffb0016979>] ? native_sched_clock+0x69/0x160
 [<ffffffffb018b71e>] ? __lock_acquire+0x7ee/0x2ec0
 [<ffffffffb0189974>] ? mark_lock+0xf4/0xc90
 [<ffffffffb0189880>] ? print_usage_bug+0x520/0x520
 [<ffffffffb018af30>] ? debug_check_no_locks_freed+0x200/0x200
 [<ffffffffb018b71e>] ? __lock_acquire+0x7ee/0x2ec0
 [<ffffffffb0127679>] ? preempt_count_sub+0xc9/0x140
 [<ffffffffb07b4177>] ? debug_smp_processor_id+0x17/0x20
 [<ffffffffb018152e>] ? get_lock_stats+0x4e/0xf0
 [<ffffffffb0127679>] ? preempt_count_sub+0xc9/0x140
 [<ffffffffb01822a3>] ? trace_hardirqs_off_caller+0x73/0x150
 [<ffffffffb018238d>] ? trace_hardirqs_off+0xd/0x10
 [<ffffffffb0263b98>] ? __acct_update_integrals+0x108/0x260
 [<ffffffffb0263a90>] ? taskstats_exit+0x5f0/0x5f0
 [<ffffffffb07b4177>] ? debug_smp_processor_id+0x17/0x20
 [<ffffffffb018152e>] ? get_lock_stats+0x4e/0xf0
 [<ffffffffb0127679>] ? preempt_count_sub+0xc9/0x140
 [<ffffffffb0146181>] ? account_user_time+0x141/0x200
 [<ffffffffb1163881>] ipv6_setsockopt+0x31/0xe0
 [<ffffffffb10157a1>] tcp_setsockopt+0x71/0xd0
 [<ffffffffb0f07a3c>] sock_common_setsockopt+0x6c/0xb0
 [<ffffffffb0f04ee6>] SyS_setsockopt+0x116/0x200
 [<ffffffffb0f04dd0>] ? SyS_recv+0x20/0x20
 [<ffffffffb11f625a>] ? int_ret_from_sys_call+0x52/0x9f
 [<ffffffffb0002017>] ? trace_hardirqs_on_thunk+0x17/0x19
 [<ffffffffb11f60d7>] entry_SYSCALL_64_fastpath+0x12/0x6b
