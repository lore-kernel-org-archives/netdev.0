From: Maarten Lankhorst <m.b.lankhorst@gmail.com>
Subject: Re: [GIT] Networking
Date: Sun, 05 May 2013 12:24:10 +0200
Message-ID: <5186334A.7000904@gmail.com>
References: <20130504.224225.1329294730869442752.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Bruce Allan <bruce.w.allan@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130504.224225.1329294730869442752.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey,

Op 05-05-13 04:42, David Miller schreef:
> 1) Several routines do not use netdev_features_t to hold such bitmask=
s,
>    fixes from Patrick McHardy and Bj=F8rn Mork.
>
> 2) Update cpsw IRQ software state and the actual HW irq enabling in
>    the correct order.  From Mugunthan V N.
>
> 3) When sending tipc packets to multiple bearers, we have to make cop=
ies
>    of the SKB rather than just giving the original SKB directly.  Fix
>    from Gerlando Falauto.
>
> 4) Fix race with bridging topology change timer, from Stephen
>    Hemminger.
>
> 5) Fix TCPv6 segmentation handling in GRE and VXLAN, from Pravin B
>    Shelar.
>
> 6) Endian bug in USB pegasus driver, from Dan Carpenter.
>
> 7) Fix crashes on MTU reduction in USB asix driver, from Holger
>    Eitzenberger.
>
> 8) Don't allow the kernel to BUG() just because the user puts some
>    crap in an AF_PACKET mmap() ring descriptor.  Fix from Daniel
>    Borkmann.
>
> 9) Don't use variable sized arrays on the stack in xen-netback, from
>    Wei Liu.
>
> 10) Fix stats reporting and an unbalanced napi_disable() in be2net
>     driver.  From Somnath Kotur and Ajit Khaparde.
>
I finally decided to try 3.10rc0, but I'm getting a lot of this:

BUG: scheduling while atomic: irq/43-eth1/1465/0x00000102
Modules linked in: adt7475 ebtable_nat ebtables nouveau ipt_MASQUERADE =
iptable_nat nf_nat_ipv4 nf_nat xt_CHECKSUM iptable_mangle bridge snd_hd=
a_codec_hdmi stp llc ttm drm_kms_helper drm snd_hda_codec_realtek mxm_w=
mi intel_powerclamp kvm_intel kvm snd_hda_intel snd_hda_codec snd_hwdep=
 e1000e snd_pcm video parport_pc snd_page_alloc ptp ppdev pps_core parp=
ort nfsd lockd nfs_acl auth_rpcgss sunrpc oid_registry(P)
CPU: 0 PID: 1465 Comm: irq/43-eth1 Tainted: P        W    3.10.0-rc0-pa=
tser+ #70
Hardware name: Acer Aspire M3985/Aspire M3985, BIOS P01-A1 03/12/2012
 0000000000000000 ffff88041dc03cc8 ffffffff8165ea16 ffff88041dc03cd8
 ffffffff8165a84a ffff88041dc03d58 ffffffff8166200d 000000000000c350
 000000000000c350 ffff8803f827a180 ffff8803f8275fd8 ffff8803f8275fd8
Call Trace:
 <IRQ>  [<ffffffff8165ea16>] dump_stack+0x19/0x1b
 [<ffffffff8165a84a>] __schedule_bug+0x48/0x56
 [<ffffffff8166200d>] __schedule+0x7fa/0x832
 [<ffffffff81662154>] schedule+0x29/0x59
 [<ffffffff81660aa0>] schedule_hrtimeout_range_clock+0xeb/0x129
 [<ffffffff81078c5f>] ? update_rmtp+0x65/0x65
 [<ffffffff81660af1>] schedule_hrtimeout_range+0x13/0x15
 [<ffffffff8106140a>] usleep_range+0x40/0x42
 [<ffffffffa012a39a>] e1000_irq_enable+0x18b/0x202 [e1000e]
 [<ffffffffa012e022>] e1000e_poll+0x1d1/0x2e2 [e1000e]
 [<ffffffff81535e1b>] net_rx_action+0xaa/0x1f3
 [<ffffffff8105b055>] __do_softirq+0xcc/0x2a9
 [<ffffffff810d49e1>] ? irq_thread_fn+0x48/0x48
 [<ffffffff8166b3cc>] call_softirq+0x1c/0x30
 <EOI>  [<ffffffff810042d3>] do_softirq+0x4d/0x8a
 [<ffffffff8105ad57>] local_bh_enable+0xa0/0xa2
 [<ffffffff810d4a2a>] irq_forced_thread_fn+0x49/0x5a
 [<ffffffff810d467d>] irq_thread+0x122/0x145
 [<ffffffff810d48e9>] ? irq_finalize_oneshot.part.33+0xe7/0xe7
 [<ffffffff810d455b>] ? wake_threads_waitq+0x44/0x44
 [<ffffffff81075fe5>] kthread+0xc0/0xc5
 [<ffffffff81075f25>] ? flush_kthread_work+0x10c/0x10c
 [<ffffffff8166a16c>] ret_from_fork+0x7c/0xb0
 [<ffffffff81075f25>] ? flush_kthread_work+0x10c/0x10c

BUG: scheduling while atomic: Socket Thread/3163/0x00000402

etc, from various places..

I was using CONFIG_RCU_NOCB_CPU_ALL=3Dy and threadirqs, I'm not sure if=
 it's related or not..
Looking at e1000e there has been a few commits to change everything to =
usleep_range, maybe
it was a bit too much?

~Maarten
