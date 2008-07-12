From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: linux-next: Tree for July 11
Date: Sat, 12 Jul 2008 20:51:50 +0200
Message-ID: <200807122051.50909.rjw@sisk.pl>
References: <20080711182557.9b24df1f.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	netdev@vger.kernel.org, "Vegard Nossum" <vegard.nossum@gmail.com>,
	"Pekka Enberg" <penberg@cs.helsinki.fi>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755384AbYGLSto@vger.kernel.org>
In-Reply-To: <20080711182557.9b24df1f.sfr@canb.auug.org.au>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, 11 of July 2008, Stephen Rothwell wrote:
> Hi all,
> 
> Changes since next-20080710:
> 
> New tree: voltage
> 
> The tip-core tree lost its conflict against Linus' tree.
> 
> The sched tree gained a conflict against Linus' tree.
> 
> The x86 tree gained conflicts against the ftrace and driver-core trees.
> 
> The ide tree lost its 2 conflicts against Linus' tree.
> 
> The rr tree gained a runtime bug fix patch (which Rusty tells me will not
> be needed for long).
> 
> The firmware tree gained a conflict against the usb tree that required the
> reverting of one of its commits) but also lost a conflict against Linus'
> tree.
> 
> The kmemcheck tree gained a conflict against the x86 tree.
> 
> The ttydev tree had two patches fail to apply which I removed.
> 
> I have also applied the following patches for known problems:
> 
> 	sparc64: sysdev API change fallout
> 	s390: fix compile error due to smp_call_function
> 
> This patch is no longer needed:
> 	linux-next: zero based percpu build error on s390
> 
> ----------------------------------------------------------------------------

With this tree I see two problems.  The first one is this:

=============================================
[ INFO: possible recursive locking detected ]
2.6.26-rc9-next #44
---------------------------------------------
swapper/1 is trying to acquire lock:
 (&queue->lock){-...}, at: [<ffffffff80483067>] qdisc_lock_tree+0x27/0x30

but task is already holding lock:
 (&queue->lock){-...}, at: [<ffffffff8048305f>] qdisc_lock_tree+0x1f/0x30

other info that might help us debug this:
3 locks held by swapper/1:
 #0:  (net_mutex){--..}, at: [<ffffffff8046e482>] register_pernet_device+0x22/0x70
 #1:  (rtnl_mutex){--..}, at: [<ffffffff8047bac2>] rtnl_lock+0x12/0x20
 #2:  (&queue->lock){-...}, at: [<ffffffff8048305f>] qdisc_lock_tree+0x1f/0x30

stack backtrace:
Pid: 1, comm: swapper Not tainted 2.6.26-rc9-next #44

Call Trace:
 [<ffffffff80263a4e>] __lock_acquire+0xb7e/0x1280
 [<ffffffff802641a7>] lock_acquire+0x57/0x80
 [<ffffffff80483067>] ? qdisc_lock_tree+0x27/0x30
 [<ffffffff80500c65>] _spin_lock+0x25/0x40
 [<ffffffff80483067>] qdisc_lock_tree+0x27/0x30
 [<ffffffff804830b1>] dev_init_scheduler+0x11/0x70
 [<ffffffff8047193b>] register_netdevice+0x1fb/0x370
 [<ffffffff80471af4>] register_netdev+0x44/0x60
 [<ffffffff806f18f7>] loopback_net_init+0x47/0x90
 [<ffffffff806f12c0>] ? firmware_class_init+0x0/0x90
 [<ffffffff806f1890>] ? loopback_init+0x0/0x20
 [<ffffffff8046e3e8>] register_pernet_operations+0x18/0x20
 [<ffffffff8046e491>] register_pernet_device+0x31/0x70
 [<ffffffff806f18a0>] loopback_init+0x10/0x20
 [<ffffffff806caa48>] kernel_init+0x128/0x310
 [<ffffffff8026297f>] ? trace_hardirqs_on_caller+0xbf/0x150
 [<ffffffff80262a1d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff80500f9b>] ? _spin_unlock_irq+0x2b/0x40
 [<ffffffff80500830>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff8026297f>] ? trace_hardirqs_on_caller+0xbf/0x150
 [<ffffffff8020c6d9>] child_rip+0xa/0x11
 [<ffffffff8020bd0f>] ? restore_args+0x0/0x30
 [<ffffffff806ca920>] ? kernel_init+0x0/0x310
 [<ffffffff8020c6cf>] ? child_rip+0x0/0x11

and the second one is the following:

WARNING: at /home/rafael/src/linux-next/include/linux/blkdev.h:447 blk_plug_device+0x9b/0xb0()
Modules linked in: snd_hda_intel ohci1394 ieee1394 snd_pcm rtc_cmos sr_mod rtc_core floppy snd_timer wmi button cdrom rtc_lib serio_raw sky2 snd_page_alloc snd_hwdep snd evdev joydev sg soundcore raid456 async_xor async_memcpy async_tx xor raid0 usbhid ff_memless ehci_hcd ohci_hcd sd_mod edd raid1 ext3 jbd fan pata_marvell pata_atiixp thermal processor
Pid: 2244, comm: kjournald Not tainted 2.6.26-rc9-next #44

Call Trace:
 [<ffffffff8023d37f>] warn_on_slowpath+0x5f/0x80
 [<ffffffff80220030>] ? hpet_unregister_irq_handler+0x0/0x30
 [<ffffffff8022a8ae>] ? kmemcheck_mark_initialized+0xe/0x10
 [<ffffffff802b97fb>] ? kmemcheck_slab_alloc+0x2b/0x50
 [<ffffffff802b8610>] ? kmem_cache_alloc+0xc0/0x140
 [<ffffffff80291921>] ? mempool_alloc_slab+0x11/0x20
 [<ffffffff80291a8b>] ? mempool_alloc+0x5b/0x140
 [<ffffffff803575db>] blk_plug_device+0x9b/0xb0
 [<ffffffff80453d9f>] bitmap_startwrite+0xbf/0x1b0
 [<ffffffff802e87e4>] ? bio_alloc_bioset+0x54/0xb0
 [<ffffffffa004eafa>] make_request+0x39a/0x810 [raid1]
 [<ffffffff80291a8b>] ? mempool_alloc+0x5b/0x140
 [<ffffffff80291a8b>] ? mempool_alloc+0x5b/0x140
 [<ffffffff8035682d>] generic_make_request+0x17d/0x2b0
 [<ffffffff803581dc>] submit_bio+0x6c/0xf0
 [<ffffffff802e3c60>] submit_bh+0xf0/0x130
 [<ffffffffa001cce0>] journal_commit_transaction+0xa40/0x1000 [jbd]
 [<ffffffff80248504>] ? try_to_del_timer_sync+0x44/0x90
 [<ffffffffa0020967>] kjournald+0xe7/0x250 [jbd]
 [<ffffffff80254350>] ? autoremove_wake_function+0x0/0x40
 [<ffffffffa0020880>] ? kjournald+0x0/0x250 [jbd]
 [<ffffffff80253efd>] kthread+0x4d/0x80
 [<ffffffff8020c6d9>] child_rip+0xa/0x11
 [<ffffffff80500f9b>] ? _spin_unlock_irq+0x2b/0x40
 [<ffffffff8020bd0f>] ? restore_args+0x0/0x30
 [<ffffffff80254052>] ? kthreadd+0x122/0x1a0
 [<ffffffff80253eb0>] ? kthread+0x0/0x80
 [<ffffffff8020c6cf>] ? child_rip+0x0/0x11

---[ end trace d63b767d1ed7d78a ]---

Full dmesg output is at: http://www.sisk.pl/kernel/debug/20080711/dmesg-1.log

Thanks,
Rafael
