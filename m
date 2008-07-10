From: "Alexander Beregalov" <a.beregalov@gmail.com>
Subject: next-20080710: possible recursive locking detected at qdisc_lock_tree
Date: Thu, 10 Jul 2008 13:04:32 +0400
Message-ID: <a4423d670807100204kf269814ncd649bf02312311b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	linux-next@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.225]:13102 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756903AbYGJJEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 05:04:33 -0400
Received: by wx-out-0506.google.com with SMTP id h29so1376940wxd.4
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 02:04:32 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

It happens during booting.
It is x86_64 SMP.
[    0.393307] PCI: Using ACPI for IRQ routing
[    0.407715] DMAR:parse DMAR table failure.
[    0.408565] PCI-DMA: Disabling AGP.
[    0.409973] PCI-DMA: aperture base @ 20000000 size 65536 KB
[    0.409973] PCI-DMA: using GART IOMMU.
[    0.409973] PCI-DMA: Reserving 64MB of IOMMU area in the AGP aperture
[    0.420674] system 00:00: iomem range 0xfff00000-0xffffffff could
not be reserved
[    0.420739] system 00:00: iomem range 0xfec00000-0xfec00fff could
not be reserved
[    0.420799] system 00:00: iomem range 0xfee00000-0xfeefffff could
not be reserved
[    0.420860] system 00:00: iomem range 0xf8000000-0xf9ffffff could
not be reserved
[    0.420931] system 00:02: iomem range 0xd0040000-0xd0047fff has been reserved
[    0.420992] system 00:03: ioport range 0x1000-0x107f has been reserved
[    0.421041] system 00:03: ioport range 0x1080-0x10ff has been reserved
[    0.421090] system 00:03: ioport range 0x1400-0x147f has been reserved
[    0.421138] system 00:03: ioport range 0x1480-0x14ff has been reserved
[    0.421187] system 00:03: ioport range 0x1800-0x187f has been reserved
[    0.421235] system 00:03: ioport range 0x1880-0x18ff has been reserved
[    0.421284] system 00:03: ioport range 0x3440-0x347f has been reserved
[    0.421333] system 00:03: ioport range 0x3400-0x343f has been reserved
[    0.421393] system 00:04: ioport range 0x4d0-0x4d1 has been reserved
[    0.421441] system 00:04: ioport range 0xca8-0xca8 has been reserved
[    0.421490] system 00:04: ioport range 0xcac-0xcac has been reserved
[    0.421538] system 00:04: ioport range 0x295-0x296 has been reserved
[    0.426638]
[    0.426638] =============================================
[    0.426638] [ INFO: possible recursive locking detected ]
[    0.426638] 2.6.26-rc9-next-20080710 #5
[    0.426638] ---------------------------------------------
[    0.426638] swapper/1 is trying to acquire lock:
[    0.426638]  (&queue->lock){-...}, at: [<ffffffff8041c3d0>]
qdisc_lock_tree+0x27/0x2c
[    0.426638]
[    0.426638] but task is already holding lock:
[    0.426638]  (&queue->lock){-...}, at: [<ffffffff8041c3c8>]
qdisc_lock_tree+0x1f/0x2c
[    0.426638]
[    0.426638] other info that might help us debug this:
[    0.426638] 3 locks held by swapper/1:
[    0.426638]  #0:  (net_mutex){--..}, at: [<ffffffff8040b827>]
register_pernet_device+0x1a/0x5a
[    0.426638]  #1:  (rtnl_mutex){--..}, at: [<ffffffff80417179>]
rtnl_lock+0x12/0x14
[    0.426638]  #2:  (&queue->lock){-...}, at: [<ffffffff8041c3c8>]
qdisc_lock_tree+0x1f/0x2c
[    0.426638]
[    0.426638] stack backtrace:
[    0.426638] Pid: 1, comm: swapper Not tainted 2.6.26-rc9-next-20080710 #5
[    0.426638]
[    0.426638] Call Trace:
[    0.426638]  [<ffffffff8024f95a>] __lock_acquire+0xba9/0xf12
[    0.426638]  [<ffffffff8041c3d0>] ? qdisc_lock_tree+0x27/0x2c
[    0.426638]  [<ffffffff8024fd48>] lock_acquire+0x85/0xa9
[    0.426638]  [<ffffffff8041c3d0>] ? qdisc_lock_tree+0x27/0x2c
[    0.426638]  [<ffffffff80476794>] _spin_lock+0x25/0x31
[    0.426638]  [<ffffffff8041c3d0>] qdisc_lock_tree+0x27/0x2c
[    0.426638]  [<ffffffff8041c412>] dev_init_scheduler+0x11/0x94
[    0.426638]  [<ffffffff8040f3be>] register_netdevice+0x296/0x3f0
[    0.426638]  [<ffffffff8040f552>] register_netdev+0x3a/0x48
[    0.426638]  [<ffffffff805fc274>] loopback_net_init+0x40/0x7a
[    0.426638]  [<ffffffff805fc222>] ? loopback_init+0x0/0x12
[    0.426638]  [<ffffffff8040b83a>] register_pernet_device+0x2d/0x5a
[    0.426638]  [<ffffffff805fc232>] loopback_init+0x10/0x12
[    0.426638]  [<ffffffff805e4657>] kernel_init+0x150/0x2a9
[    0.426638]  [<ffffffff8024e76a>] ? trace_hardirqs_on_caller+0xf9/0x124
[    0.426638]  [<ffffffff8024e7a2>] ? trace_hardirqs_on+0xd/0xf
[    0.426638]  [<ffffffff80476681>] ? _spin_unlock_irq+0x2b/0x30
[    0.426638]  [<ffffffff804762b3>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[    0.426638]  [<ffffffff8024e76a>] ? trace_hardirqs_on_caller+0xf9/0x124
[    0.426638]  [<ffffffff8020c2f9>] child_rip+0xa/0x11
[    0.426638]  [<ffffffff8020b92f>] ? restore_args+0x0/0x30
[    0.426638]  [<ffffffff805e4507>] ? kernel_init+0x0/0x2a9
[    0.426638]  [<ffffffff8020c2ef>] ? child_rip+0x0/0x11
[    0.426638]
[    0.426638] pci 0000:00:06.0: PCI bridge, secondary bus 0000:01
[    0.426638] pci 0000:00:06.0:   IO window: 0x4000-0x4fff
[    0.426638] pci 0000:00:06.0:   MEM window: 0xd0100000-0xd01fffff
[    0.426638] pci 0000:00:06.0:   PREFETCH window: disabled
[    0.426638] pci 0000:00:0a.0: PCI bridge, secondary bus 0000:02
[    0.426638] pci 0000:00:0a.0:   IO window: disabled

Is it a net subsystem?
