From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [Bug 42754] New: BUG: sleeping function called from invalid
 context at mm/memory.c:3924
Date: Sun, 12 Feb 2012 09:50:04 -0800
Message-ID: <20120212175004.GM3737@linux.vnet.ibm.com>
References: <bug-42754-27@https.bugzilla.kernel.org/>
 <20120209191317.2fbad57b.akpm@linux-foundation.org>
 <20120210122657.GA9347@smp.if.uj.edu.pl>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>, rostedt@goodmis.org
To: Witold Baryluk <baryluk@smp.if.uj.edu.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:33453 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754677Ab2BLRuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2012 12:50:12 -0500
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Sun, 12 Feb 2012 10:50:11 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 91750C40001
	for <netdev@vger.kernel.org>; Sun, 12 Feb 2012 10:50:08 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1CHo8KS125908
	for <netdev@vger.kernel.org>; Sun, 12 Feb 2012 10:50:08 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1CHo6uX012617
	for <netdev@vger.kernel.org>; Sun, 12 Feb 2012 10:50:08 -0700
Content-Disposition: inline
In-Reply-To: <20120210122657.GA9347@smp.if.uj.edu.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 10, 2012 at 01:26:57PM +0100, Witold Baryluk wrote:
> On 02-09 19:13, Andrew Morton wrote:
> > 
> > (switched to email.  Please respond via emailed reply-to-all, not via the
> > bugzilla web interface).
> > 
> > (It's 3.3-rc2)
> > 
> > On Fri, 10 Feb 2012 02:24:10 GMT bugzilla-daemon@bugzilla.kernel.org wrote:
> > 
> > > https://bugzilla.kernel.org/show_bug.cgi?id=42754
> > > 
> > >            Summary: BUG: sleeping function called from invalid context at
> > >                     mm/memory.c:3924
> > >            Product: Memory Management
> > >            Version: 2.5
> > >     Kernel Version: 3.3.0-rc2+
> > >           Platform: All
> > >         OS/Version: Linux
> > >               Tree: Mainline
> > >             Status: NEW
> > >           Severity: high
> > >           Priority: P1
> > >          Component: Other
> > >         AssignedTo: akpm@linux-foundation.org
> > >         ReportedBy: baryluk@smp.if.uj.edu.pl
> > >         Regression: Yes
> > > 
> > > 
> > > Created an attachment (id=72350)
> > >  --> (https://bugzilla.kernel.org/attachment.cgi?id=72350)
> > > Konfig file
> > > 
> > > [    0.000000] Linux version 3.3.0-rc2-t43-devel-smp-00172-g23783f8
> > > (baryluk@sredniczarny) (gcc version 4.6.2 (Debian 4.6.2-12) ) #13 SMP Sun Feb 5
> > > 15:37:06 CET 2012
> > > 
> > > 
> > > [ 1203.050623] BUG: sleeping function called from invalid context at
> > > mm/memory.c:3924
> > > [ 1203.054259] in_atomic(): 1, irqs_disabled(): 0, pid: 4446, name:
> > > NetworkManager
> > > [ 1203.057932] INFO: lockdep is turned off.
> > > [ 1203.061685] Pid: 4446, comm: NetworkManager Tainted: G        W  O
> > > 3.3.0-rc2-t43-devel-smp-00172-g23783f8 #13
> > > [ 1203.065606] Call Trace:
> > > [ 1203.069502]  [<c107e182>] __might_sleep+0x122/0x1d0
> > > [ 1203.073506]  [<c1140b4e>] might_fault+0x2e/0xb0
> > > [ 1203.077501]  [<c131c67b>] copy_to_user+0x3b/0x60
> > > [ 1203.081561]  [<c158a102>] put_cmsg+0x52/0xd0
> > > [ 1203.085624]  [<c15bc7d7>] netlink_recvmsg+0x287/0x340
> > > [ 1203.089740]  [<c1579b43>] sock_recvmsg+0xd3/0x110
> > > [ 1203.093902]  [<c1140b74>] ? might_fault+0x54/0xb0
> > > [ 1203.098093]  [<c158834c>] ? verify_iovec+0x4c/0xc0
> > > [ 1203.102336]  [<c1579a70>] ? sock_sendmsg_nosec+0x100/0x100
> > > [ 1203.106611]  [<c157a994>] __sys_recvmsg+0x114/0x1e0
> > > [ 1203.110942]  [<c1081dc7>] ? finish_task_switch+0x77/0x200
> > > [ 1203.115315]  [<c11784b5>] ? fget_light+0xc5/0x410
> > > [ 1203.119722]  [<c1081dc7>] ? finish_task_switch+0x77/0x200
> > > [ 1203.124167]  [<c11784c9>] ? fget_light+0xd9/0x410
> > > [ 1203.128618]  [<c1178435>] ? fget_light+0x45/0x410
> > > [ 1203.133102]  [<c157c659>] sys_recvmsg+0x39/0x60
> > > [ 1203.137590]  [<c157cbb3>] sys_socketcall+0x2e3/0x330
> > > [ 1203.142147]  [<c17cf58d>] ? sysenter_exit+0xf/0x1a
> > > [ 1203.146707]  [<c131be78>] ? trace_hardirqs_on_thunk+0xc/0x10
> > > [ 1203.151358]  [<c17cf558>] sysenter_do_call+0x12/0x38
> > > [ 1203.155980] BUG: scheduling while atomic: NetworkManager/4446/0x10000002
> > > [ 1203.160714] INFO: lockdep is turned off.
> > > [ 1203.165429] Modules linked in: vfat fat pci_stub vboxpci(O) vboxnetadp(O)
> > > vboxnetflt(O) vboxdrv(O) pktcdvd ebtable_nat ebtables acpi_cpufreq mperf
> > > xt_CHECKSUM irtty_sir sir_dev irda crc_ccitt dummy ppdev lp bnep rfcomm
> > > bluetooth lib80211_crypt_ccmp uinput nfsd pcmcia yenta_socket i2c_i801 radeon
> > > ipw2200 libipw pcmcia_rsrc pcmcia_core ttm drm_kms_helper parport_pc parport
> > > cfbfillrect cfbcopyarea cfbimgblt raid10 raid456 async_memcpy async_pq
> > > async_xor xor async_raid6_recov async_tx raid6_pq sr_mod cdrom floppy [last
> > > unloaded: scsi_wait_scan]
> > 
> > 
> > OK, so we have a pile of in_atomic warnings.  I assume the above was
> > the first to come out?  The third and following traces have a different
> > trace.
> > 
> > It might be a bug in the netlink code or thereabouts.  Or it might be that
> > some random unrelated piece of kernel code forgot to release a lock and
> > netlink was the first place where this was detected.
> > 
> > Peter, is there any way in which lockdep can help us find the culprit
> > in the second case?
> > 
> > Thanks.
> 
> 
> Well, there is few problems before this message, they are already reported:
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=42742  (cpu_idle warning)
> https://bugzilla.kernel.org/show_bug.cgi?id=42741  (sirdev DEADLOCK - second one is DEADLOCK warning, and it actually triggers real deadlock, but not on this boot)
> 
> but they are somehow unreleated.
> 
> Immiedietly before BUG I have
> [  592.952374] PM: Adding info for No Bus:0:52
> 
> so pretty nothing for long time. System wasn't really loaded or anything,
> it just happened. There was not suspend/resume cycles or anything.
> 
> This is IBM ThinkPad T43 (Pentium-M 32 bit), and it had fresh boot 20
> minutes before this happened.
> 
> Bellow dmesg are same as boot above
> 
> cpuidle looks like this:

If you had tracing enabled, Steven Rostedt's patchset at
https://lkml.org/lkml/2012/2/7/231 might help here.

							Thanx, Paul

> [   16.960579] Testing event cpu_idle: 
> [   16.961306] ------------[ cut here ]------------
> [   16.961316] WARNING: at include/linux/rcupdate.h:242 __atomic_notifier_call_chain+0xbc/0xf0()
> [   16.961319] Hardware name: 2669UYD
> [   16.961321] Modules linked in:
> [   16.961326] Pid: 0, comm: swapper/0 Not tainted 3.3.0-rc2-t43-devel-smp-00172-g23783f8 #13
> [   16.961329] Call Trace:
> [   16.961337]  [<c104a372>] warn_slowpath_common+0x72/0xa0
> [   16.961341]  [<c17cb41c>] ? __atomic_notifier_call_chain+0xbc/0xf0
> [   16.961346]  [<c17cb41c>] ? __atomic_notifier_call_chain+0xbc/0xf0
> [   16.961350]  [<c104a3c0>] warn_slowpath_null+0x20/0x30
> [   16.961355]  [<c17cb41c>] __atomic_notifier_call_chain+0xbc/0xf0
> [   16.961360]  [<c136056e>] ? vgacon_scroll+0x5e/0x60
> [   16.961365]  [<c17cb46f>] atomic_notifier_call_chain+0x1f/0x30
> [   16.961371]  [<c13cdf23>] notify_write+0x23/0x30
> [   16.961375]  [<c13cdf7f>] lf+0x4f/0x70
> [   16.961379]  [<c13cefb9>] vt_console_print+0x249/0x380
> [   16.961384]  [<c13ced70>] ? con_shutdown+0x40/0x40
> [   16.961389]  [<c104a4fd>] __call_console_drivers+0x7d/0xa0
> [   16.961393]  [<c104a6ec>] _call_console_drivers+0x4c/0x90
> [   16.961398]  [<c104a94d>] call_console_drivers+0xdd/0x110
> [   16.961402]  [<c104aa47>] console_unlock+0x77/0x170
> [   16.961407]  [<c104accb>] vprintk+0x18b/0x490
> [   16.961414]  [<c17b11a8>] printk+0x1d/0x1f
> [   16.961420]  [<c10af9e2>] lockdep_rcu_suspicious+0x22/0xe0
> [   16.961427]  [<c150db78>] cpuidle_idle_call+0x238/0x300
> [   16.961433]  [<c10158df>] cpu_idle+0x6f/0xc0
> [   16.961439]  [<c1795caa>] rest_init+0x11e/0x124
> [   16.961443]  [<c1795bf3>] ? rest_init+0x67/0x124
> [   16.961450]  [<c1b5a76e>] start_kernel+0x325/0x32b
> [   16.961454]  [<c1b5a25a>] ? obsolete_checksetup+0x95/0x95
> [   16.961459]  [<c1b5a11e>] ? reserve_ebda_region+0x6b/0x6d
> [   16.961463]  [<c1b5a0ac>] i386_start_kernel+0x9b/0xa2
> [   16.961466] ---[ end trace d284d408f7ee228c ]---
> [   16.961468] ------------[ cut here ]------------
> [   16.961472] WARNING: at include/linux/rcupdate.h:248 __atomic_notifier_call_chain+0xe0/0xf0()
> [   16.961475] Hardware name: 2669UYD
> [   16.961477] Modules linked in:
> [   16.961481] Pid: 0, comm: swapper/0 Tainted: G        W    3.3.0-rc2-t43-devel-smp-00172-g23783f8 #13
> [   16.961483] Call Trace:
> [   16.961488]  [<c104a372>] warn_slowpath_common+0x72/0xa0
> [   16.961492]  [<c17cb440>] ? __atomic_notifier_call_chain+0xe0/0xf0
> [   16.961496]  [<c17cb440>] ? __atomic_notifier_call_chain+0xe0/0xf0
> [   16.961501]  [<c104a3c0>] warn_slowpath_null+0x20/0x30
> [   16.961505]  [<c17cb440>] __atomic_notifier_call_chain+0xe0/0xf0
> [   16.961509]  [<c17cb387>] ? __atomic_notifier_call_chain+0x27/0xf0
> [   16.961514]  [<c17cb46f>] atomic_notifier_call_chain+0x1f/0x30
> [   16.961518]  [<c13cdf23>] notify_write+0x23/0x30
> [   16.961522]  [<c13cdf7f>] lf+0x4f/0x70
> [   16.961527]  [<c13cefb9>] vt_console_print+0x249/0x380
> [   16.961532]  [<c13ced70>] ? con_shutdown+0x40/0x40
> [   16.961536]  [<c104a4fd>] __call_console_drivers+0x7d/0xa0
> [   16.961540]  [<c104a6ec>] _call_console_drivers+0x4c/0x90
> [   16.961545]  [<c104a94d>] call_console_drivers+0xdd/0x110
> [   16.961549]  [<c104aa47>] console_unlock+0x77/0x170
> [   16.961554]  [<c104accb>] vprintk+0x18b/0x490
> [   16.961559]  [<c17b11a8>] printk+0x1d/0x1f
> [   16.961563]  [<c10af9e2>] lockdep_rcu_suspicious+0x22/0xe0
> [   16.961568]  [<c150db78>] cpuidle_idle_call+0x238/0x300
> [   16.961573]  [<c10158df>] cpu_idle+0x6f/0xc0
> [   16.961577]  [<c1795caa>] rest_init+0x11e/0x124
> [   16.961581]  [<c1795bf3>] ? rest_init+0x67/0x124
> [   16.961585]  [<c1b5a76e>] start_kernel+0x325/0x32b
> [   16.961590]  [<c1b5a25a>] ? obsolete_checksetup+0x95/0x95
> [   16.961594]  [<c1b5a11e>] ? reserve_ebda_region+0x6b/0x6d
> [   16.961599]  [<c1b5a0ac>] i386_start_kernel+0x9b/0xa2
> [   16.961601] ---[ end trace d284d408f7ee228d ]---
> [   16.965103] ===============================
> [   16.965156] [ INFO: suspicious RCU usage. ]
> [   16.965209] 3.3.0-rc2-t43-devel-smp-00172-g23783f8 #13 Tainted: G        W   
> [   16.965268] -------------------------------
> [   16.965321] include/trace/events/power.h:35 suspicious rcu_dereference_check() usage!
> [   16.965409] 
> [   16.965410] other info that might help us debug this:
> [   16.965411] 
> [   16.965556] 
> [   16.965556] rcu_scheduler_active = 1, debug_locks = 1
> [   16.965656] RCU used illegally from extended quiescent state!
> [   16.965711] no locks held by swapper/0/0.
> [   16.965764] 
> [   16.965764] stack backtrace:
> [   16.965861] Pid: 0, comm: swapper/0 Tainted: G        W    3.3.0-rc2-t43-devel-smp-00172-g23783f8 #13
> [   16.965951] Call Trace:
> [   16.966003]  [<c17b11a8>] ? printk+0x1d/0x1f
> [   16.966059]  [<c10afa78>] lockdep_rcu_suspicious+0xb8/0xe0
> [   16.966118]  [<c150db78>] cpuidle_idle_call+0x238/0x300
> [   16.966175]  [<c10158df>] cpu_idle+0x6f/0xc0
> [   16.966231]  [<c1795caa>] rest_init+0x11e/0x124
> [   16.966287]  [<c1795bf3>] ? rest_init+0x67/0x124
> [   16.966344]  [<c1b5a76e>] start_kernel+0x325/0x32b
> [   16.966400]  [<c1b5a25a>] ? obsolete_checksetup+0x95/0x95
> [   16.966458]  [<c1b5a11e>] ? reserve_ebda_region+0x6b/0x6d
> [   16.966516]  [<c1b5a0ac>] i386_start_kernel+0x9b/0xa2
> [   16.980655] OK
> [   16.980705] Testing event cpu_frequency: OK
> 
> 
> 
> And sirdev problem looks like this:
> 
> 
> [  177.805346] irda_init()
> [  177.805617] NET: Registered protocol family 23
> [  177.853523] warning: `hipd' uses 32-bit capabilities (legacy support in use)
> [  178.014559] sirdev_get_instance - ttyS1
> [  178.014689] device: 'irda0': device_add
> [  178.014943] PM: Adding info for No Bus:irda0
> [  178.060888] irtty_open - ttyS1: irda line discipline opened
> [  178.412690] alg: No test for authenc(hmac(sha1),cbc(aes)) (authenc(hmac(sha1-generic),cbc(aes-asm)))
> [  179.070690] irlap_change_speed(), setting speed to 9600
> [  182.070664] 
> [  182.073284] ======================================================
> [  182.075969] [ INFO: possible circular locking dependency detected ]
> [  182.078702] 3.3.0-rc2-t43-devel-smp-00172-g23783f8 #13 Tainted: G        W   
> [  182.080017] -------------------------------------------------------
> [  182.080017] irq/3-serial/5887 is trying to acquire lock:
> [  182.080017]  (&(&dev->tx_lock)->rlock){..-...}, at: [<f869a883>] sirdev_write_complete+0x23/0x280 [sir_dev]
> [  182.080017] 
> [  182.080017] but task is already holding lock:
> [  182.080017]  (&port_lock_key){..-...}, at: [<c13dc0f7>] serial8250_handle_irq+0x37/0xa0
> [  182.080017] 
> [  182.080017] which lock already depends on the new lock.
> [  182.080017] 
> [  182.080017] 
> [  182.080017] the existing dependency chain (in reverse order) is:
> [  182.080017] 
> [  182.080017] -> #1 (&port_lock_key){..-...}:
> [  182.080017]        [<c10b0f1b>] check_prevs_add+0xcb/0x120
> [  182.080017]        [<c10b14c7>] validate_chain.isra.34+0x557/0x6d0
> [  182.080017]        [<c10b3945>] __lock_acquire+0x355/0x820
> [  182.080017]        [<c10b4467>] lock_acquire+0x87/0x1b0
> [  182.080017]        [<c17c762e>] _raw_spin_lock_irqsave+0x5e/0xa0
> [  182.080017]        [<c13d5f32>] uart_write_room+0x22/0x60
> [  182.080017]        [<c13c1c19>] tty_write_room+0x19/0x20
> [  182.080017]        [<f876b512>] irtty_do_write+0x42/0xa0 [irtty_sir]
> [  182.080017]        [<f869a455>] sirdev_hard_xmit+0xc5/0x280 [sir_dev]
> [  182.080017]        [<c159586f>] dev_hard_start_xmit+0x22f/0x690
> [  182.080017]        [<c15ba331>] sch_direct_xmit+0xa1/0x220
> [  182.080017]        [<c1595e45>] dev_queue_xmit+0x175/0x770
> [  182.080017]        [<f878e62a>] irlap_queue_xmit+0x9a/0xe0 [irda]
> [  182.080017]        [<f878ebeb>] irlap_send_discovery_xid_frame+0xdb/0x360 [irda]
> [  182.080017]        [<f878ca68>] irlap_state_ndm+0x308/0x4e0 [irda]
> [  182.080017]        [<f878cd7b>] irlap_do_event+0x4b/0xb0 [irda]
> [  182.080017]        [<f878964a>] irlap_discovery_request+0xda/0x230 [irda]
> [  182.080017]        [<f8786168>] irlmp_state_standby+0x78/0x170 [irda]
> [  182.080017]        [<f8786b59>] irlmp_do_lap_event+0x39/0xe0 [irda]
> [  182.080017]        [<f878546c>] irlmp_do_discovery+0xac/0x140 [irda]
> [  182.080017]        [<f8787603>] irlmp_discovery_timer_expired+0x23/0x60 [irda]
> [  182.080017]        [<c105abad>] call_timer_fn+0x6d/0x2e0
> [  182.080017]        [<c105af0a>] run_timer_softirq+0xea/0x260
> [  182.080017]        [<c10524cf>] __do_softirq+0x9f/0x360
> [  182.080017]        [<c1052887>] run_ksoftirqd+0xf7/0x1b0
> [  182.080017]        [<c10721f2>] kthread+0x72/0x80
> [  182.080017]        [<c17cfafa>] kernel_thread_helper+0x6/0x10
> [  182.080017] 
> [  182.080017] -> #0 (&(&dev->tx_lock)->rlock){..-...}:
> [  182.080017]        [<c10b0e45>] check_prev_add+0x605/0x610
> [  182.080017]        [<c10b0f1b>] check_prevs_add+0xcb/0x120
> [  182.080017]        [<c10b14c7>] validate_chain.isra.34+0x557/0x6d0
> [  182.080017]        [<c10b3945>] __lock_acquire+0x355/0x820
> [  182.080017]        [<c10b4467>] lock_acquire+0x87/0x1b0
> [  182.080017]        [<c17c762e>] _raw_spin_lock_irqsave+0x5e/0xa0
> [  182.080017]        [<f869a883>] sirdev_write_complete+0x23/0x280 [sir_dev]
> [  182.080017]        [<f876b671>] irtty_write_wakeup+0x31/0x90 [irtty_sir]
> [  182.080017]        [<c13ba332>] tty_wakeup+0x62/0x70
> [  182.080017]        [<c13d7686>] uart_write_wakeup+0x16/0x20
> [  182.080017]        [<c13daffe>] serial8250_tx_chars+0x8e/0x110
> [  182.080017]        [<c13dc157>] serial8250_handle_irq+0x97/0xa0
> [  182.080017]        [<c13dc17c>] serial8250_default_handle_irq+0x1c/0x20
> [  182.080017]        [<c13da1e5>] serial8250_interrupt+0x65/0xd0
> [  182.080017]        [<c10dfa26>] irq_forced_thread_fn+0x26/0x50
> [  182.080017]        [<c10df932>] irq_thread+0x152/0x1e0
> [  182.080017]        [<c10721f2>] kthread+0x72/0x80
> [  182.080017]        [<c17cfafa>] kernel_thread_helper+0x6/0x10
> [  182.080017] 
> [  182.080017] other info that might help us debug this:
> [  182.080017] 
> [  182.080017]  Possible unsafe locking scenario:
> [  182.080017] 
> [  182.080017]        CPU0                    CPU1
> [  182.080017]        ----                    ----
> [  182.080017]   lock(&port_lock_key);
> [  182.080017]                                lock(&(&dev->tx_lock)->rlock);
> [  182.080017]                                lock(&port_lock_key);
> [  182.080017]   lock(&(&dev->tx_lock)->rlock);
> [  182.080017] 
> [  182.080017]  *** DEADLOCK ***
> [  182.080017] 
> [  182.080017] 2 locks held by irq/3-serial/5887:
> [  182.080017]  #0:  (&(&i->lock)->rlock){+.....}, at: [<c13da1a3>] serial8250_interrupt+0x23/0xd0
> [  182.080017]  #1:  (&port_lock_key){..-...}, at: [<c13dc0f7>] serial8250_handle_irq+0x37/0xa0
> [  182.080017] 
> [  182.080017] stack backtrace:
> [  182.080017] Pid: 5887, comm: irq/3-serial Tainted: G        W    3.3.0-rc2-t43-devel-smp-00172-g23783f8 #13
> [  182.080017] Call Trace:
> [  182.080017]  [<c17b11a8>] ? printk+0x1d/0x1f
> [  182.080017]  [<c17b2506>] print_circular_bug+0xa7/0xb1
> [  182.080017]  [<c10b0e45>] check_prev_add+0x605/0x610
> [  182.080017]  [<c10b0f1b>] check_prevs_add+0xcb/0x120
> [  182.080017]  [<c10b14c7>] validate_chain.isra.34+0x557/0x6d0
> [  182.080017]  [<c10b3945>] __lock_acquire+0x355/0x820
> [  182.080017]  [<c10b4467>] lock_acquire+0x87/0x1b0
> [  182.080017]  [<f869a883>] ? sirdev_write_complete+0x23/0x280 [sir_dev]
> [  182.080017]  [<c17c75f9>] ? _raw_spin_lock_irqsave+0x29/0xa0
> [  182.080017]  [<c17c762e>] _raw_spin_lock_irqsave+0x5e/0xa0
> [  182.080017]  [<f869a883>] ? sirdev_write_complete+0x23/0x280 [sir_dev]
> [  182.080017]  [<f869a883>] sirdev_write_complete+0x23/0x280 [sir_dev]
> [  182.080017]  [<c10aea1b>] ? trace_hardirqs_off+0xb/0x10
> [  182.080017]  [<f876b671>] irtty_write_wakeup+0x31/0x90 [irtty_sir]
> [  182.080017]  [<c13c2991>] ? tty_ldisc_try+0x41/0x50
> [  182.080017]  [<c13c29ad>] ? tty_ldisc_ref+0xd/0x10
> [  182.080017]  [<c13ba332>] tty_wakeup+0x62/0x70
> [  182.080017]  [<c13d7686>] uart_write_wakeup+0x16/0x20
> [  182.080017]  [<c13daffe>] serial8250_tx_chars+0x8e/0x110
> [  182.080017]  [<c13dc157>] serial8250_handle_irq+0x97/0xa0
> [  182.080017]  [<c13dc17c>] serial8250_default_handle_irq+0x1c/0x20
> [  182.080017]  [<c13da1e5>] serial8250_interrupt+0x65/0xd0
> [  182.080017]  [<c108580b>] ? get_parent_ip+0xb/0x40
> [  182.080017]  [<c10dfa26>] irq_forced_thread_fn+0x26/0x50
> [  182.080017]  [<c10df932>] irq_thread+0x152/0x1e0
> [  182.080017]  [<c10dfa00>] ? irq_thread_fn+0x40/0x40
> [  182.080017]  [<c10df7e0>] ? irq_finalize_oneshot+0x20/0x20
> [  182.080017]  [<c10721f2>] kthread+0x72/0x80
> [  182.080017]  [<c1072180>] ? __init_kthread_worker+0x60/0x60
> [  182.080017]  [<c17cfafa>] kernel_thread_helper+0x6/0x10
> 
> 
> But I do not see how this locks can any problem.
> 
> I do not know why lockdep is disabled, because I configured kernel to
> keep telling my about lock dependency problems even after showing first
> one. AFAIK.
> 
> As of VirtualBox modules, they were not used for anything, just loaded.
> 
> Regards,
> Witek
> 
> 
> 
> 
> -- 
> Witold Baryluk
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
