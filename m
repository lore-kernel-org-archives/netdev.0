From: Dave Jones <davej@codemonkey.org.uk>
Subject: lockdep trace from rc2.
Date: Sun, 24 Feb 2008 21:22:37 -0500
Message-ID: <20080225022237.GA3907@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from testure.choralone.org ([194.9.77.134]:59812 "EHLO
	testure.choralone.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753501AbYBYDCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2008 22:02:43 -0500
Received: from c-66-30-206-50.hsd1.ma.comcast.net ([66.30.206.50] helo=gelk.kernelslacker.org)
	by testure.choralone.org with esmtpsa (TLS-1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <davej@gelk.kernelslacker.org>)
	id 1JTSzJ-0004FV-5Y
	for netdev@vger.kernel.org; Mon, 25 Feb 2008 02:22:41 +0000
Received: from davej by gelk.kernelslacker.org with local (Exim 4.68)
	(envelope-from <davej@gelk.kernelslacker.org>)
	id 1JTSzF-0001XL-2x
	for netdev@vger.kernel.org; Sun, 24 Feb 2008 21:22:37 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

https://bugzilla.redhat.com/show_bug.cgi?id=431038 has some more info,
but the trace is below...
I'll get an rc3 kernel built and ask the user to retest, but in case this
isn't a known problem, I'm forwarding this here.

	Dave
 
Feb 24 17:53:21 cirithungol kernel: =======================================================
Feb 24 17:53:21 cirithungol kernel: [ INFO: possible circular locking dependency detected ]
Feb 24 17:53:21 cirithungol kernel: 2.6.25-0.54.rc2.fc9 #1
Feb 24 17:53:21 cirithungol kernel: -------------------------------------------------------
Feb 24 17:53:21 cirithungol kernel: ip/10650 is trying to acquire lock:
Feb 24 17:53:21 cirithungol kernel:  (events){--..}, at: [<c0436f9a>] flush_workqueue+0x0/0x85
Feb 24 17:53:21 cirithungol kernel: 
Feb 24 17:53:21 cirithungol kernel: but task is already holding lock:
Feb 24 17:53:21 cirithungol kernel:  (rtnl_mutex){--..}, at: [<c05cea31>] rtnetlink_rcv+0x12/0x26
Feb 24 17:53:21 cirithungol kernel: 
Feb 24 17:53:21 cirithungol kernel: which lock already depends on the new lock.
Feb 24 17:53:21 cirithungol kernel: 
Feb 24 17:53:21 cirithungol kernel: 
Feb 24 17:53:21 cirithungol kernel: the existing dependency chain (in reverse order) is:
Feb 24 17:53:21 cirithungol kernel: 
Feb 24 17:53:21 cirithungol kernel: -> #2 (rtnl_mutex){--..}:
Feb 24 17:53:21 cirithungol kernel:        [<c04458f7>] __lock_acquire+0xa7c/0xbf4
Feb 24 17:53:21 cirithungol kernel:        [<c05cea1d>] rtnl_lock+0xf/0x11
Feb 24 17:53:21 cirithungol kernel:        [<c04415dc>] tick_program_event+0x31/0x55
Feb 24 17:53:21 cirithungol kernel:        [<c0445ad9>] lock_acquire+0x6a/0x90
Feb 24 17:53:21 cirithungol kernel:        [<c05cea1d>] rtnl_lock+0xf/0x11
Feb 24 17:53:21 cirithungol kernel:        [<c0638d21>] mutex_lock_nested+0xdb/0x271
Feb 24 17:53:21 cirithungol kernel:        [<c05cea1d>] rtnl_lock+0xf/0x11
Feb 24 17:53:21 cirithungol kernel:last message repeated 2 times
Feb 24 17:53:21 cirithungol kernel:        [<c05cf755>] linkwatch_event+0x8/0x22
Feb 24 17:53:21 cirithungol kernel:        [<c043675c>] run_workqueue+0xd3/0x1a1
Feb 24 17:53:21 cirithungol kernel:        [<c043671a>] run_workqueue+0x91/0x1a1
Feb 24 17:53:21 cirithungol kernel:        [<c05cf74d>] linkwatch_event+0x0/0x22
Feb 24 17:53:21 cirithungol kernel:        [<c04368e0>] worker_thread+0xb6/0xc2
Feb 24 17:53:21 cirithungol kernel:        [<c0439733>] autoremove_wake_function+0x0/0x33
Feb 24 17:53:21 cirithungol kernel:        [<c043682a>] worker_thread+0x0/0xc2
Feb 24 17:53:21 cirithungol kernel:        [<c04394e2>] kthread+0x3b/0x61
Feb 24 17:53:21 cirithungol kernel:        [<c04394a7>] kthread+0x0/0x61
Feb 24 17:53:21 cirithungol kernel:        [<c0406a1b>] kernel_thread_helper+0x7/0x10
Feb 24 17:53:21 cirithungol kernel:        [<ffffffff>] 0xffffffff
Feb 24 17:53:21 cirithungol kernel: 
Feb 24 17:53:21 cirithungol kernel: -> #1 ((linkwatch_work).work){--..}:
Feb 24 17:53:21 cirithungol kernel:        [<c04458f7>] __lock_acquire+0xa7c/0xbf4
Feb 24 17:53:21 cirithungol kernel:        [<c043671a>] run_workqueue+0x91/0x1a1
Feb 24 17:53:21 cirithungol kernel:        [<c0445ad9>] lock_acquire+0x6a/0x90
Feb 24 17:53:21 cirithungol kernel:        [<c043671a>] run_workqueue+0x91/0x1a1
Feb 24 17:53:21 cirithungol kernel:        [<c0436756>] run_workqueue+0xcd/0x1a1
Feb 24 17:53:21 cirithungol kernel:        [<c043671a>] run_workqueue+0x91/0x1a1
Feb 24 17:53:21 cirithungol kernel:        [<c05cf74d>] linkwatch_event+0x0/0x22
Feb 24 17:53:21 cirithungol kernel:        [<c04368e0>] worker_thread+0xb6/0xc2
Feb 24 17:53:21 cirithungol kernel:        [<c0439733>] autoremove_wake_function+0x0/0x33
Feb 24 17:53:21 cirithungol kernel:        [<c043682a>] worker_thread+0x0/0xc2
Feb 24 17:53:21 cirithungol kernel:        [<c04394e2>] kthread+0x3b/0x61
Feb 24 17:53:21 cirithungol kernel:        [<c04394a7>] kthread+0x0/0x61
Feb 24 17:53:21 cirithungol kernel:        [<c0406a1b>] kernel_thread_helper+0x7/0x10
Feb 24 17:53:21 cirithungol kernel:        [<ffffffff>] 0xffffffff
Feb 24 17:53:21 cirithungol kernel: 
Feb 24 17:53:21 cirithungol kernel: -> #0 (events){--..}:
Feb 24 17:53:21 cirithungol kernel:        [<c0444ad8>] print_circular_bug_entry+0x39/0x43
Feb 24 17:53:21 cirithungol kernel:        [<c0445816>] __lock_acquire+0x99b/0xbf4
Feb 24 17:53:21 cirithungol kernel:        [<c040a354>] native_sched_clock+0xb5/0xd1
Feb 24 17:53:21 cirithungol kernel:        [<c0445ad9>] lock_acquire+0x6a/0x90
Feb 24 17:53:21 cirithungol kernel:        [<c0436f9a>] flush_workqueue+0x0/0x85
Feb 24 17:53:21 cirithungol kernel:        [<c0436fde>] flush_workqueue+0x44/0x85
Feb 24 17:53:21 cirithungol kernel:        [<c0436f9a>] flush_workqueue+0x0/0x85
Feb 24 17:53:21 cirithungol kernel:        [<c043702c>] flush_scheduled_work+0xd/0xf
Feb 24 17:53:21 cirithungol kernel:        [<f8f4380a>] tulip_down+0x20/0x1a3 [tulip]
Feb 24 17:53:21 cirithungol kernel:        [<c044495b>] trace_hardirqs_on+0xe9/0x10a
Feb 24 17:53:21 cirithungol kernel:        [<c05d5103>] dev_deactivate+0xb1/0xde
Feb 24 17:53:21 cirithungol kernel:        [<f8f442b5>] tulip_close+0x24/0xd6 [tulip]
Feb 24 17:53:21 cirithungol kernel:        [<c05c7265>] dev_close+0x52/0x6f
Feb 24 17:53:21 cirithungol kernel:        [<c05c6fbc>] dev_change_flags+0x9f/0x152
Feb 24 17:53:21 cirithungol kernel:        [<c05cdb5e>] do_setlink+0x258/0x34a
Feb 24 17:53:21 cirithungol kernel:        [<c05cee5b>] rtnl_newlink+0x257/0x3ad
Feb 24 17:53:21 cirithungol kernel:        [<c05cec70>] rtnl_newlink+0x6c/0x3ad
Feb 24 17:53:21 cirithungol kernel:        [<c05cecb1>] rtnl_newlink+0xad/0x3ad
Feb 24 17:53:21 cirithungol kernel:        [<c04d880c>] selinux_netlink_recv+0x4d/0x57
Feb 24 17:53:21 cirithungol kernel:        [<c05cec04>] rtnl_newlink+0x0/0x3ad
Feb 24 17:53:21 cirithungol kernel:        [<c05cebea>] rtnetlink_rcv_msg+0x1a5/0x1bf
Feb 24 17:53:21 cirithungol kernel:        [<c05cea45>] rtnetlink_rcv_msg+0x0/0x1bf
Feb 24 17:53:21 cirithungol kernel:        [<c05dbcca>] netlink_rcv_skb+0x30/0x86
Feb 24 17:53:21 cirithungol kernel:        [<c05cea3d>] rtnetlink_rcv+0x1e/0x26
Feb 24 17:53:21 cirithungol kernel:        [<c05db7ee>] netlink_unicast+0x1b7/0x215
Feb 24 17:53:21 cirithungol kernel:        [<c05dbaa4>] netlink_sendmsg+0x258/0x265
Feb 24 17:53:21 cirithungol kernel:        [<c05bbd4b>] sock_sendmsg+0xde/0xf9
Feb 24 17:53:21 cirithungol kernel:        [<c0439733>] autoremove_wake_function+0x0/0x33
Feb 24 17:53:21 cirithungol kernel:        [<c040a354>] native_sched_clock+0xb5/0xd1
Feb 24 17:53:21 cirithungol kernel:        [<c04fec74>] copy_from_user+0x39/0x121
Feb 24 17:53:21 cirithungol kernel:        [<c05c2755>] verify_iovec+0x40/0x6f
Feb 24 17:53:21 cirithungol kernel:        [<c05bbea5>] sys_sendmsg+0x13f/0x192
Feb 24 17:53:21 cirithungol kernel:        [<c040a086>] sched_clock+0x8/0xb
Feb 24 17:53:21 cirithungol kernel:        [<c04431f1>] lock_release_holdtime+0x1a/0x115
Feb 24 17:53:21 cirithungol kernel:        [<c04447d3>] mark_held_locks+0x4e/0x66
Feb 24 17:53:21 cirithungol kernel:        [<c0484cd7>] __slab_alloc+0xc7/0x506
Feb 24 17:53:21 cirithungol kernel:        [<c05bd901>] release_sock+0xac/0xb4
Feb 24 17:53:21 cirithungol kernel:        [<c04770d8>] __vma_link+0x6e/0x73
Feb 24 17:53:21 cirithungol kernel:        [<c047712c>] vma_link+0x4f/0xc4
Feb 24 17:53:21 cirithungol kernel:        [<c040a354>] native_sched_clock+0xb5/0xd1
Feb 24 17:53:21 cirithungol kernel:        [<c05bcdd9>] sys_socketcall+0x16b/0x186
Feb 24 17:53:21 cirithungol kernel:        [<c0405d3e>] syscall_call+0x7/0xb
Feb 24 17:53:21 cirithungol kernel:        [<ffffffff>] 0xffffffff
Feb 24 17:53:21 cirithungol kernel: 
Feb 24 17:53:21 cirithungol kernel: other info that might help us debug this:
Feb 24 17:53:21 cirithungol kernel: 
Feb 24 17:53:21 cirithungol kernel: 1 lock held by ip/10650:
Feb 24 17:53:21 cirithungol kernel:  #0:  (rtnl_mutex){--..}, at: [<c05cea31>] rtnetlink_rcv+0x12/0x26
Feb 24 17:53:21 cirithungol kernel: 
Feb 24 17:53:21 cirithungol kernel: stack backtrace:
Feb 24 17:53:21 cirithungol kernel: Pid: 10650, comm: ip Not tainted 2.6.25-0.54.rc2.fc9 #1
Feb 24 17:53:21 cirithungol kernel:  [<c0444c65>] print_circular_bug_tail+0x5b/0x66
Feb 24 17:53:21 cirithungol kernel:  [<c0444ad8>] ? print_circular_bug_entry+0x39/0x43
Feb 24 17:53:21 cirithungol kernel:  [<c0445816>] __lock_acquire+0x99b/0xbf4
Feb 24 17:53:21 cirithungol kernel:  [<c040a354>] ? native_sched_clock+0xb5/0xd1
Feb 24 17:53:21 cirithungol kernel:  [<c0445ad9>] lock_acquire+0x6a/0x90
Feb 24 17:53:21 cirithungol kernel:  [<c0436f9a>] ? flush_workqueue+0x0/0x85
Feb 24 17:53:21 cirithungol kernel:  [<c0436fde>] flush_workqueue+0x44/0x85
Feb 24 17:53:21 cirithungol kernel:  [<c0436f9a>] ? flush_workqueue+0x0/0x85
Feb 24 17:53:21 cirithungol kernel:  [<c043702c>] flush_scheduled_work+0xd/0xf
Feb 24 17:53:21 cirithungol kernel:  [<f8f4380a>] tulip_down+0x20/0x1a3 [tulip]
Feb 24 17:53:21 cirithungol kernel:  [<c044495b>] ? trace_hardirqs_on+0xe9/0x10a
Feb 24 17:53:21 cirithungol kernel:  [<c05d5103>] ? dev_deactivate+0xb1/0xde
Feb 24 17:53:21 cirithungol kernel:  [<f8f442b5>] tulip_close+0x24/0xd6 [tulip]
Feb 24 17:53:21 cirithungol kernel:  [<c05c7265>] dev_close+0x52/0x6f
Feb 24 17:53:21 cirithungol kernel:  [<c05c6fbc>] dev_change_flags+0x9f/0x152
Feb 24 17:53:21 cirithungol kernel:  [<c05cdb5e>] do_setlink+0x258/0x34a
Feb 24 17:53:21 cirithungol kernel:  [<c05cee5b>] rtnl_newlink+0x257/0x3ad
Feb 24 17:53:21 cirithungol kernel:  [<c05cec70>] ? rtnl_newlink+0x6c/0x3ad
Feb 24 17:53:21 cirithungol kernel:  [<c05cecb1>] ? rtnl_newlink+0xad/0x3ad
Feb 24 17:53:21 cirithungol kernel:  [<c04d880c>] ? selinux_netlink_recv+0x4d/0x57
Feb 24 17:53:21 cirithungol kernel:  [<c05cec04>] ? rtnl_newlink+0x0/0x3ad
Feb 24 17:53:21 cirithungol kernel:  [<c05cebea>] rtnetlink_rcv_msg+0x1a5/0x1bf
Feb 24 17:53:21 cirithungol kernel:  [<c05cea45>] ? rtnetlink_rcv_msg+0x0/0x1bf
Feb 24 17:53:21 cirithungol kernel:  [<c05dbcca>] netlink_rcv_skb+0x30/0x86
Feb 24 17:53:21 cirithungol kernel:  [<c05cea3d>] rtnetlink_rcv+0x1e/0x26
Feb 24 17:53:21 cirithungol kernel:  [<c05db7ee>] netlink_unicast+0x1b7/0x215
Feb 24 17:53:21 cirithungol kernel:  [<c05dbaa4>] netlink_sendmsg+0x258/0x265
Feb 24 17:53:21 cirithungol kernel:  [<c05bbd4b>] sock_sendmsg+0xde/0xf9
Feb 24 17:53:21 cirithungol kernel:  [<c0439733>] ? autoremove_wake_function+0x0/0x33
Feb 24 17:53:21 cirithungol kernel:  [<c040a354>] ? native_sched_clock+0xb5/0xd1
Feb 24 17:53:21 cirithungol kernel:  [<c04fec74>] ? copy_from_user+0x39/0x121
Feb 24 17:53:21 cirithungol kernel:  [<c05c2755>] ? verify_iovec+0x40/0x6f
Feb 24 17:53:21 cirithungol kernel:  [<c05bbea5>] sys_sendmsg+0x13f/0x192
Feb 24 17:53:21 cirithungol kernel:  [<c040a086>] ? sched_clock+0x8/0xb
Feb 24 17:53:21 cirithungol kernel:  [<c04431f1>] ? lock_release_holdtime+0x1a/0x115
Feb 24 17:53:21 cirithungol kernel:  [<c04447d3>] ? mark_held_locks+0x4e/0x66
Feb 24 17:53:21 cirithungol kernel:  [<c0484cd7>] ? __slab_alloc+0xc7/0x506
Feb 24 17:53:21 cirithungol kernel:  [<c05bd901>] ? release_sock+0xac/0xb4
Feb 24 17:53:21 cirithungol kernel:  [<c04770d8>] ? __vma_link+0x6e/0x73
Feb 24 17:53:21 cirithungol kernel:  [<c047712c>] ? vma_link+0x4f/0xc4
Feb 24 17:53:21 cirithungol kernel:  [<c040a354>] ? native_sched_clock+0xb5/0xd1
Feb 24 17:53:21 cirithungol kernel:  [<c05bcdd9>] sys_socketcall+0x16b/0x186
Feb 24 17:53:21 cirithungol kernel:  [<c0405d3e>] syscall_call+0x7/0xb
Feb 24 17:53:21 cirithungol kernel:  =======================

-- 
http://www.codemonkey.org.uk
