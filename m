From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: page allocation failure
Date: Sat, 14 Jun 2008 05:25:59 +0300
Message-ID: <20080614022451.M72462@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:56194 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752701AbYFNC0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 22:26:11 -0400
Received: from visp.net.lb (localhost [127.0.0.1])
	by usermail.globalproof.net (Postfix) with ESMTP id B3110BD44F
	for <netdev@vger.kernel.org>; Sat, 14 Jun 2008 05:25:59 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am not sure it is error, but this message appearing on loaded PC routers.
(about 100-150Mbit/s passing there, and rtorrent also running, 1G of ram)

For example:
[1407075.519722] swapper: page allocation failure. order:3, mode:0x4020
[1407075.519722] Pid: 0, comm: swapper Not tainted 2.6.25.4-devel2 #1
[1407075.519722]  [<c0144c09>] __alloc_pages+0x2a9/0x2bd
[1407075.519722]  [<c015a606>] __slab_alloc+0x14a/0x45e
[1407075.519722]  [<c015b4c9>] __kmalloc_track_caller+0x72/0xb9
[1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519722]  [<c030156c>] __alloc_skb+0x4d/0xf9
[1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519722]  [<f887f395>] bnx2_poll+0x58f/0xd0c [bnx2]
[1407075.519722]  [<c0307469>] net_rx_action+0xa4/0x1bf
[1407075.519722]  [<c01219fd>] __do_softirq+0x5d/0xc1
[1407075.519722]  [<c0105be4>] do_softirq+0x52/0x85
[1407075.519722]  [<c013ea70>] handle_edge_irq+0x0/0xff
[1407075.519722]  [<c012196e>] irq_exit+0x35/0x67
[1407075.519722]  [<c0105cb0>] do_IRQ+0x99/0xad
[1407075.519722]  [<c01040ef>] common_interrupt+0x23/0x28
[1407075.519722]  [<c01200d8>] sys_waitid+0x11/0x85
[1407075.519722]  [<c010260c>] default_idle+0x37/0x59
[1407075.519722]  [<c01025d5>] default_idle+0x0/0x59
[1407075.519722]  [<c010251f>] cpu_idle+0x6e/0x87
[1407075.519722]  =======================
[1407075.519722] Mem-info:
[1407075.519722] DMA per-cpu:
[1407075.519722] CPU    0: hi:    0, btch:   1 usd:   0
[1407075.519722] CPU    1: hi:    0, btch:   1 usd:   0
[1407075.519722] CPU    2: hi:    0, btch:   1 usd:   0
[1407075.519722] CPU    3: hi:    0, btch:   1 usd:   0
[1407075.519722] Normal per-cpu:
[1407075.519722] CPU    0: hi:  186, btch:  31 usd: 179
[1407075.519722] CPU    1: hi:  186, btch:  31 usd:  75
[1407075.519722] CPU    2: hi:  186, btch:  31 usd:  53
[1407075.519722] CPU    3: hi:  186, btch:  31 usd:  85
[1407075.519722] HighMem per-cpu:
[1407075.519722] CPU    0: hi:   42, btch:   7 usd:  39
[1407075.519722] CPU    1: hi:   42, btch:   7 usd:  36
[1407075.519722] CPU    2: hi:   42, btch:   7 usd:  20
[1407075.519722] CPU    3: hi:   42, btch:   7 usd:  21
[1407075.519722] Active:96553 inactive:148441 dirty:0 writeback:0 unstable:0
[1407075.519722]  free:3535 slab:6033 mapped:3064 pagetables:162 bounce:0
[1407075.519722] DMA free:3508kB min:64kB low:80kB high:96kB active:396kB
inactive:5812kB present:16176kB pages_scanned:0 all_unreclaimable? no
[1407075.519722] lowmem_reserve[]: 0 868 994 994
[1407075.519722] Normal free:10428kB min:3736kB low:4668kB high:5604kB
active:321452kB inactive:522780kB present:889680kB pages_scanned:96
all_unreclaimable? no
[1407075.519722] lowmem_reserve[]: 0 0 1008 1008
[1407075.519722] HighMem free:204kB min:128kB low:260kB high:396kB
active:64364kB inactive:65172kB present:129064kB pages_scanned:612
all_unreclaimable? no
[1407075.519722] lowmem_reserve[]: 0 0 0 0
[1407075.519722] DMA: 35*4kB 27*8kB 1*16kB 0*32kB 1*64kB 0*128kB 0*256kB
0*512kB 1*1024kB 1*2048kB 0*4096kB = 3508kB
[1407075.519722] Normal: 1621*4kB 211*8kB 133*16kB 0*32kB 1*64kB 0*128kB
0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 10364kB
[1407075.519722] HighMem: 13*4kB 3*8kB 2*16kB 1*32kB 1*64kB 0*128kB 0*256kB
0*512kB 0*1024kB 0*2048kB 0*4096kB = 204kB
[1407075.519722] 234421 total pagecache pages
[1407075.519722] Swap cache: add 0, delete 0, find 0/0
[1407075.519722] Free swap  = 0kB
[1407075.519722] Total swap = 0kB
[1407075.519722] Free swap:            0kB
[1407075.519722] 262056 pages of RAM
[1407075.519722] 32680 pages of HIGHMEM
[1407075.519722] 5048 reserved pages
[1407075.519722] 18938 pages shared
[1407075.519722] 0 pages swap cached
[1407075.519722] 0 pages dirty
[1407075.519722] 0 pages writeback
[1407075.519722] 3064 pages mapped
[1407075.519722] 6033 pages slab
[1407075.519722] 162 pages pagetables
[1407075.519722] swapper: page allocation failure. order:3, mode:0x4020
[1407075.519722] Pid: 0, comm: swapper Not tainted 2.6.25.4-devel2 #1
[1407075.519722]  [<c0144c09>] __alloc_pages+0x2a9/0x2bd
[1407075.519722]  [<c015a606>] __slab_alloc+0x14a/0x45e
[1407075.519722]  [<c015b4c9>] __kmalloc_track_caller+0x72/0xb9
[1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519722]  [<c030156c>] __alloc_skb+0x4d/0xf9
[1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519722]  [<f887f395>] bnx2_poll+0x58f/0xd0c [bnx2]
[1407075.519722]  [<c0307469>] net_rx_action+0xa4/0x1bf
[1407075.519722]  [<c01219fd>] __do_softirq+0x5d/0xc1
[1407075.519722]  [<c0105be4>] do_softirq+0x52/0x85
[1407075.519722]  [<c013ea70>] handle_edge_irq+0x0/0xff
[1407075.519722]  [<c012196e>] irq_exit+0x35/0x67
[1407075.519722]  [<c0105cb0>] do_IRQ+0x99/0xad
[1407075.519722]  [<c01040ef>] common_interrupt+0x23/0x28
[1407075.519722]  [<c01200d8>] sys_waitid+0x11/0x85
[1407075.519722]  [<c010260c>] default_idle+0x37/0x59
[1407075.519722]  [<c01025d5>] default_idle+0x0/0x59
[1407075.519722]  [<c010251f>] cpu_idle+0x6e/0x87
[1407075.519722]  =======================
[1407075.519722] Mem-info:
[1407075.519722] DMA per-cpu:
[1407075.519722] CPU    0: hi:    0, btch:   1 usd:   0
[1407075.519722] CPU    1: hi:    0, btch:   1 usd:   0
[1407075.519722] CPU    2: hi:    0, btch:   1 usd:   0
[1407075.519722] CPU    3: hi:    0, btch:   1 usd:   0
[1407075.519722] Normal per-cpu:
[1407075.519722] CPU    0: hi:  186, btch:  31 usd: 178
[1407075.519722] CPU    1: hi:  186, btch:  31 usd:  75
[1407075.519722] CPU    2: hi:  186, btch:  31 usd:  50
[1407075.519722] CPU    3: hi:  186, btch:  31 usd:  85
[1407075.519722] HighMem per-cpu:
[1407075.519722] CPU    0: hi:   42, btch:   7 usd:  39
[1407075.519722] CPU    1: hi:   42, btch:   7 usd:  36
[1407075.519722] CPU    2: hi:   42, btch:   7 usd:  20
[1407075.519722] CPU    3: hi:   42, btch:   7 usd:  21
[1407075.519722] Active:96553 inactive:148441 dirty:0 writeback:0 unstable:0
[1407075.519722]  free:3535 slab:6033 mapped:3064 pagetables:162 bounce:0
[1407075.519722] DMA free:3508kB min:64kB low:80kB high:96kB active:396kB
inactive:5812kB present:16176kB pages_scanned:0 all_unreclaimable? no
[1407075.519722] lowmem_reserve[]: 0 868 994 994
[1407075.519722] Normal free:10428kB min:3736kB low:4668kB high:5604kB
active:321452kB inactive:522780kB present:889680kB pages_scanned:96
all_unreclaimable? no
[1407075.519722] lowmem_reserve[]: 0 0 1008 1008
[1407075.519722] HighMem free:204kB min:128kB low:260kB high:396kB
active:64364kB inactive:65172kB present:129064kB pages_scanned:612
all_unreclaimable? no
[1407075.519722] lowmem_reserve[]: 0 0 0 0
[1407075.519722] DMA: 35*4kB 27*8kB 1*16kB 0*32kB 1*64kB 0*128kB 0*256kB
0*512kB 1*1024kB 1*2048kB 0*4096kB = 3508kB
[1407075.519722] Normal: 1621*4kB 211*8kB 133*16kB 0*32kB 1*64kB 0*128kB
0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 10364kB
[1407075.519722] HighMem: 13*4kB 3*8kB 2*16kB 1*32kB 1*64kB 0*128kB 0*256kB
0*512kB 0*1024kB 0*2048kB 0*4096kB = 204kB
[1407075.519722] 234421 total pagecache pages
[1407075.519722] Swap cache: add 0, delete 0, find 0/0
[1407075.519722] Free swap  = 0kB
[1407075.519722] Total swap = 0kB
[1407075.519722] Free swap:            0kB
[1407075.519722] 262056 pages of RAM
[1407075.519722] 32680 pages of HIGHMEM
[1407075.519722] 5048 reserved pages
[1407075.519722] 18942 pages shared
[1407075.519722] 0 pages swap cached
[1407075.519722] 0 pages dirty
[1407075.519722] 0 pages writeback
[1407075.519722] 3064 pages mapped
[1407075.519722] 6033 pages slab
[1407075.519722] 162 pages pagetables
[1407075.519722] swapper: page allocation failure. order:3, mode:0x4020
[1407075.519722] Pid: 0, comm: swapper Not tainted 2.6.25.4-devel2 #1
[1407075.519722]  [<c0144c09>] __alloc_pages+0x2a9/0x2bd
[1407075.519722]  [<c015a606>] __slab_alloc+0x14a/0x45e
[1407075.519722]  [<c015b4c9>] __kmalloc_track_caller+0x72/0xb9
[1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519722]  [<c030156c>] __alloc_skb+0x4d/0xf9
[1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519722]  [<f887f395>] bnx2_poll+0x58f/0xd0c [bnx2]
[1407075.519722]  [<c0307469>] net_rx_action+0xa4/0x1bf
[1407075.519722]  [<c01219fd>] __do_softirq+0x5d/0xc1
[1407075.519722]  [<c0105be4>] do_softirq+0x52/0x85
[1407075.519722]  [<c013ea70>] handle_edge_irq+0x0/0xff
[1407075.519722]  [<c012196e>] irq_exit+0x35/0x67
[1407075.519722]  [<c0105cb0>] do_IRQ+0x99/0xad
[1407075.519722]  [<c01040ef>] common_interrupt+0x23/0x28
[1407075.519722]  [<c01200d8>] sys_waitid+0x11/0x85
[1407075.519722]  [<c010260c>] default_idle+0x37/0x59
[1407075.519722]  [<c01025d5>] default_idle+0x0/0x59
[1407075.519722]  [<c010251f>] cpu_idle+0x6e/0x87
[1407075.519722]  =======================
[1407075.519722] Mem-info:
[1407075.519722] DMA per-cpu:
[1407075.519722] CPU    0: hi:    0, btch:   1 usd:   0
[1407075.519722] CPU    1: hi:    0, btch:   1 usd:   0
[1407075.519722] CPU    2: hi:    0, btch:   1 usd:   0
[1407075.519722] CPU    3: hi:    0, btch:   1 usd:   0
[1407075.519722] Normal per-cpu:
[1407075.519722] CPU    0: hi:  186, btch:  31 usd: 177
[1407075.519722] CPU    1: hi:  186, btch:  31 usd:  75
[1407075.519722] CPU    2: hi:  186, btch:  31 usd:  49
[1407075.519722] CPU    3: hi:  186, btch:  31 usd:  85
[1407075.519722] HighMem per-cpu:
[1407075.519722] CPU    0: hi:   42, btch:   7 usd:  39
[1407075.519722] CPU    1: hi:   42, btch:   7 usd:  36
[1407075.519722] CPU    2: hi:   42, btch:   7 usd:  20
[1407075.519722] CPU    3: hi:   42, btch:   7 usd:  21
[1407075.519722] Active:96553 inactive:148441 dirty:0 writeback:0 unstable:0
[1407075.519722]  free:3535 slab:6033 mapped:3064 pagetables:162 bounce:0
[1407075.519722] DMA free:3508kB min:64kB low:80kB high:96kB active:396kB
inactive:5812kB present:16176kB pages_scanned:0 all_unreclaimable? no
[1407075.519722] lowmem_reserve[]: 0 868 994 994
[1407075.519722] Normal free:10428kB min:3736kB low:4668kB high:5604kB
active:321452kB inactive:522780kB present:889680kB pages_scanned:96
all_unreclaimable? no
[1407075.519722] lowmem_reserve[]: 0 0 1008 1008
[1407075.519722] HighMem free:204kB min:128kB low:260kB high:396kB
active:64364kB inactive:65172kB present:129064kB pages_scanned:612
all_unreclaimable? no
[1407075.519722] lowmem_reserve[]: 0 0 0 0
[1407075.519722] DMA: 35*4kB 27*8kB 1*16kB 0*32kB 1*64kB 0*128kB 0*256kB
0*512kB 1*1024kB 1*2048kB 0*4096kB = 3508kB
[1407075.519722] Normal: 1621*4kB 211*8kB 133*16kB 0*32kB 1*64kB 0*128kB
0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 10364kB
[1407075.519722] HighMem: 13*4kB 3*8kB 2*16kB 1*32kB 1*64kB 0*128kB 0*256kB
0*512kB 0*1024kB 0*2048kB 0*4096kB = 204kB
[1407075.519722] 234421 total pagecache pages
[1407075.519722] Swap cache: add 0, delete 0, find 0/0
[1407075.519722] Free swap  = 0kB
[1407075.519722] Total swap = 0kB
[1407075.519722] Free swap:            0kB
[1407075.519722] 262056 pages of RAM
[1407075.519722] 32680 pages of HIGHMEM
[1407075.519722] 5048 reserved pages
[1407075.519722] 18944 pages shared
[1407075.519722] 0 pages swap cached
[1407075.519722] 0 pages dirty
[1407075.519722] 0 pages writeback
[1407075.519722] 3064 pages mapped
[1407075.519722] 6033 pages slab
[1407075.519722] 162 pages pagetables
[1407075.519722] swapper: page allocation failure. order:3, mode:0x4020
[1407075.519722] Pid: 0, comm: swapper Not tainted 2.6.25.4-devel2 #1
[1407075.519722]  [<c0144c09>] __alloc_pages+0x2a9/0x2bd
[1407075.519722]  [<c015a606>] __slab_alloc+0x14a/0x45e
[1407075.519722]  [<c015b4c9>] __kmalloc_track_caller+0x72/0xb9
[1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519722]  [<c030156c>] __alloc_skb+0x4d/0xf9
[1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519722]  [<f887f395>] bnx2_poll+0x58f/0xd0c [bnx2]
[1407075.519722]  [<c0307469>] net_rx_action+0xa4/0x1bf
[1407075.519722]  [<c01219fd>] __do_softirq+0x5d/0xc1
[1407075.519722]  [<c0105be4>] do_softirq+0x52/0x85
[1407075.519722]  [<c013ea70>] handle_edge_irq+0x0/0xff
[1407075.519722]  [<c012196e>] irq_exit+0x35/0x67
[1407075.519722]  [<c0105cb0>] do_IRQ+0x99/0xad
[1407075.519722]  [<c01040ef>] common_interrupt+0x23/0x28
[1407075.519722]  [<c01200d8>] sys_waitid+0x11/0x85
[1407075.519722]  [<c010260c>] default_idle+0x37/0x59
[1407075.519722]  [<c01025d5>] default_idle+0x0/0x59
[1407075.519722]  [<c010251f>] cpu_idle+0x6e/0x87
[1407075.519722]  =======================
[1407075.519722] Mem-info:
[1407075.519722] DMA per-cpu:
[1407075.519722] CPU    0: hi:    0, btch:   1 usd:   0
[1407075.519722] CPU    1: hi:    0, btch:   1 usd:   0
[1407075.519722] CPU    2: hi:    0, btch:   1 usd:   0
[1407075.519722] CPU    3: hi:    0, btch:   1 usd:   0
[1407075.519722] Normal per-cpu:
[1407075.519722] CPU    0: hi:  186, btch:  31 usd: 176
[1407075.519722] CPU    1: hi:  186, btch:  31 usd:  75
[1407075.519722] CPU    2: hi:  186, btch:  31 usd:  48
[1407075.519722] CPU    3: hi:  186, btch:  31 usd:  85
[1407075.519722] HighMem per-cpu:
[1407075.519722] CPU    0: hi:   42, btch:   7 usd:  39
[1407075.519722] CPU    1: hi:   42, btch:   7 usd:  36
[1407075.519722] CPU    2: hi:   42, btch:   7 usd:  20
[1407075.519722] CPU    3: hi:   42, btch:   7 usd:  21
[1407075.519722] Active:96553 inactive:148441 dirty:0 writeback:0 unstable:0
[1407075.519722]  free:3535 slab:6033 mapped:3064 pagetables:162 bounce:0
[1407075.519722] DMA free:3508kB min:64kB low:80kB high:96kB active:396kB
inactive:5812kB present:16176kB pages_scanned:0 all_unreclaimable? no
[1407075.519722] lowmem_reserve[]: 0 868 994 994
[1407075.519722] Normal free:10428kB min:3736kB low:4668kB high:5604kB
active:321452kB inactive:522780kB present:889680kB pages_scanned:96
all_unreclaimable? no
[1407075.519722] lowmem_reserve[]: 0 0 1008 1008
[1407075.519722] HighMem free:204kB min:128kB low:260kB high:396kB
active:64364kB inactive:65172kB present:129064kB pages_scanned:612
all_unreclaimable? no
[1407075.519722] lowmem_reserve[]: 0 0 0 0
[1407075.519722] DMA: 35*4kB 27*8kB 1*16kB 0*32kB 1*64kB 0*128kB 0*256kB
0*512kB 1*1024kB 1*2048kB 0*4096kB = 3508kB
[1407075.519722] Normal: 1621*4kB 211*8kB 133*16kB 0*32kB 1*64kB 0*128kB
0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 10364kB
[1407075.519722] HighMem: 13*4kB 3*8kB 2*16kB 1*32kB 1*64kB 0*128kB 0*256kB
0*512kB 0*1024kB 0*2048kB 0*4096kB = 204kB
[1407075.519722] 234421 total pagecache pages
[1407075.519722] Swap cache: add 0, delete 0, find 0/0
[1407075.519722] Free swap  = 0kB
[1407075.519722] Total swap = 0kB
[1407075.519722] Free swap:            0kB
[1407075.519722] 262056 pages of RAM
[1407075.519722] 32680 pages of HIGHMEM
[1407075.519722] 5048 reserved pages
[1407075.519722] 18944 pages shared
[1407075.519722] 0 pages swap cached
[1407075.519722] 0 pages dirty
[1407075.519722] 0 pages writeback
[1407075.519722] 3064 pages mapped
[1407075.519722] 6033 pages slab
[1407075.519722] 162 pages pagetables
[1407075.519722] swapper: page allocation failure. order:3, mode:0x4020
[1407075.519722] Pid: 0, comm: swapper Not tainted 2.6.25.4-devel2 #1
[1407075.519722]  [<c0144c09>] __alloc_pages+0x2a9/0x2bd
[1407075.519722]  [<c015a606>] __slab_alloc+0x14a/0x45e
[1407075.519722]  [<c015b4c9>] __kmalloc_track_caller+0x72/0xb9
[1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519722]  [<c030156c>] __alloc_skb+0x4d/0xf9
[1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519722]  [<f887f395>] bnx2_poll+0x58f/0xd0c [bnx2]
[1407075.519722]  [<c0307469>] net_rx_action+0xa4/0x1bf
[1407075.519722]  [<c01219fd>] __do_softirq+0x5d/0xc1
[1407075.519722]  [<c0105be4>] do_softirq+0x52/0x85
[1407075.519722]  [<c013ea70>] handle_edge_irq+0x0/0xff
[1407075.519722]  [<c012196e>] irq_exit+0x35/0x67
[1407075.519722]  [<c0105cb0>] do_IRQ+0x99/0xad
[1407075.519722]  [<c01040ef>] common_interrupt+0x23/0x28
[1407075.519722]  [<c01200d8>] sys_waitid+0x11/0x85
[1407075.519722]  [<c010260c>] default_idle+0x37/0x59
[1407075.519722]  [<c01025d5>] default_idle+0x0/0x59
[1407075.519722]  [<c010251f>] cpu_idle+0x6e/0x87
[1407075.519722]  =======================
[1407075.519722] Mem-info:
[1407075.519722] DMA per-cpu:
[1407075.519722] CPU    0: hi:    0, btch:   1 usd:   0
[1407075.519722] CPU    1: hi:    0, btch:   1 usd:   0
[1407075.519722] CPU    2: hi:    0, btch:   1 usd:   0
[1407075.519722] CPU    3: hi:    0, btch:   1 usd:   0
[1407075.519722] Normal per-cpu:
[1407075.519722] CPU    0: hi:  186, btch:  31 usd: 175
[1407075.519722] CPU    1: hi:  186, btch:  31 usd:  75
[1407075.519722] CPU    2: hi:  186, btch:  31 usd:  47
[1407075.519722] CPU    3: hi:  186, btch:  31 usd:  85
[1407075.519722] HighMem per-cpu:
[1407075.519722] CPU    0: hi:   42, btch:   7 usd:  39
[1407075.519722] CPU    1: hi:   42, btch:   7 usd:  36
[1407075.519722] CPU    2: hi:   42, btch:   7 usd:  20
[1407075.519722] CPU    3: hi:   42, btch:   7 usd:  21
[1407075.519722] Active:96553 inactive:148441 dirty:0 writeback:0 unstable:0
[1407075.519722]  free:3535 slab:6033 mapped:3064 pagetables:162 bounce:0
[1407075.519722] DMA free:3508kB min:64kB low:80kB high:96kB active:396kB
inactive:5812kB present:16176kB pages_scanned:0 all_unreclaimable? no
[1407075.519722] lowmem_reserve[]: 0 868 994 994
[1407075.519722] Normal free:10428kB min:3736kB low:4668kB high:5604kB
active:321452kB inactive:522780kB present:889680kB pages_scanned:96
all_unreclaimable? no
[1407075.519722] lowmem_reserve[]: 0 0 1008 1008
[1407075.519722] HighMem free:204kB min:128kB low:260kB high:396kB
active:64364kB inactive:65172kB present:129064kB pages_scanned:612
all_unreclaimable? no
[1407075.519722] lowmem_reserve[]: 0 0 0 0
[1407075.519722] DMA: 35*4kB 27*8kB 1*16kB 0*32kB 1*64kB 0*128kB 0*256kB
0*512kB 1*1024kB 1*2048kB 0*4096kB = 3508kB
[1407075.519722] Normal: 1621*4kB 211*8kB 133*16kB 0*32kB 1*64kB 0*128kB
0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 10364kB
[1407075.519722] HighMem: 13*4kB 3*8kB 2*16kB 1*32kB 1*64kB 0*128kB 0*256kB
0*512kB 0*1024kB 0*2048kB 0*4096kB = 204kB
[1407075.519722] 234421 total pagecache pages
[1407075.519722] Swap cache: add 0, delete 0, find 0/0
[1407075.519722] Free swap  = 0kB
[1407075.519722] Total swap = 0kB
[1407075.519722] Free swap:            0kB
[1407075.519722] 262056 pages of RAM
[1407075.519722] 32680 pages of HIGHMEM
[1407075.519722] 5048 reserved pages
[1407075.519722] 18950 pages shared
[1407075.519722] 0 pages swap cached
[1407075.519722] 0 pages dirty
[1407075.519722] 0 pages writeback
[1407075.519722] 3064 pages mapped
[1407075.519722] 6033 pages slab
[1407075.519722] 162 pages pagetables
[1407075.519722] swapper: page allocation failure. order:3, mode:0x4020
[1407075.519722] Pid: 0, comm: swapper Not tainted 2.6.25.4-devel2 #1
[1407075.519722]  [<c0144c09>] __alloc_pages+0x2a9/0x2bd
[1407075.519722]  [<c015a606>] __slab_alloc+0x14a/0x45e
[1407075.519722]  [<c015b4c9>] __kmalloc_track_caller+0x72/0xb9
[1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519722]  [<c030156c>] __alloc_skb+0x4d/0xf9
[1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519722]  [<f887f395>] bnx2_poll+0x58f/0xd0c [bnx2]
[1407075.519722]  [<c0307469>] net_rx_action+0xa4/0x1bf
[1407075.519722]  [<c01219fd>] __do_softirq+0x5d/0xc1
[1407075.519722]  [<c0105be4>] do_softirq+0x52/0x85
[1407075.519722]  [<c013ea70>] handle_edge_irq+0x0/0xff
[1407075.519722]  [<c012196e>] irq_exit+0x35/0x67
[1407075.519722]  [<c0105cb0>] do_IRQ+0x99/0xad
[1407075.519722]  [<c01040ef>] common_interrupt+0x23/0x28
[1407075.519722]  [<c01200d8>] sys_waitid+0x11/0x85
[1407075.519722]  [<c010260c>] default_idle+0x37/0x59
[1407075.519722]  [<c01025d5>] default_idle+0x0/0x59
[1407075.519722]  [<c010251f>] cpu_idle+0x6e/0x87
[1407075.519722]  =======================
[1407075.519722] Mem-info:
[1407075.519722] DMA per-cpu:
[1407075.519722] CPU    0: hi:    0, btch:   1 usd:   0
[1407075.519722] CPU    1: hi:    0, btch:   1 usd:   0
[1407075.519722] CPU    2: hi:    0, btch:   1 usd:   0
[1407075.519722] CPU    3: hi:    0, btch:   1 usd:   0
[1407075.519722] Normal per-cpu:
[1407075.519722] CPU    0: hi:  186, btch:  31 usd: 174
[1407075.519722] CPU    1: hi:  186, btch:  31 usd:  75
[1407075.519722] CPU    2: hi:  186, btch:  31 usd:  45
[1407075.519722] CPU    3: hi:  186, btch:  31 usd:  85
[1407075.519722] HighMem per-cpu:
[1407075.519722] CPU    0: hi:   42, btch:   7 usd:  39
[1407075.519722] CPU    1: hi:   42, btch:   7 usd:  36
[1407075.519722] CPU    2: hi:   42, btch:   7 usd:  20
[1407075.519722] CPU    3: hi:   42, btch:   7 usd:  21
[1407075.519722] Active:96553 inactive:148441 dirty:0 writeback:0 unstable:0
[1407075.519722]  free:3535 slab:6033 mapped:3064 pagetables:162 bounce:0
[1407075.519722] DMA free:3508kB min:64kB low:80kB high:96kB active:396kB
inactive:5812kB present:16176kB pages_scanned:0 all_unreclaimable? no
[1407075.519722] lowmem_reserve[]: 0 868 994 994
[1407075.519722] Normal free:10428kB min:3736kB low:4668kB high:5604kB
active:321452kB inactive:522780kB present:889680kB pages_scanned:96
all_unreclaimable? no
[1407075.519722] lowmem_reserve[]: 0 0 1008 1008
[1407075.519722] HighMem free:204kB min:128kB low:260kB high:396kB
active:64364kB inactive:65172kB present:129064kB pages_scanned:612
all_unreclaimable? no
[1407075.519722] lowmem_reserve[]: 0 0 0 0
[1407075.519722] DMA: 35*4kB 27*8kB 1*16kB 0*32kB 1*64kB 0*128kB 0*256kB
0*512kB 1*1024kB 1*2048kB 0*4096kB = 3508kB
[1407075.519722] Normal: 1621*4kB 211*8kB 133*16kB 0*32kB 1*64kB 0*128kB
0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 10364kB
[1407075.519722] HighMem: 13*4kB 3*8kB 2*16kB 1*32kB 1*64kB 0*128kB 0*256kB
0*512kB 0*1024kB 0*2048kB 0*4096kB = 204kB
[1407075.519722] 234421 total pagecache pages
[1407075.519722] Swap cache: add 0, delete 0, find 0/0
[1407075.519722] Free swap  = 0kB
[1407075.519722] Total swap = 0kB
[1407075.519722] Free swap:            0kB
[1407075.519722] 262056 pages of RAM
[1407075.519722] 32680 pages of HIGHMEM
[1407075.519722] 5048 reserved pages
[1407075.519722] 18952 pages shared
[1407075.519722] 0 pages swap cached
[1407075.519722] 0 pages dirty
[1407075.519722] 0 pages writeback
[1407075.519722] 3064 pages mapped
[1407075.519722] 6033 pages slab
[1407075.519722] 162 pages pagetables
[1407075.519722] swapper: page allocation failure. order:3, mode:0x4020
[1407075.519722] Pid: 0, comm: swapper Not tainted 2.6.25.4-devel2 #1
[1407075.519722]  [<c0144c09>] __alloc_pages+0x2a9/0x2bd
[1407075.519722]  [<c015a606>] __slab_alloc+0x14a/0x45e
[1407075.519722]  [<c015b4c9>] __kmalloc_track_caller+0x72/0xb9
[1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519722]  [<c030156c>] __alloc_skb+0x4d/0xf9
[1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519722]  [<f887f395>] bnx2_poll+0x58f/0xd0c [bnx2]
[1407075.519722]  [<c0307469>] net_rx_action+0xa4/0x1bf
[1407075.519722]  [<c01219fd>] __do_softirq+0x5d/0xc1
[1407075.519722]  [<c0105be4>] do_softirq+0x52/0x85
[1407075.519722]  [<c013ea70>] handle_edge_irq+0x0/0xff
[1407075.519722]  [<c012196e>] irq_exit+0x35/0x67
[1407075.519722]  [<c0105cb0>] do_IRQ+0x99/0xad
[1407075.519722]  [<c01040ef>] common_interrupt+0x23/0x28
[1407075.519722]  [<c01200d8>] sys_waitid+0x11/0x85
[1407075.519722]  [<c010260c>] default_idle+0x37/0x59
[1407075.519722]  [<c01025d5>] default_idle+0x0/0x59
[1407075.519722]  [<c010251f>] cpu_idle+0x6e/0x87
[1407075.519722]  =======================
[1407075.519722] Mem-info:
[1407075.519722] DMA per-cpu:
[1407075.519722] CPU    0: hi:    0, btch:   1 usd:   0
[1407075.519722] CPU    1: hi:    0, btch:   1 usd:   0
[1407075.519722] CPU    2: hi:    0, btch:   1 usd:   0
[1407075.519722] CPU    3: hi:    0, btch:   1 usd:   0
[1407075.519722] Normal per-cpu:
[1407075.519722] CPU    0: hi:  186, btch:  31 usd: 173
[1407075.519722] CPU    1: hi:  186, btch:  31 usd:  75
[1407075.519722] CPU    2: hi:  186, btch:  31 usd:  44
[1407075.519722] CPU    3: hi:  186, btch:  31 usd:  85
[1407075.519722] HighMem per-cpu:
[1407075.519722] CPU    0: hi:   42, btch:   7 usd:  39
[1407075.519722] CPU    1: hi:   42, btch:   7 usd:  36
[1407075.519722] CPU    2: hi:   42, btch:   7 usd:  20
[1407075.519722] CPU    3: hi:   42, btch:   7 usd:  21
[1407075.519722] Active:96553 inactive:148441 dirty:0 writeback:0 unstable:0
[1407075.519722]  free:3535 slab:6033 mapped:3064 pagetables:162 bounce:0
[1407075.519722] DMA free:3508kB min:64kB low:80kB high:96kB active:396kB
inactive:5812kB present:16176kB pages_scanned:0 all_unreclaimable? no
[1407075.519722] lowmem_reserve[]: 0 868 994 994
[1407075.519722] Normal free:10428kB min:3736kB low:4668kB high:5604kB
active:321452kB inactive:522780kB present:889680kB pages_scanned:96
all_unreclaimable? no
[1407075.519722] lowmem_reserve[]: 0 0 1008 1008
[1407075.519722] HighMem free:204kB min:128kB low:260kB high:396kB
active:64364kB inactive:65172kB present:129064kB pages_scanned:612
all_unreclaimable? no
[1407075.519722] lowmem_reserve[]: 0 0 0 0
[1407075.519722] DMA: 35*4kB 27*8kB 1*16kB 0*32kB 1*64kB 0*128kB 0*256kB
0*512kB 1*1024kB 1*2048kB 0*4096kB = 3508kB
[1407075.519722] Normal: 1621*4kB 211*8kB 133*16kB 0*32kB 1*64kB 0*128kB
0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 10364kB
[1407075.519722] HighMem: 13*4kB 3*8kB 2*16kB 1*32kB 1*64kB 0*128kB 0*256kB
0*512kB 0*1024kB 0*2048kB 0*4096kB = 204kB
[1407075.519722] 234421 total pagecache pages
[1407075.519722] Swap cache: add 0, delete 0, find 0/0
[1407075.519722] Free swap  = 0kB
[1407075.519722] Total swap = 0kB
[1407075.519722] Free swap:            0kB
[1407075.519722] 262056 pages of RAM
[1407075.519722] 32680 pages of HIGHMEM
[1407075.519722] 5048 reserved pages
[1407075.519722] 18954 pages shared
[1407075.519722] 0 pages swap cached
[1407075.519722] 0 pages dirty
[1407075.519722] 0 pages writeback
[1407075.519722] 3064 pages mapped
[1407075.519722] 6033 pages slab
[1407075.519722] 162 pages pagetables
[1407075.519722] swapper: page allocation failure. order:3, mode:0x4020
[1407075.519722] Pid: 0, comm: swapper Not tainted 2.6.25.4-devel2 #1
[1407075.519722]  [<c0144c09>] __alloc_pages+0x2a9/0x2bd
[1407075.519722]  [<c015a606>] __slab_alloc+0x14a/0x45e
[1407075.519722]  [<c015b4c9>] __kmalloc_track_caller+0x72/0xb9
[1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519722]  [<c030156c>] __alloc_skb+0x4d/0xf9
[1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519722]  [<f887f395>] bnx2_poll+0x58f/0xd0c [bnx2]
[1407075.519722]  [<c0307469>] net_rx_action+0xa4/0x1bf
[1407075.519722]  [<c01219fd>] __do_softirq+0x5d/0xc1
[1407075.519722]  [<c0105be4>] do_softirq+0x52/0x85
[1407075.519722]  [<c013ea70>] handle_edge_irq+0x0/0xff
[1407075.519722]  [<c012196e>] irq_exit+0x35/0x67
[1407075.519722]  [<c0105cb0>] do_IRQ+0x99/0xad
[1407075.519722]  [<c01040ef>] common_interrupt+0x23/0x28
[1407075.519722]  [<c01200d8>] sys_waitid+0x11/0x85
[1407075.519722]  [<c010260c>] default_idle+0x37/0x59
[1407075.519722]  [<c01025d5>] default_idle+0x0/0x59
[1407075.519722]  [<c010251f>] cpu_idle+0x6e/0x87
[1407075.519722]  =======================
[1407075.519722] Mem-info:
[1407075.519722] DMA per-cpu:
[1407075.519722] CPU    0: hi:    0, btch:   1 usd:   0
[1407075.519722] CPU    1: hi:    0, btch:   1 usd:   0
[1407075.519722] CPU    2: hi:    0, btch:   1 usd:   0
[1407075.519722] CPU    3: hi:    0, btch:   1 usd:   0
[1407075.519722] Normal per-cpu:
[1407075.519722] CPU    0: hi:  186, btch:  31 usd: 172
[1407075.519722] CPU    1: hi:  186, btch:  31 usd:  75
[1407075.519722] CPU    2: hi:  186, btch:  31 usd:  43
[1407075.519722] CPU    3: hi:  186, btch:  31 usd:  85
[1407075.519722] HighMem per-cpu:
[1407075.519722] CPU    0: hi:   42, btch:   7 usd:  39
[1407075.519722] CPU    1: hi:   42, btch:   7 usd:  36
[1407075.519722] CPU    2: hi:   42, btch:   7 usd:  20
[1407075.519722] CPU    3: hi:   42, btch:   7 usd:  21
[1407075.519722] Active:96553 inactive:148441 dirty:0 writeback:0 unstable:0
[1407075.519722]  free:3535 slab:6033 mapped:3064 pagetables:162 bounce:0
[1407075.519722] DMA free:3508kB min:64kB low:80kB high:96kB active:396kB
inactive:5812kB present:16176kB pages_scanned:0 all_unreclaimable? no
[1407075.519722] lowmem_reserve[]: 0 868 994 994
[1407075.519722] Normal free:10428kB min:3736kB low:4668kB high:5604kB
active:321452kB inactive:522780kB present:889680kB pages_scanned:96
all_unreclaimable? no
[1407075.519722] lowmem_reserve[]: 0 0 1008 1008
[1407075.519722] HighMem free:204kB min:128kB low:260kB high:396kB
active:64364kB inactive:65172kB present:129064kB pages_scanned:612
all_unreclaimable? no
[1407075.519722] lowmem_reserve[]: 0 0 0 0
[1407075.519722] DMA: 35*4kB 27*8kB 1*16kB 0*32kB 1*64kB 0*128kB 0*256kB
0*512kB 1*1024kB 1*2048kB 0*4096kB = 3508kB
[1407075.519722] Normal: 1621*4kB 211*8kB 133*16kB 0*32kB 1*64kB 0*128kB
0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 10364kB
[1407075.519722] HighMem: 13*4kB 3*8kB 2*16kB 1*32kB 1*64kB 0*128kB 0*256kB
0*512kB 0*1024kB 0*2048kB 0*4096kB = 204kB
[1407075.519722] 234458 total pagecache pages
[1407075.519722] Swap cache: add 0, delete 0, find 0/0
[1407075.519722] Free swap  = 0kB
[1407075.519722] Total swap = 0kB
[1407075.519722] Free swap:            0kB
[1407075.519722] 262056 pages of RAM
[1407075.519722] 32680 pages of HIGHMEM
[1407075.519722] 5048 reserved pages
[1407075.519722] 18956 pages shared
[1407075.519722] 0 pages swap cached
[1407075.519722] 0 pages dirty
[1407075.519722] 0 pages writeback
[1407075.519723] 3064 pages mapped
[1407075.519723] 6033 pages slab
[1407075.519723] 162 pages pagetables
[1407075.519723] swapper: page allocation failure. order:3, mode:0x4020
[1407075.519723] Pid: 0, comm: swapper Not tainted 2.6.25.4-devel2 #1
[1407075.519723]  [<c0144c09>] __alloc_pages+0x2a9/0x2bd
[1407075.519723]  [<c015a606>] __slab_alloc+0x14a/0x45e
[1407075.519723]  [<c015b4c9>] __kmalloc_track_caller+0x72/0xb9
[1407075.519723]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519723]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519723]  [<c030156c>] __alloc_skb+0x4d/0xf9
[1407075.519723]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519723]  [<f887f395>] bnx2_poll+0x58f/0xd0c [bnx2]
[1407075.519723]  [<c0307469>] net_rx_action+0xa4/0x1bf
[1407075.519723]  [<c01219fd>] __do_softirq+0x5d/0xc1
[1407075.519723]  [<c0105be4>] do_softirq+0x52/0x85
[1407075.519723]  [<c013ea70>] handle_edge_irq+0x0/0xff
[1407075.519723]  [<c012196e>] irq_exit+0x35/0x67
[1407075.519723]  [<c0105cb0>] do_IRQ+0x99/0xad
[1407075.519723]  [<c01040ef>] common_interrupt+0x23/0x28
[1407075.519723]  [<c01200d8>] sys_waitid+0x11/0x85
[1407075.519723]  [<c010260c>] default_idle+0x37/0x59
[1407075.519723]  [<c01025d5>] default_idle+0x0/0x59
[1407075.519723]  [<c010251f>] cpu_idle+0x6e/0x87
[1407075.519723]  =======================
[1407075.519723] Mem-info:
[1407075.519723] DMA per-cpu:
[1407075.519723] CPU    0: hi:    0, btch:   1 usd:   0
[1407075.519723] CPU    1: hi:    0, btch:   1 usd:   0
[1407075.519723] CPU    2: hi:    0, btch:   1 usd:   0
[1407075.519723] CPU    3: hi:    0, btch:   1 usd:   0
[1407075.519723] Normal per-cpu:
[1407075.519723] CPU    0: hi:  186, btch:  31 usd: 171
[1407075.519723] CPU    1: hi:  186, btch:  31 usd:  75
[1407075.519723] CPU    2: hi:  186, btch:  31 usd:  41
[1407075.519723] CPU    3: hi:  186, btch:  31 usd:  85
[1407075.519723] HighMem per-cpu:
[1407075.519723] CPU    0: hi:   42, btch:   7 usd:  39
[1407075.519723] CPU    1: hi:   42, btch:   7 usd:  36
[1407075.519723] CPU    2: hi:   42, btch:   7 usd:  20
[1407075.519723] CPU    3: hi:   42, btch:   7 usd:  21
[1407075.519723] Active:96553 inactive:148441 dirty:0 writeback:0 unstable:0
[1407075.519723]  free:3535 slab:6033 mapped:3064 pagetables:162 bounce:0
[1407075.519723] DMA free:3508kB min:64kB low:80kB high:96kB active:396kB
inactive:5812kB present:16176kB pages_scanned:0 all_unreclaimable? no
[1407075.519723] lowmem_reserve[]: 0 868 994 994
[1407075.519723] Normal free:10428kB min:3736kB low:4668kB high:5604kB
active:321452kB inactive:522780kB present:889680kB pages_scanned:96
all_unreclaimable? no
[1407075.519723] lowmem_reserve[]: 0 0 1008 1008
[1407075.519723] HighMem free:204kB min:128kB low:260kB high:396kB
active:64364kB inactive:65172kB present:129064kB pages_scanned:612
all_unreclaimable? no
[1407075.519723] lowmem_reserve[]: 0 0 0 0
[1407075.519723] DMA: 35*4kB 27*8kB 1*16kB 0*32kB 1*64kB 0*128kB 0*256kB
0*512kB 1*1024kB 1*2048kB 0*4096kB = 3508kB
[1407075.519723] Normal: 1621*4kB 211*8kB 133*16kB 0*32kB 1*64kB 0*128kB
0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 10364kB
[1407075.519723] HighMem: 13*4kB 3*8kB 2*16kB 1*32kB 1*64kB 0*128kB 0*256kB
0*512kB 0*1024kB 0*2048kB 0*4096kB = 204kB
[1407075.519723] 234458 total pagecache pages
[1407075.519723] Swap cache: add 0, delete 0, find 0/0
[1407075.519723] Free swap  = 0kB
[1407075.519723] Total swap = 0kB
[1407075.519723] Free swap:            0kB
[1407075.519723] 262056 pages of RAM
[1407075.519723] 32680 pages of HIGHMEM
[1407075.519723] 5048 reserved pages
[1407075.519723] 18946 pages shared
[1407075.519723] 0 pages swap cached
[1407075.519723] 0 pages dirty
[1407075.519723] 0 pages writeback
[1407075.519723] 3064 pages mapped
[1407075.519723] 6033 pages slab
[1407075.519723] 162 pages pagetables
[1407075.519723] swapper: page allocation failure. order:3, mode:0x4020
[1407075.519723] Pid: 0, comm: swapper Not tainted 2.6.25.4-devel2 #1
[1407075.519723]  [<c0144c09>] __alloc_pages+0x2a9/0x2bd
[1407075.519723]  [<c015a606>] __slab_alloc+0x14a/0x45e
[1407075.519723]  [<c015b4c9>] __kmalloc_track_caller+0x72/0xb9
[1407075.519723]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519723]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519723]  [<c030156c>] __alloc_skb+0x4d/0xf9
[1407075.519723]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
[1407075.519723]  [<f887f395>] bnx2_poll+0x58f/0xd0c [bnx2]
[1407075.519723]  [<c0307469>] net_rx_action+0xa4/0x1bf
[1407075.519723]  [<c01219fd>] __do_softirq+0x5d/0xc1
[1407075.519723]  [<c0105be4>] do_softirq+0x52/0x85
[1407075.519723]  [<c013ea70>] handle_edge_irq+0x0/0xff
[1407075.519723]  [<c012196e>] irq_exit+0x35/0x67
[1407075.519723]  [<c0105cb0>] do_IRQ+0x99/0xad
[1407075.519723]  [<c01040ef>] common_interrupt+0x23/0x28
[1407075.519723]  [<c01200d8>] sys_waitid+0x11/0x85
[1407075.519723]  [<c010260c>] default_idle+0x37/0x59
[1407075.519723]  [<c01025d5>] default_idle+0x0/0x59
[1407075.519723]  [<c010251f>] cpu_idle+0x6e/0x87
[1407075.519723]  =======================
[1407075.519723] Mem-info:
[1407075.519723] DMA per-cpu:
[1407075.519723] CPU    0: hi:    0, btch:   1 usd:   0
[1407075.519723] CPU    1: hi:    0, btch:   1 usd:   0
[1407075.519723] CPU    2: hi:    0, btch:   1 usd:   0
[1407075.519723] CPU    3: hi:    0, btch:   1 usd:   0
[1407075.519723] Normal per-cpu:
[1407075.519723] CPU    0: hi:  186, btch:  31 usd: 170
[1407075.519723] CPU    1: hi:  186, btch:  31 usd:  75
[1407075.519723] CPU    2: hi:  186, btch:  31 usd:  40
[1407075.519723] CPU    3: hi:  186, btch:  31 usd:  85
[1407075.519723] HighMem per-cpu:
[1407075.519723] CPU    0: hi:   42, btch:   7 usd:  39
[1407075.519723] CPU    1: hi:   42, btch:   7 usd:  36
[1407075.519723] CPU    2: hi:   42, btch:   7 usd:  20
[1407075.519723] CPU    3: hi:   42, btch:   7 usd:  21
[1407075.519723] Active:96553 inactive:148441 dirty:0 writeback:0 unstable:0
[1407075.519723]  free:3535 slab:6033 mapped:3064 pagetables:162 bounce:0
[1407075.519723] DMA free:3508kB min:64kB low:80kB high:96kB active:396kB
inactive:5812kB present:16176kB pages_scanned:0 all_unreclaimable? no
[1407075.519723] lowmem_reserve[]: 0 868 994 994
[1407075.519723] Normal free:10428kB min:3736kB low:4668kB high:5604kB
active:321452kB inactive:522780kB present:889680kB pages_scanned:96
all_unreclaimable? no
[1407075.519723] lowmem_reserve[]: 0 0 1008 1008
[1407075.519723] HighMem free:204kB min:128kB low:260kB high:396kB
active:64364kB inactive:65172kB present:129064kB pages_scanned:612
all_unreclaimable? no
[1407075.519723] lowmem_reserve[]: 0 0 0 0
[1407075.519723] DMA: 35*4kB 27*8kB 1*16kB 0*32kB 1*64kB 0*128kB 0*256kB
0*512kB 1*1024kB 1*2048kB 0*4096kB = 3508kB
[1407075.519723] Normal: 1621*4kB 211*8kB 133*16kB 0*32kB 1*64kB 0*128kB
0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 10364kB
[1407075.519723] HighMem: 13*4kB 3*8kB 2*16kB 1*32kB 1*64kB 0*128kB 0*256kB
0*512kB 0*1024kB 0*2048kB 0*4096kB = 204kB
[1407075.519723] 234458 total pagecache pages
[1407075.519723] Swap cache: add 0, delete 0, find 0/0
[1407075.519723] Free swap  = 0kB
[1407075.519723] Total swap = 0kB
[1407075.519723] Free swap:            0kB
[1407075.519723] 262056 pages of RAM
[1407075.519723] 32680 pages of HIGHMEM
[1407075.519723] 5048 reserved pages
[1407075.519723] 18948 pages shared
[1407075.519723] 0 pages swap cached
[1407075.519723] 0 pages dirty
[1407075.519723] 0 pages writeback
[1407075.519723] 3064 pages mapped
[1407075.519723] 6033 pages slab
[1407075.519723] 162 pages pagetables


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

