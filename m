From: "Jon Nelson" <jnelson-linux-raid@jamponi.net>
Subject: Stack Trace. Bad?
Date: Tue, 6 Nov 2007 14:22:30 -0600
Message-ID: <cccedfc60711061222o6c4599fcyf71265c126568395@mail.gmail.com>
References: <cccedfc60711061136r5ec89e73m7457e9fea0bf4f55@mail.gmail.com>
	 <cccedfc60711061139r11a5e8c6raf6cd64c575ec453@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:55233 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754314AbXKFUWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 15:22:34 -0500
Received: by nf-out-0910.google.com with SMTP id g13so1790967nfb
        for <netdev@vger.kernel.org>; Tue, 06 Nov 2007 12:22:31 -0800 (PST)
In-Reply-To: <cccedfc60711061139r11a5e8c6raf6cd64c575ec453@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[linux-raid was also emailed this same information]

I was testing some network throughput today and ran into this.
I should note that I've this motherboard has 2x MCP55 Ethernet and one
of them works fine and the other one gives lots and lots of frame
errors under load.

The following is only an harmless informational message.
Unless you get a _continuous_flood_ of these messages it means
everything is working fine. Allocations from irqs cannot be
perfectly reliable and the kernel is designed to handle that.
md0_raid5: page allocation failure. order:2, mode:0x20

Call Trace:
 <IRQ>  [<ffffffff802684c2>] __alloc_pages+0x324/0x33d
 [<ffffffff80283147>] kmem_getpages+0x66/0x116
 [<ffffffff8028367a>] fallback_alloc+0x104/0x174
 [<ffffffff80283330>] kmem_cache_alloc_node+0x9c/0xa8
 [<ffffffff80396984>] __alloc_skb+0x65/0x138
 [<ffffffff8821d82a>] :forcedeth:nv_alloc_rx_optimized+0x4d/0x18f
 [<ffffffff88220fca>] :forcedeth:nv_napi_poll+0x61f/0x71c
 [<ffffffff8039ce93>] net_rx_action+0xb2/0x1c5
 [<ffffffff8023625e>] __do_softirq+0x65/0xce
 [<ffffffff8020adbc>] call_softirq+0x1c/0x28
 [<ffffffff8020bef5>] do_softirq+0x2c/0x7d
 [<ffffffff8020c180>] do_IRQ+0xb6/0xd6
 [<ffffffff8020a141>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff80265d8e>] mempool_free_slab+0x0/0xe
 [<ffffffff803fac0b>] _spin_unlock_irqrestore+0x8/0x9
 [<ffffffff803892d8>] bitmap_daemon_work+0xee/0x2f3
 [<ffffffff80386571>] md_check_recovery+0x22/0x4b9
 [<ffffffff88118e10>] :raid456:raid5d+0x1b/0x3a2
 [<ffffffff8023978b>] del_timer_sync+0xc/0x16
 [<ffffffff803f98db>] schedule_timeout+0x92/0xad
 [<ffffffff80239612>] process_timeout+0x0/0x5
 [<ffffffff803f98ce>] schedule_timeout+0x85/0xad
 [<ffffffff80387e62>] md_thread+0xf2/0x10e
 [<ffffffff80243353>] autoremove_wake_function+0x0/0x2e
 [<ffffffff80387d70>] md_thread+0x0/0x10e
 [<ffffffff8024322c>] kthread+0x47/0x73
 [<ffffffff8020aa48>] child_rip+0xa/0x12
 [<ffffffff802431e5>] kthread+0x0/0x73
 [<ffffffff8020aa3e>] child_rip+0x0/0x12

Mem-info:
Node 0 DMA per-cpu:
CPU    0: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd:   0
CPU    1: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd:   0
Node 0 DMA32 per-cpu:
CPU    0: Hot: hi:  186, btch:  31 usd: 115   Cold: hi:   62, btch:  15 usd:  31
CPU    1: Hot: hi:  186, btch:  31 usd: 128   Cold: hi:   62, btch:  15 usd:  56
Active:111696 inactive:116497 dirty:31 writeback:0 unstable:0
 free:1850 slab:19676 mapped:3608 pagetables:1217 bounce:0
Node 0 DMA free:3988kB min:40kB low:48kB high:60kB active:232kB
inactive:5496kB present:10692kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 994 994
Node 0 DMA32 free:3412kB min:4012kB low:5012kB high:6016kB
active:446552kB inactive:460492kB present:1018020kB pages_scanned:0
all_unreclaimable? no
lowmem_reserve[]: 0 0 0
Node 0 DMA: 29*4kB 2*8kB 1*16kB 0*32kB 0*64kB 0*128kB 1*256kB 1*512kB
1*1024kB 1*2048kB 0*4096kB = 3988kB
Node 0 DMA32: 419*4kB 147*8kB 19*16kB 0*32kB 1*64kB 0*128kB 1*256kB
0*512kB 0*1024kB 0*2048kB 0*4096kB = 3476kB
Swap cache: add 57, delete 57, find 0/0, race 0+0
Free swap  = 979608kB
Total swap = 979832kB
 Free swap:       979608kB
262128 pages of RAM
4938 reserved pages
108367 pages shared
0 pages swap cached


--
Jon
