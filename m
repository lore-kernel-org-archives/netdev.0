From: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
Subject: INFO: possible circular locking detected [when unloading the bonding
 driver]
Date: Sun, 13 Sep 2009 13:26:22 +0100
Message-ID: <4AACE4EE.4080707@tuffmail.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:44349 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753305AbZIMM0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Sep 2009 08:26:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I found this warning after loading and unloading all the modules I had
available.  I can reproduce it by hibernating the system, then loading
and unloading the bonding module. 

Regards
Alan

[  123.484225] Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)
[  123.484229] bonding: Warning: either miimon or arp_interval and
arp_ip_target module parameters must be specified, otherwise bonding
will not detect link failures! see bonding.txt for details.
[  125.790929]
[  125.790931] =======================================================
[  125.790936] [ INFO: possible circular locking dependency detected ]
[  125.790940] 2.6.31-rc8debug #50
[  125.790942] -------------------------------------------------------
[  125.790946] modprobe/8372 is trying to acquire lock:
[  125.790948]  (cpu_add_remove_lock){+.+.+.}, at: [<ffffffff81048ef2>]
cpu_maps_update_begin+0x12/0x20
[  125.790961]
[  125.790962] but task is already holding lock:
[  125.790965]  (rtnl_mutex){+.+.+.}, at: [<ffffffff812d0aa2>]
rtnl_lock+0x12/0x20
[  125.790974]
[  125.790975] which lock already depends on the new lock.
[  125.790976]
[  125.790978]
[  125.790979] the existing dependency chain (in reverse order) is:
[  125.790982]
[  125.790983] -> #3 (rtnl_mutex){+.+.+.}:
[  125.790989]        [<ffffffff810741d9>] validate_chain+0xb99/0x11d0
[  125.790996]        [<ffffffff81074b6e>] __lock_acquire+0x35e/0xa30
[  125.791001]        [<ffffffff810752d7>] lock_acquire+0x97/0x110
[  125.791006]        [<ffffffff8134f046>] mutex_lock_nested+0x56/0x310
[  125.791012]        [<ffffffff812d0aa2>] rtnl_lock+0x12/0x20
[  125.791016]        [<ffffffff812d2079>] linkwatch_event+0x9/0x40
[  125.791021]        [<ffffffff8105cafa>] worker_thread+0x23a/0x350
[  125.791027]        [<ffffffff81060f56>] kthread+0xa6/0xb0
[  125.791032]        [<ffffffff8100ce5a>] child_rip+0xa/0x20
[  125.791037]        [<ffffffffffffffff>] 0xffffffffffffffff
[  125.791051]
[  125.791052] -> #2 ((linkwatch_work).work){+.+.+.}:
[  125.791058]        [<ffffffff810741d9>] validate_chain+0xb99/0x11d0
[  125.791063]        [<ffffffff81074b6e>] __lock_acquire+0x35e/0xa30
[  125.791068]        [<ffffffff810752d7>] lock_acquire+0x97/0x110
[  125.791073]        [<ffffffff8105caf4>] worker_thread+0x234/0x350
[  125.791077]        [<ffffffff81060f56>] kthread+0xa6/0xb0
[  125.791082]        [<ffffffff8100ce5a>] child_rip+0xa/0x20
[  125.791087]        [<ffffffffffffffff>] 0xffffffffffffffff
[  125.791092]
[  125.791093] -> #1 (events){+.+.+.}:
[  125.791098]        [<ffffffff810741d9>] validate_chain+0xb99/0x11d0
[  125.791104]        [<ffffffff81074b6e>] __lock_acquire+0x35e/0xa30
[  125.791108]        [<ffffffff810752d7>] lock_acquire+0x97/0x110
[  125.791114]        [<ffffffff8105b758>]
cleanup_workqueue_thread+0x48/0xd0
[  125.791119]        [<ffffffff8133dffa>] workqueue_cpu_callback+0x9a/0x130
[  125.791125]        [<ffffffff81353dce>] notifier_call_chain+0x5e/0xa0
[  125.791130]        [<ffffffff81065549>]
__raw_notifier_call_chain+0x9/0x10
[  125.791136]        [<ffffffff81065561>] raw_notifier_call_chain+0x11/0x20
[  125.791141]        [<ffffffff8133c213>] _cpu_down+0x173/0x2b0
[  125.791145]        [<ffffffff81049148>] disable_nonboot_cpus+0x98/0x130
[  125.791150]        [<ffffffff81081f97>] hibernation_snapshot+0x187/0x250
[  125.791156]        [<ffffffff81082178>] hibernate+0x118/0x1c0
[  125.791160]        [<ffffffff81080863>] state_store+0xd3/0xf0
[  125.791165]        [<ffffffff81199fe7>] kobj_attr_store+0x17/0x20
[  125.791172]        [<ffffffff8113e7b4>] sysfs_write_file+0xf4/0x150
[  125.791178]        [<ffffffff810e3557>] vfs_write+0xc7/0x1a0
[  125.791184]        [<ffffffff810e3ba0>] sys_write+0x50/0x90
[  125.791189]        [<ffffffff8100bdab>] system_call_fastpath+0x16/0x1b
[  125.791194]        [<ffffffffffffffff>] 0xffffffffffffffff
[  125.791205]
[  125.791205] -> #0 (cpu_add_remove_lock){+.+.+.}:
[  125.791211]        [<ffffffff81073c0d>] validate_chain+0x5cd/0x11d0
[  125.791216]        [<ffffffff81074b6e>] __lock_acquire+0x35e/0xa30
[  125.791221]        [<ffffffff810752d7>] lock_acquire+0x97/0x110
[  125.791225]        [<ffffffff8134f046>] mutex_lock_nested+0x56/0x310
[  125.791230]        [<ffffffff81048ef2>] cpu_maps_update_begin+0x12/0x20
[  125.791235]        [<ffffffff8105b842>] destroy_workqueue+0x22/0xc0
[  125.791240]        [<ffffffffa03afdfa>] bond_uninit+0x3a/0x70 [bonding]
[  125.791252]        [<ffffffff812c5e8d>] rollback_registered+0xbd/0x120
[  125.791258]        [<ffffffff812c5f0d>] unregister_netdevice+0x1d/0x70
[  125.791262]        [<ffffffffa03ad71f>] bond_free_all+0x4f/0xa0 [bonding]
[  125.791273]        [<ffffffffa03ba075>] bonding_exit+0x35/0x3c [bonding]
[  125.791283]        [<ffffffff8107ddc6>] sys_delete_module+0x176/0x230
[  125.791288]        [<ffffffff8100bdab>] system_call_fastpath+0x16/0x1b
[  125.791293]        [<ffffffffffffffff>] 0xffffffffffffffff
[  125.791298]
[  125.791299] other info that might help us debug this:
[  125.791300]
[  125.791304] 1 lock held by modprobe/8372:
[  125.791306]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff812d0aa2>]
rtnl_lock+0x12/0x20
[  125.791314]
[  125.791315] stack backtrace:
[  125.791319] Pid: 8372, comm: modprobe Not tainted 2.6.31-rc8debug #50
[  125.791322] Call Trace:
[  125.791328]  [<ffffffff81073494>] print_circular_bug_tail+0x94/0xe0
[  125.791333]  [<ffffffff81073c0d>] validate_chain+0x5cd/0x11d0
[  125.791338]  [<ffffffff81074b6e>] __lock_acquire+0x35e/0xa30
[  125.791343]  [<ffffffff810752d7>] lock_acquire+0x97/0x110
[  125.791349]  [<ffffffff81048ef2>] ? cpu_maps_update_begin+0x12/0x20
[  125.791354]  [<ffffffff8134f046>] mutex_lock_nested+0x56/0x310
[  125.791358]  [<ffffffff81048ef2>] ? cpu_maps_update_begin+0x12/0x20
[  125.791363]  [<ffffffff8113f974>] ? release_sysfs_dirent+0x54/0xc0
[  125.791368]  [<ffffffff81048ef2>] cpu_maps_update_begin+0x12/0x20
[  125.791373]  [<ffffffff8105b842>] destroy_workqueue+0x22/0xc0
[  125.791383]  [<ffffffffa03afdfa>] bond_uninit+0x3a/0x70 [bonding]
[  125.791388]  [<ffffffff812c5e8d>] rollback_registered+0xbd/0x120
[  125.791397]  [<ffffffffa03abfb6>] ? bond_work_cancel_all+0x16/0x130
[bonding]
[  125.791402]  [<ffffffff812c5f0d>] unregister_netdevice+0x1d/0x70
[  125.791411]  [<ffffffffa03ad71f>] bond_free_all+0x4f/0xa0 [bonding]
[  125.791421]  [<ffffffffa03ba075>] bonding_exit+0x35/0x3c [bonding]
[  125.791425]  [<ffffffff8107ddc6>] sys_delete_module+0x176/0x230
[  125.791430]  [<ffffffff8107186d>] ? trace_hardirqs_on_caller+0x14d/0x1a0
[  125.791435]  [<ffffffff81350a04>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  125.791441]  [<ffffffff8100bdab>] system_call_fastpath+0x16/0x1b

