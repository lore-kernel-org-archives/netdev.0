From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: [ipw2100, b44] Re: X or AF_UNIX and order 3 allocation
Date: Sun, 27 Apr 2008 19:48:24 +0300
Message-ID: <20080427164824.GA31477@ee.oulu.fi>
References: <20080415211055.882e67fe.zaitcev@redhat.com> <20080415.215144.87148045.davem@davemloft.net> <20080416085213.1e55bd1e@extreme> <20080416095938.66d798e4.zaitcev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Pete Zaitcev <zaitcev@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ee.oulu.fi ([130.231.61.23]:56274 "EHLO ee.oulu.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755670AbYD0RQs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Apr 2008 13:16:48 -0400
Content-Disposition: inline
In-Reply-To: <20080416095938.66d798e4.zaitcev@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 16, 2008 at 09:59:38AM -0700, Pete Zaitcev wrote:
> > > It seems to be the b44 driver doing a large huge order allocation.
> > > That driver only asks for (1536 + 30 + 64) bytes, so I suppose part of
> > > the problem is that SLAB is using an order 3 allocation to satisfy
> > > that.
> > The chip needs memory below 1G for DMA, perhaps low memory is getting
> > exhausted.
> The failure corresponds to memory pressure (from yum), but the real issue
> is the lack of order 3 areas. We're talking a 32KB chunk! Why would anyone
> need that much? Crazy!
Here too, but with ipw2100 not b44 (-rc8.git7, which has otherwise been
running quite happily for a few weeks)

swapper: page allocation failure. order:3, mode:0x4020
Pid: 0, comm: swapper Not tainted 2.6.25-0.218.rc8.git7.fc9.i686 #1
 [<c0466d66>] __alloc_pages+0x2cf/0x2e6
 [<c047e8f9>] __slab_alloc+0x19e/0x529
 [<c047fbc4>] __kmalloc_track_caller+0x87/0xca
 [<f09f8e00>] ? ipw2100_alloc_skb+0x19/0x5c [ipw2100]
 [<f09f8e00>] ? ipw2100_alloc_skb+0x19/0x5c [ipw2100]
 [<c05b4c30>] __alloc_skb+0x49/0xf8
 [<f09f8e00>] ipw2100_alloc_skb+0x19/0x5c [ipw2100]
 [<f09f9599>] ipw2100_irq_tasklet+0x4b1/0x6e0 [ipw2100]
 [<c042b161>] tasklet_action+0x5e/0xb3
 [<c042b879>] __do_softirq+0x79/0xe7
 [<c0407edf>] do_softirq+0x74/0xb5
 [<c045ccde>] ? handle_level_irq+0x0/0xbe
 [<c042b681>] irq_exit+0x38/0x6b
 [<c0407fcc>] do_IRQ+0xac/0xc4
 [<c04066eb>] common_interrupt+0x23/0x28
 [<c059e494>] ? poll_idle+0x21/0x65
 [<c059e3d2>] cpuidle_idle_call+0x62/0x92
 [<c059e370>] ? cpuidle_idle_call+0x0/0x92
 [<c0404c8d>] cpu_idle+0xbd/0xdd
 [<c061c009>] rest_init+0x49/0x4b
 =======================
Mem-info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd: 152
Active:155693 inactive:24779 dirty:2760 writeback:447 unstable:0
 free:2446 slab:6669 mapped:16577 pagetables:1509 bounce:0
DMA free:3012kB min:72kB low:88kB high:108kB active:6620kB inactive:952kB
present:16256kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 745 745 745
Normal free:6772kB min:3452kB low:4312kB high:5176kB active:616152kB
inactive:98164kB present:763400kB pages_scanned:260 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 33*4kB 6*8kB 5*16kB 0*32kB 1*64kB 3*128kB 1*256kB 0*512kB 0*1024kB
1*2048kB 0*4096kB = 3012kB
Normal: 1133*4kB 218*8kB 23*16kB 1*32kB 0*64kB 1*128kB 0*256kB 0*512kB
0*1024kB 0*2048kB 0*4096kB = 6804kB
75100 total pagecache pages
Swap cache: add 369369, delete 344259, find 701011/737099
Free swap  = 1314284kB
Total swap = 1572856kB
Free swap:       1314284kB
196448 pages of RAM
0 pages of HIGHMEM
2965 reserved pages
87587 pages shared
25110 pages swap cached
2760 pages dirty
447 pages writeback
16577 pages mapped
6669 pages slab
1509 pages pagetables
swapper: page allocation failure. order:3, mode:0x4020
Pid: 0, comm: swapper Not tainted 2.6.25-0.218.rc8.git7.fc9.i686 #1
 [<c0466d66>] __alloc_pages+0x2cf/0x2e6
 [<c047e8f9>] __slab_alloc+0x19e/0x529
 [<c047fbc4>] __kmalloc_track_caller+0x87/0xca
[<f09f8e00>] ? ipw2100_alloc_skb+0x19/0x5c [ipw2100]
 [<f09f8e00>] ? ipw2100_alloc_skb+0x19/0x5c [ipw2100]
 [<c05b4c30>] __alloc_skb+0x49/0xf8
 [<f09f8e00>] ipw2100_alloc_skb+0x19/0x5c [ipw2100]
 [<f09f9599>] ipw2100_irq_tasklet+0x4b1/0x6e0 [ipw2100]
 [<c042b161>] tasklet_action+0x5e/0xb3
 [<c042b879>] __do_softirq+0x79/0xe7
 [<c0407edf>] do_softirq+0x74/0xb5
 [<c045ccde>] ? handle_level_irq+0x0/0xbe
 [<c042b681>] irq_exit+0x38/0x6b
 [<c0407fcc>] do_IRQ+0xac/0xc4
 [<c04066eb>] common_interrupt+0x23/0x28
 [<c059e494>] ? poll_idle+0x21/0x65
 [<c059e3d2>] cpuidle_idle_call+0x62/0x92
 [<c059e370>] ? cpuidle_idle_call+0x0/0x92
 [<c0404c8d>] cpu_idle+0xbd/0xdd
 [<c061c009>] rest_init+0x49/0x4b
 =======================

It seems to have been a pretty transient thing:

messages-20080427:Apr 24 15:37:14 it-pc37 kernel: swapper: page allocation
failure. order:3, mode:0x4020
messages-20080427:Apr 24 15:37:15 it-pc37 kernel: swapper: page allocation
failure. order:3, mode:0x4020
messages-20080427:Apr 24 15:37:15 it-pc37 kernel: swapper: page allocation
failure. order:3, mode:0x4020
messages-20080427:Apr 24 15:37:15 it-pc37 kernel: swapper: page allocation
failure. order:3, mode:0x4020
messages-20080427:Apr 24 15:37:16 it-pc37 kernel: swapper: page allocation
failure. order:3, mode:0x4020
messages-20080427:Apr 24 15:37:16 it-pc37 kernel: swapper: page allocation
failure. order:3, mode:0x4020
messages-20080427:Apr 24 15:37:16 it-pc37 kernel: swapper: page allocation
failure. order:3, mode:0x4020
messages-20080427:Apr 24 15:37:16 it-pc37 kernel: swapper: page allocation
failure. order:3, mode:0x4020
messages-20080427:Apr 24 15:37:16 it-pc37 kernel: swapper: page allocation
failure. order:3, mode:0x4020
messages-20080427:Apr 24 15:37:16 it-pc37 kernel: swapper: page allocation
failure. order:3, mode:0x4020
messages-20080427:Apr 24 15:37:35 it-pc37 kernel: swapper: page allocation
failure. order:3, mode:0x4020
messages-20080427:Apr 24 15:37:35 it-pc37 kernel: swapper: page allocation
failure. order:3, mode:0x4020
messages-20080427:Apr 24 15:37:35 it-pc37 kernel: swapper: page allocation
failure. order:3, mode:0x4020
messages-20080427:Apr 24 15:37:37 it-pc37 kernel: swapper: page allocation
failure. order:3, mode:0x4020

(and nothing since that for a few days)

-- 
Pekka Pietikainen
