From: Dave Jones <davej@codemonkey.org.uk>
Subject: 2.6.25rc7 lockdep trace
Date: Thu, 27 Mar 2008 20:00:13 -0400
Message-ID: <20080328000013.GA8193@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from testure.choralone.org ([194.9.77.134]:41296 "EHLO
	testure.choralone.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752738AbYC1AAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 20:00:20 -0400
Received: from c-66-30-206-50.hsd1.ma.comcast.net ([66.30.206.50] helo=gelk.kernelslacker.org)
	by testure.choralone.org with esmtpsa (TLS-1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <davej@gelk.kernelslacker.org>)
	id 1Jf1x3-0003oN-FQ
	for netdev@vger.kernel.org; Thu, 27 Mar 2008 23:56:09 +0000
Received: from davej by gelk.kernelslacker.org with local (Exim 4.68)
	(envelope-from <davej@gelk.kernelslacker.org>)
	id 1Jf20z-00028L-7V
	for netdev@vger.kernel.org; Thu, 27 Mar 2008 20:00:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I see this every time I shut down.

	Dave


 
 =======================================================
 [ INFO: possible circular locking dependency detected ]
 2.6.25-0.161.rc7.fc9.i686 #1
 -------------------------------------------------------
 NetworkManager/2308 is trying to acquire lock:
  (events){--..}, at: [flush_workqueue+0/133] flush_workqueue+0x0/0x85
 
 but task is already holding lock:
  (rtnl_mutex){--..}, at: [rtnetlink_rcv+18/38] rtnetlink_rcv+0x12/0x26
 
 which lock already depends on the new lock.
 
 
 the existing dependency chain (in reverse order) is:
 
 -> #2 (rtnl_mutex){--..}:
        [__lock_acquire+2713/3089] __lock_acquire+0xa99/0xc11
        [lock_acquire+106/144] lock_acquire+0x6a/0x90
        [mutex_lock_nested+219/625] mutex_lock_nested+0xdb/0x271
        [rtnl_lock+15/17] rtnl_lock+0xf/0x11
        [linkwatch_event+8/34] linkwatch_event+0x8/0x22
        [run_workqueue+211/417] run_workqueue+0xd3/0x1a1
        [worker_thread+182/194] worker_thread+0xb6/0xc2
        [kthread+59/97] kthread+0x3b/0x61
        [kernel_thread_helper+7/16] kernel_thread_helper+0x7/0x10
        [<ffffffff>] 0xffffffff
 
 -> #1 ((linkwatch_work).work){--..}:
        [__lock_acquire+2713/3089] __lock_acquire+0xa99/0xc11
        [lock_acquire+106/144] lock_acquire+0x6a/0x90
        [run_workqueue+205/417] run_workqueue+0xcd/0x1a1
        [worker_thread+182/194] worker_thread+0xb6/0xc2
        [kthread+59/97] kthread+0x3b/0x61
        [kernel_thread_helper+7/16] kernel_thread_helper+0x7/0x10
        [<ffffffff>] 0xffffffff
 
 -> #0 (events){--..}:
        [__lock_acquire+2488/3089] __lock_acquire+0x9b8/0xc11
        [lock_acquire+106/144] lock_acquire+0x6a/0x90
        [flush_workqueue+68/133] flush_workqueue+0x44/0x85
        [flush_scheduled_work+13/15] flush_scheduled_work+0xd/0xf
        [<d096d80a>] tulip_down+0x20/0x1a3 [tulip]
        [<d096e2b5>] tulip_close+0x24/0xd6 [tulip]
        [dev_close+82/111] dev_close+0x52/0x6f
        [dev_change_flags+159/338] dev_change_flags+0x9f/0x152
        [do_setlink+586/764] do_setlink+0x24a/0x2fc
        [rtnl_setlink+226/230] rtnl_setlink+0xe2/0xe6
        [rtnetlink_rcv_msg+418/444] rtnetlink_rcv_msg+0x1a2/0x1bc
        [netlink_rcv_skb+48/134] netlink_rcv_skb+0x30/0x86
        [rtnetlink_rcv+30/38] rtnetlink_rcv+0x1e/0x26
        [netlink_unicast+439/533] netlink_unicast+0x1b7/0x215
        [netlink_sendmsg+600/613] netlink_sendmsg+0x258/0x265
        [sock_sendmsg+222/249] sock_sendmsg+0xde/0xf9
        [sys_sendmsg+319/402] sys_sendmsg+0x13f/0x192
        [sys_socketcall+363/390] sys_socketcall+0x16b/0x186
        [syscall_call+7/11] syscall_call+0x7/0xb
        [<ffffffff>] 0xffffffff
 
 other info that might help us debug this:
 
 1 lock held by NetworkManager/2308:
  #0:  (rtnl_mutex){--..}, at: [rtnetlink_rcv+18/38] rtnetlink_rcv+0x12/0x26
 
 stack backtrace:
 Pid: 2308, comm: NetworkManager Not tainted 2.6.25-0.161.rc7.fc9.i686 #1
  [print_circular_bug_tail+91/102] print_circular_bug_tail+0x5b/0x66
  [print_circular_bug_entry+57/67] ? print_circular_bug_entry+0x39/0x43
  [__lock_acquire+2488/3089] __lock_acquire+0x9b8/0xc11
  [_spin_unlock_irq+34/47] ? _spin_unlock_irq+0x22/0x2f
  [lock_acquire+106/144] lock_acquire+0x6a/0x90
  [flush_workqueue+0/133] ? flush_workqueue+0x0/0x85
  [flush_workqueue+68/133] flush_workqueue+0x44/0x85
  [flush_workqueue+0/133] ? flush_workqueue+0x0/0x85
  [flush_scheduled_work+13/15] flush_scheduled_work+0xd/0xf
  [<d096d80a>] tulip_down+0x20/0x1a3 [tulip]
  [trace_hardirqs_on+233/266] ? trace_hardirqs_on+0xe9/0x10a
  [dev_deactivate+177/222] ? dev_deactivate+0xb1/0xde
  [<d096e2b5>] tulip_close+0x24/0xd6 [tulip]
  [dev_close+82/111] dev_close+0x52/0x6f
  [dev_change_flags+159/338] dev_change_flags+0x9f/0x152
  [do_setlink+586/764] do_setlink+0x24a/0x2fc
  [_read_unlock+29/32] ? _read_unlock+0x1d/0x20
  [rtnl_setlink+226/230] rtnl_setlink+0xe2/0xe6
  [rtnl_setlink+0/230] ? rtnl_setlink+0x0/0xe6
  [rtnetlink_rcv_msg+418/444] rtnetlink_rcv_msg+0x1a2/0x1bc
  [rtnetlink_rcv_msg+0/444] ? rtnetlink_rcv_msg+0x0/0x1bc
  [netlink_rcv_skb+48/134] netlink_rcv_skb+0x30/0x86
  [rtnetlink_rcv+30/38] rtnetlink_rcv+0x1e/0x26
  [netlink_unicast+439/533] netlink_unicast+0x1b7/0x215
  [netlink_sendmsg+600/613] netlink_sendmsg+0x258/0x265
  [sock_sendmsg+222/249] sock_sendmsg+0xde/0xf9
  [autoremove_wake_function+0/51] ? autoremove_wake_function+0x0/0x33
  [native_sched_clock+181/209] ? native_sched_clock+0xb5/0xd1
  [sched_clock+8/11] ? sched_clock+0x8/0xb
  [lock_release_holdtime+26/277] ? lock_release_holdtime+0x1a/0x115
  [fget_light+142/185] ? fget_light+0x8e/0xb9
  [copy_from_user+57/289] ? copy_from_user+0x39/0x121
  [verify_iovec+64/111] ? verify_iovec+0x40/0x6f
  [sys_sendmsg+319/402] sys_sendmsg+0x13f/0x192
  [sys_recvmsg+366/379] ? sys_recvmsg+0x16e/0x17b
  [check_object+304/388] ? check_object+0x130/0x184
  [check_object+304/388] ? check_object+0x130/0x184
  [kmem_cache_free+186/207] ? kmem_cache_free+0xba/0xcf
  [trace_hardirqs_on+233/266] ? trace_hardirqs_on+0xe9/0x10a
  [d_free+59/77] ? d_free+0x3b/0x4d
  [d_free+59/77] ? d_free+0x3b/0x4d
  [sys_socketcall+363/390] sys_socketcall+0x16b/0x186
  [syscall_call+7/11] syscall_call+0x7/0xb
  =======================

-- 
http://www.codemonkey.org.uk
