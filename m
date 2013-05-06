From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [GIT] Networking
Date: Mon, 6 May 2013 16:46:48 +0000
Message-ID: <804857E1F29AAC47BF68C404FC60A1844E3DE0B6@FMSMSX153.amr.corp.intel.com>
References: <20130504.224225.1329294730869442752.davem@davemloft.net>
 <5186334A.7000904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Maarten Lankhorst <m.b.lankhorst@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5186334A.7000904@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Maarten Lankhorst [mailto:m.b.lankhorst@gmail.com]
> Sent: Sunday, May 05, 2013 3:24 AM
> To: David Miller; Allan, Bruce W
> Cc: torvalds@linux-foundation.org; akpm@linux-foundation.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [GIT] Networking
> 
> Hey,
> 
[snip]
> I finally decided to try 3.10rc0, but I'm getting a lot of this:
> 
> BUG: scheduling while atomic: irq/43-eth1/1465/0x00000102
> Modules linked in: adt7475 ebtable_nat ebtables nouveau
> ipt_MASQUERADE iptable_nat nf_nat_ipv4 nf_nat xt_CHECKSUM
> iptable_mangle bridge snd_hda_codec_hdmi stp llc ttm drm_kms_helper
> drm snd_hda_codec_realtek mxm_wmi intel_powerclamp kvm_intel kvm
> snd_hda_intel snd_hda_codec snd_hwdep e1000e snd_pcm video
> parport_pc snd_page_alloc ptp ppdev pps_core parport nfsd lockd nfs_acl
> auth_rpcgss sunrpc oid_registry(P)
> CPU: 0 PID: 1465 Comm: irq/43-eth1 Tainted: P        W    3.10.0-rc0-patser+
> #70
> Hardware name: Acer Aspire M3985/Aspire M3985, BIOS P01-A1 03/12/2012
>  0000000000000000 ffff88041dc03cc8 ffffffff8165ea16 ffff88041dc03cd8
>  ffffffff8165a84a ffff88041dc03d58 ffffffff8166200d 000000000000c350
>  000000000000c350 ffff8803f827a180 ffff8803f8275fd8 ffff8803f8275fd8
> Call Trace:
>  <IRQ>  [<ffffffff8165ea16>] dump_stack+0x19/0x1b
>  [<ffffffff8165a84a>] __schedule_bug+0x48/0x56
>  [<ffffffff8166200d>] __schedule+0x7fa/0x832
>  [<ffffffff81662154>] schedule+0x29/0x59
>  [<ffffffff81660aa0>] schedule_hrtimeout_range_clock+0xeb/0x129
>  [<ffffffff81078c5f>] ? update_rmtp+0x65/0x65
>  [<ffffffff81660af1>] schedule_hrtimeout_range+0x13/0x15
>  [<ffffffff8106140a>] usleep_range+0x40/0x42
>  [<ffffffffa012a39a>] e1000_irq_enable+0x18b/0x202 [e1000e]
>  [<ffffffffa012e022>] e1000e_poll+0x1d1/0x2e2 [e1000e]
>  [<ffffffff81535e1b>] net_rx_action+0xaa/0x1f3
>  [<ffffffff8105b055>] __do_softirq+0xcc/0x2a9
>  [<ffffffff810d49e1>] ? irq_thread_fn+0x48/0x48
>  [<ffffffff8166b3cc>] call_softirq+0x1c/0x30
>  <EOI>  [<ffffffff810042d3>] do_softirq+0x4d/0x8a
>  [<ffffffff8105ad57>] local_bh_enable+0xa0/0xa2
>  [<ffffffff810d4a2a>] irq_forced_thread_fn+0x49/0x5a
>  [<ffffffff810d467d>] irq_thread+0x122/0x145
>  [<ffffffff810d48e9>] ? irq_finalize_oneshot.part.33+0xe7/0xe7
>  [<ffffffff810d455b>] ? wake_threads_waitq+0x44/0x44
>  [<ffffffff81075fe5>] kthread+0xc0/0xc5
>  [<ffffffff81075f25>] ? flush_kthread_work+0x10c/0x10c
>  [<ffffffff8166a16c>] ret_from_fork+0x7c/0xb0
>  [<ffffffff81075f25>] ? flush_kthread_work+0x10c/0x10c
> 
> BUG: scheduling while atomic: Socket Thread/3163/0x00000402
> 
> etc, from various places..
> 
> I was using CONFIG_RCU_NOCB_CPU_ALL=y and threadirqs, I'm not sure if
> it's related or not..
> Looking at e1000e there has been a few commits to change everything to
> usleep_range, maybe
> it was a bit too much?
> 
> ~Maarten

Yup, my bad (commit ce43a216 e1000e: cleanup USLEEP_RANGE checkpatch checks).
I'll send along a patch to fix this shortly.

Bruce.
