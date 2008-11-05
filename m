From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: next-20081103 - possible circular locking dependency detected
	while bring up eth1
Date: Wed, 5 Nov 2008 12:43:06 +0530
Message-ID: <20081105071306.GB10881@linux.vnet.ibm.com>
References: <20081103183214.aac32543.sfr@canb.auug.org.au>
Reply-To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, mel@csn.ul.ie, peterz@infradead.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from E23SMTP02.au.ibm.com ([202.81.18.163]:59734 "EHLO
	e23smtp02.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbYKEHNP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 02:13:15 -0500
Content-Disposition: inline
In-Reply-To: <20081103183214.aac32543.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While booting with the next-20081103 kernel on x86 box, circular locking
dependency is detected.

Bringing up interface eth1:  [   31.988230] 
[   31.988234] =======================================================
[   31.989072] [ INFO: possible circular locking dependency detected ]
[   31.989072] 2.6.28-rc3-next-20081103-autotest #1
[   31.989072] -------------------------------------------------------
[   31.989072] events/3/18 is trying to acquire lock:
[   32.074777] ADDRCONF(NETDEV_UP): eth1: link is not ready
[   31.989072]  (rtnl_mutex){--..}, at: [<c05e8ef5>] rtnl_lock+0xf/0x11
[   31.989072] 
[   31.989072] but task is already holding lock:
[   31.989072]  ((linkwatch_work).work){--..}, at: [<c04367bf>] run_workqueue+0x80/0x189
[   31.989072] 
[   31.989072] which lock already depends on the new lock.
[   31.989072] 
[   31.989072] 
[   31.989072] the existing dependency chain (in reverse order) is:
[   31.989072] 
[   31.989072] -> #4 ((linkwatch_work).work){--..}:
[   31.989072]        [<c0445edb>] validate_chain+0x86e/0xb35
[   31.989072]        [<c0446822>] __lock_acquire+0x680/0x70e
[   31.989072]        [<c044690d>] lock_acquire+0x5d/0x7a
[   31.989072]        [<c04367f8>] run_workqueue+0xb9/0x189
[   31.989072]        [<c04371f3>] worker_thread+0xb4/0xbf
[   31.989072]        [<c04396a6>] kthread+0x3b/0x61
[   31.989072]        [<c040481b>] kernel_thread_helper+0x7/0x10
[   31.989072]        [<ffffffff>] 0xffffffff
[   31.989072] 
[   31.989072] -> #3 (events){--..}:
[   31.989072]        [<c0445edb>] validate_chain+0x86e/0xb35
[   31.989072]        [<c0446822>] __lock_acquire+0x680/0x70e
[   31.989072]        [<c044690d>] lock_acquire+0x5d/0x7a
[   31.989072]        [<c0436e21>] flush_work+0x45/0xb6
[   31.989072]        [<c043729a>] schedule_on_each_cpu+0x9c/0xca
[   31.989072]        [<c0466c97>] lru_add_drain_all+0xd/0xf
[   31.989072]        [<c046f1b6>] __mlock_vma_pages_range+0x96/0x1e5
[   31.989072]        [<c046f43a>] mlock_fixup+0x135/0x199
[   31.989072]        [<c046f50b>] do_mlockall+0x6d/0x82
[   31.989072]        [<c046f839>] sys_mlockall+0x7b/0x9e
[   31.989072]        [<c040398d>] sysenter_do_call+0x12/0x31
[   31.989072]        [<ffffffff>] 0xffffffff
[   31.989072] 
[   31.989072] -> #2 (&mm->mmap_sem){----}:
[   31.989072]        [<c0445edb>] validate_chain+0x86e/0xb35
[   31.989072]        [<c0446822>] __lock_acquire+0x680/0x70e
[   31.989072]        [<c044690d>] lock_acquire+0x5d/0x7a
[   31.989072]        [<c046e570>] might_fault+0x53/0x73
[   31.989072]        [<c0508bf5>] copy_to_user+0x28/0x3f
[   31.989072]        [<c048cd11>] filldir+0x88/0xc8
[   31.989072]        [<c04bee82>] sysfs_readdir+0x11d/0x156
[   31.989072]        [<c048cdb9>] vfs_readdir+0x68/0x94
[   31.989072]        [<c048d00b>] sys_getdents+0x5f/0xa0
[   31.989072]        [<c0403a66>] syscall_call+0x7/0xb
[   31.989072]        [<ffffffff>] 0xffffffff
[   31.989072] 
[   31.989072] -> #1 (sysfs_mutex){--..}:
[   31.989072]        [<c0445edb>] validate_chain+0x86e/0xb35
[   31.989072]        [<c0446822>] __lock_acquire+0x680/0x70e
[   31.989072]        [<c044690d>] lock_acquire+0x5d/0x7a
[   31.989072]        [<c0651c04>] mutex_lock_nested+0xdf/0x251
[   31.989072]        [<c04bf039>] sysfs_addrm_start+0x23/0x90
[   31.989072]        [<c04bf4af>] create_dir+0x3a/0x72
[   31.989072]        [<c04bf514>] sysfs_create_dir+0x2d/0x41
[   31.989072]        [<c0503e05>] kobject_add_internal+0xe5/0x189
[   31.989072]        [<c0503f54>] kobject_add_varg+0x35/0x41
[   31.989072]        [<c05042f7>] kobject_add+0x49/0x4f
[   31.989072]        [<c05777e1>] device_add+0x76/0x4c8
[   31.989072]        [<c05eb70e>] netdev_register_kobject+0x64/0x69
[   31.989072]        [<c05e1581>] register_netdevice+0x1fe/0x274
[   31.989072]        [<c05e1629>] register_netdev+0x32/0x3f
[   31.989072]        [<c07fa965>] loopback_net_init+0x2e/0x5d
[   31.989072]        [<c05de93b>] register_pernet_operations+0x13/0x15
[   31.989072]        [<c05de9a4>] register_pernet_device+0x1f/0x4c
[   31.989072]        [<c07fa935>] loopback_init+0xd/0xf
[   31.989072]        [<c0401130>] _stext+0x48/0x10d
[   31.989072]        [<c07db530>] kernel_init+0xf1/0x142
[   31.989072]        [<c040481b>] kernel_thread_helper+0x7/0x10
[   31.989072]        [<ffffffff>] 0xffffffff
[   31.989072] 
[   31.989072] -> #0 (rtnl_mutex){--..}:
[   31.989072]        [<c0445c10>] validate_chain+0x5a3/0xb35
[   31.989072]        [<c0446822>] __lock_acquire+0x680/0x70e
[   31.989072]        [<c044690d>] lock_acquire+0x5d/0x7a
[   31.989072]        [<c0651c04>] mutex_lock_nested+0xdf/0x251
[   31.989072]        [<c05e8ef5>] rtnl_lock+0xf/0x11
[   31.989072]        [<c05ea07a>] linkwatch_event+0x8/0x27
[   31.989072]        [<c04367fd>] run_workqueue+0xbe/0x189
[   31.989072]        [<c04371f3>] worker_thread+0xb4/0xbf
[   31.989072]        [<c04396a6>] kthread+0x3b/0x61
[   31.989072]        [<c040481b>] kernel_thread_helper+0x7/0x10
[   31.989072]        [<ffffffff>] 0xffffffff
[   31.989072] 
[   31.989072] other info that might help us debug this:
[   31.989072] 
[   31.989072] 2 locks held by events/3/18:
[   31.989072]  #0:  (events){--..}, at: [<c04367bf>] run_workqueue+0x80/0x189
[   31.989072]  #1:  ((linkwatch_work).work){--..}, at: [<c04367bf>] run_workqueue+0x80/0x189
[   31.989072] 
[   31.989072] stack backtrace:
[   31.989072] Pid: 18, comm: events/3 Not tainted 2.6.28-rc3-next-20081103-autotest #1
[   31.989072] Call Trace:
[   31.989072]  [<c0445662>] print_circular_bug_tail+0xa4/0xaf
[   31.989072]  [<c0445c10>] validate_chain+0x5a3/0xb35
[   31.989072]  [<c0446822>] __lock_acquire+0x680/0x70e
[   31.989072]  [<c04367bf>] ? run_workqueue+0x80/0x189
[   31.989072]  [<c044690d>] lock_acquire+0x5d/0x7a
[   31.989072]  [<c05e8ef5>] ? rtnl_lock+0xf/0x11
[   31.989072]  [<c0651c04>] mutex_lock_nested+0xdf/0x251
[   31.989072]  [<c05e8ef5>] ? rtnl_lock+0xf/0x11
[   31.989072]  [<c05e8ef5>] ? rtnl_lock+0xf/0x11
[   31.989072]  [<c05e8ef5>] rtnl_lock+0xf/0x11
[   31.989072]  [<c05ea07a>] linkwatch_event+0x8/0x27
[   31.989072]  [<c04367fd>] run_workqueue+0xbe/0x189
[   31.989072]  [<c04367bf>] ? run_workqueue+0x80/0x189
[   31.989072]  [<c05ea072>] ? linkwatch_event+0x0/0x27
[   31.989072]  [<c043713f>] ? worker_thread+0x0/0xbf
[   31.989072]  [<c04371f3>] worker_thread+0xb4/0xbf
[   31.989072]  [<c0439765>] ? autoremove_wake_function+0x0/0x33
[   31.989072]  [<c04396a6>] kthread+0x3b/0x61
[   33.690691] tg3: eth1: Link is up at 100 Mbps, full duplex.
[   33.690696] tg3: eth1: Flow control is off for TX and off for RX.
[   31.989072]  [<c043966b>] ? kthread+0x0/0x61
[   31.989072]  [<c040481b>] kernel_thread_helper+0x7/0x10
[   33.762336] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[  OK  ]

0xc05e8ef5 is in rtnl_lock (net/core/rtnetlink.c:67).
62	static DEFINE_MUTEX(rtnl_mutex);
63	
64	void rtnl_lock(void)
65	{
66		mutex_lock(&rtnl_mutex);
67	}
68	
69	void __rtnl_unlock(void)
70	{
71		mutex_unlock(&rtnl_mutex);
-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.
