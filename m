From: "Jon Nelson" <jnelson@jamponi.net>
Subject: Re: request: via velocity and tg3 help
Date: Wed, 16 Jul 2008 16:35:15 -0500
Message-ID: <cccedfc60807161435t54ff2559n9bd2b2b5217870ba@mail.gmail.com>
References: <cccedfc60807151733n1c204c73ya4878bc03cba2e26@mail.gmail.com>
	 <20080716211030.GA27803@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:56704 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756171AbYGPVfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 17:35:17 -0400
Received: by fg-out-1718.google.com with SMTP id 19so2514267fgg.17
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2008 14:35:15 -0700 (PDT)
In-Reply-To: <20080716211030.GA27803@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 16, 2008 at 4:10 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Jon Nelson <jnelson@jamponi.net> :
>> I have a pair (each) of VIA Velocity and Broadcom (Altima) gig-e NICs.
>> They've never worked worth a damn. Only with 2.6.25.5 (and later) does
>> the VIA not kernel oops on boot, but neither one of them works
>> correctly, and things go downhill even faster when jumbo frames get
>> involved. They are both OK in 100-mbit, but in gig-e nearly useless. I
>> am willing to personally ship one or both cards to parties interested
>> in making them work better. I also have a single RTL8169-based card
>> which works OK but not great, and I may be willing to do the same
>> there. The only gig-e NICs I have are NVidia (Marvell) MCP55 which, at
>> least as of 2.6.25.9, work great - I'm easily able to sustain 112MB/s
>> with 1500byte frames and a non-jumbo-frame capable Intel NIC.
>
> Can you redirect to netdev@vger.kernel.org and describe more specifically
> in what way the r8169 does not match your expectations ? Memory allocation
> failures with jumbo frames ?

First, let me preface things by saying that I've personally had great
experiences dealing with the linux kernel developers and others - do
not let my grumpiness regarding my marginally-working hardware detract
from that.  With that out of the way:

The RTL8169 I have (I only have one) works fine when not under load.
The last time I did extensive tests was with 2.6.22.18 and at that
time it did not work properly, hanging or getting really /really/
slow. In the last 15 minutes, I re-tested using 2.6.25.9 and the
RTL8169 seems fine, if not stellar:

With 1500 byte mtu, a quick test shows sending at 75MB/s and receiving
at 46MB/s.
With 7200 byte mtu, sending drops to 63MB/s but receiving up to 75MB/s.

This is on a POS Pentium III (thus, 32bit, 33MHz PCI) running at 933 MHz.

The server (turnip) is an AMD x86-64 3600+ with dual Marvell MCP55
(NForce 5).  The server is able to supply another client (with
non-jumbo-frame-capable Intel gig-e) at 112MB/s, but that client has a
rather beefier CPU.

I'll note that I still get these (first one since the upgrade to
2.6.25.9) on my:

Jul 16 16:26:08 turnip kernel: The following is only an harmless
informational message.
Jul 16 16:26:08 turnip kernel: Unless you get a _continuous_flood_ of
these messages it means
Jul 16 16:26:08 turnip kernel: everything is working fine. Allocations
from irqs cannot be
Jul 16 16:26:08 turnip kernel: perfectly reliable and the kernel is
designed to handle that.
Jul 16 16:26:08 turnip kernel: kswapd0: page allocation failure.
order:2, mode:0x20
Jul 16 16:26:08 turnip kernel: Pid: 20, comm: kswapd0 Tainted: G
AN 2.6.25.9-0.2-default #1
Jul 16 16:26:08 turnip kernel:
Jul 16 16:26:08 turnip kernel: Call Trace:
Jul 16 16:26:08 turnip kernel:  [<ffffffff8020d696>] dump_trace+0xc4/0x576
Jul 16 16:26:08 turnip kernel:  [<ffffffff8020db88>] show_trace+0x40/0x57
Jul 16 16:26:08 turnip kernel:  [<ffffffff8044f845>] _etext+0x72/0x7b
Jul 16 16:26:08 turnip kernel:  [<ffffffff8027a72a>] __alloc_pages+0x370/0x392
Jul 16 16:26:08 turnip kernel:  [<ffffffff8029a21f>] kmem_getpages+0xd2/0x1a0
Jul 16 16:26:08 turnip kernel:  [<ffffffff8029ab38>] fallback_alloc+0x134/0x1b9
Jul 16 16:26:08 turnip kernel:  [<ffffffff8029a9f5>]
____cache_alloc_node+0x11d/0x12c
Jul 16 16:26:08 turnip kernel:  [<ffffffff8029a3fd>]
kmem_cache_alloc_node+0x110/0x144
Jul 16 16:26:08 turnip kernel:  [<ffffffff8029adc9>] __kmalloc_node+0x43/0x45
Jul 16 16:26:08 turnip kernel:  [<ffffffff803cf6db>] __alloc_skb+0x6b/0x131
Jul 16 16:26:08 turnip kernel:  [<ffffffff881dfc6f>]
:forcedeth:nv_alloc_rx_optimized+0x59/0x1be
Jul 16 16:26:08 turnip kernel:  [<ffffffff881e551a>]
:forcedeth:nv_napi_poll+0x5ea/0x6d8
Jul 16 16:26:08 turnip kernel:  [<ffffffff803d2f21>] net_rx_action+0xba/0x1fc
Jul 16 16:26:08 turnip kernel:  [<ffffffff8023ca76>] __do_softirq+0x6d/0xe1
Jul 16 16:26:08 turnip kernel:  [<ffffffff8020d40c>] call_softirq+0x1c/0x28
Jul 16 16:26:08 turnip kernel: DWARF2 unwinder stuck at call_softirq+0x1c/0x28
Jul 16 16:26:08 turnip kernel:
Jul 16 16:26:08 turnip kernel: Leftover inexact backtrace:
Jul 16 16:26:08 turnip kernel:
Jul 16 16:26:08 turnip kernel:  <IRQ>  [<ffffffff8020e95c>] ?
do_softirq+0x44/0x8b
Jul 16 16:26:08 turnip kernel:  [<ffffffff8023c847>] ? irq_exit+0x3f/0x80
Jul 16 16:26:08 turnip kernel:  [<ffffffff8020ec13>] ? do_IRQ+0xba/0xd8
Jul 16 16:26:08 turnip kernel:  [<ffffffff8020c5ad>] ? ret_from_intr+0x0/0x19
Jul 16 16:26:08 turnip kernel:  <EOI>  [<ffffffff8027e2bf>] ?
shrink_page_list+0x89/0x5b4
Jul 16 16:26:08 turnip kernel:  [<ffffffff8027e245>] ?
shrink_page_list+0xf/0x5b4
Jul 16 16:26:08 turnip kernel:  [<ffffffff8027e979>] ?
shrink_inactive_list+0x18f/0x452
Jul 16 16:26:08 turnip kernel:  [<ffffffff80449366>] ?
_spin_unlock_irqrestore+0xb/0x13
Jul 16 16:26:08 turnip kernel:  [<ffffffff8027ed18>] ? shrink_zone+0xdc/0x100
Jul 16 16:26:08 turnip kernel:  [<ffffffff8027f594>] ? kswapd+0x430/0x5c1
Jul 16 16:26:08 turnip kernel:  [<ffffffff8027db12>] ?
isolate_pages_global+0x0/0x34
Jul 16 16:26:08 turnip kernel:  [<ffffffff8024a5bf>] ?
autoremove_wake_function+0x0/0x38
Jul 16 16:26:08 turnip kernel:  [<ffffffff8022a5b9>] ?
__wake_up_common+0x46/0x75
Jul 16 16:26:08 turnip kernel:  [<ffffffff8027f164>] ? kswapd+0x0/0x5c1
Jul 16 16:26:08 turnip kernel:  [<ffffffff8024a269>] ? kthread+0x49/0x76
Jul 16 16:26:08 turnip kernel:  [<ffffffff8020d068>] ? child_rip+0xa/0x12
Jul 16 16:26:08 turnip kernel:  [<ffffffff8024a220>] ? kthread+0x0/0x76
Jul 16 16:26:08 turnip kernel:  [<ffffffff8020d05e>] ? child_rip+0x0/0x12
Jul 16 16:26:08 turnip kernel:
Jul 16 16:26:08 turnip kernel: Mem-info:
Jul 16 16:26:08 turnip kernel: Node 0 DMA per-cpu:
Jul 16 16:26:08 turnip kernel: CPU    0: hi:    0, btch:   1 usd:   0
Jul 16 16:26:08 turnip kernel: CPU    1: hi:    0, btch:   1 usd:   0
Jul 16 16:26:08 turnip kernel: Node 0 DMA32 per-cpu:
Jul 16 16:26:08 turnip kernel: CPU    0: hi:  186, btch:  31 usd: 166
Jul 16 16:26:08 turnip kernel: CPU    1: hi:  186, btch:  31 usd: 170
Jul 16 16:26:08 turnip kernel: Active:26327 inactive:199891 dirty:18
writeback:0 unstable:0
Jul 16 16:26:08 turnip kernel:  free:2809 slab:19234 mapped:4141
pagetables:1211 bounce:0
Jul 16 16:26:08 turnip kernel: Node 0 DMA free:3980kB min:32kB
low:40kB high:48kB active:32kB inactive:4288kB present:8868kB
pages_scanned:0 all_unreclaimable? no
Jul 16 16:26:08 turnip kernel: lowmem_reserve[]: 0 994 994 994
Jul 16 16:26:08 turnip kernel: Node 0 DMA32 free:7256kB min:4016kB
low:5020kB high:6024kB active:105276kB inactive:795276kB
present:1018020kB pages_scanned:32 all_unreclaimable? no
Jul 16 16:26:08 turnip kernel: lowmem_reserve[]: 0 0 0 0
Jul 16 16:26:08 turnip kernel: Node 0 DMA: 75*4kB 84*8kB 60*16kB
0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB =
3980kB
Jul 16 16:26:08 turnip kernel: Node 0 DMA32: 1142*4kB 292*8kB 0*16kB
1*32kB 1*64kB 0*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =
7256kB
Jul 16 16:26:08 turnip kernel: 209322 total pagecache pages
Jul 16 16:26:08 turnip kernel: Swap cache: add 690, delete 682, find 134/269
Jul 16 16:26:08 turnip kernel: Free swap  = 979524kB
Jul 16 16:26:08 turnip kernel: Total swap = 979832kB
Jul 16 16:26:08 turnip kernel: Free swap:       979524kB
Jul 16 16:26:08 turnip kernel: 262128 pages of RAM
Jul 16 16:26:08 turnip kernel: 5383 reserved pages
Jul 16 16:26:08 turnip kernel: 139139 pages shared
Jul 16 16:26:08 turnip kernel: 8 pages swap cached


With prior kernels (incl. 2.6.25.5) I got those messages VERY
frequently under high load.

-- 
Jon
