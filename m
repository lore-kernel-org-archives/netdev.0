From: Marc MERLIN <marc-xnduUnryOU1AfugRpC6u6w@public.gmane.org>
Subject: Re: kernel 3.5.2/amd64: iwlwifi 0000:03:00.0: failed to allocate pci memory
Date: Sat, 8 Sep 2012 10:01:28 -0700
Message-ID: <20120908170128.GK3347@merlins.org>
References: <20120908161038.GF3347@merlins.org> <1347122927.1234.849.camel@edumazet-glaptop> <20120904003014.GB6287@merlins.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-q7rQbLoQdy39qxiX1TGQuw@public.gmane.org
To: johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1347122927.1234.849.camel@edumazet-glaptop> <20120904003014.GB6287-xnduUnryOU1AfugRpC6u6w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Howdy,

I currently rmmod iwlwifi before putting my laptop to sleep and reload it 
when coming back. Arguably, it's maybe not needed, but from time to time
I hit this memory allocation failure below.

I realize it's likely a memory fragmentation problem, but I have 8GB and
plenty of 'free' space, so I'm hoping that somehow it can be defragmented
enough for module loading ot work?

My kenrel config options are here
http://marc.merlins.org/tmp/config-3.5.2-amd64-preempt-noide-20120731

and this happens on an Lenovo T530

when it works:
[   13.494270] iwlwifi 0000:03:00.0: loaded firmware version 9.221.4.1 build 25532
[   13.494440] iwlwifi 0000:03:00.0: Detected Intel(R) Centrino(R) Ultimate-N 6300 AGN, REV=0x74

When it doesn't:
[856806.443647] cfg80211: Calling CRDA to update world regulatory domain
[856806.448428] iwlwifi: Intel(R) Wireless WiFi Link AGN driver for Linux, in-tree:d
[856806.448431] iwlwifi: Copyright(c) 2003-2012 Intel Corporation
[856806.448929] cfg80211: World regulatory domain updated:
[856806.448931] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[856806.448933] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[856806.448941] cfg80211:   (2457000 KHz - 2482000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[856806.448942] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[856806.448943] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[856806.448945] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[856806.483929] iwlwifi 0000:03:00.0: pci_resource_len = 0x00002000
[856806.483932] iwlwifi 0000:03:00.0: pci_resource_base = ffffc900057bc000
[856806.483933] iwlwifi 0000:03:00.0: HW Revision ID = 0x3E
[856806.484004] iwlwifi 0000:03:00.0: irq 46 for MSI/MSI-X
[856806.497476] iwlwifi 0000:03:00.0: loaded firmware version 9.221.4.1 build 25532
[856806.497944] kworker/3:0: page allocation failure: order:5, mode:0xd0
[856806.497948] Pid: 17936, comm: kworker/3:0 Tainted: G        W  O 3.5.2-amd64-preempt-noide-20120731 #1
[856806.497949] Call Trace:
[856806.497959]  [<ffffffff810cf54c>] warn_alloc_failed+0x117/0x12c
[856806.497963]  [<ffffffff810d23af>] __alloc_pages_nodemask+0x6e3/0x792
[856806.497969]  [<ffffffff812b7f41>] ? pfn_to_dma_pte+0x116/0x15e
[856806.497976]  [<ffffffff810ff58b>] alloc_pages_current+0xcd/0xee
[856806.497979]  [<ffffffff810cecca>] __get_free_pages+0x9/0x45
[856806.497982]  [<ffffffff812ba67d>] intel_alloc_coherent+0x84/0xe7
[856806.497986]  [<ffffffff81085cf8>] ? arch_local_irq_save+0x15/0x1b
[856806.497999]  [<ffffffffa0b84afc>] iwl_ucode_callback+0xa49/0xc0d [iwlwifi]
[856806.498006]  [<ffffffff8128f100>] ? _request_firmware_prepare.isra.5+0x1bf/0x1bf
[856806.498010]  [<ffffffff8128f181>] request_firmware_work_func+0x81/0xb1
[856806.498014]  [<ffffffff81054b13>] process_one_work+0x16f/0x28e
[856806.498018]  [<ffffffff810555d5>] worker_thread+0xce/0x152
[856806.498021]  [<ffffffff81055507>] ? manage_workers.isra.24+0x16c/0x16c
[856806.498024]  [<ffffffff81058e3c>] kthread+0x86/0x8e
[856806.498029]  [<ffffffff813a0aa4>] kernel_thread_helper+0x4/0x10
[856806.498032]  [<ffffffff81058db6>] ? kthread_freezable_should_stop+0x3e/0x3e
[856806.498034]  [<ffffffff813a0aa0>] ? gs_change+0x13/0x13
[856806.498036] Mem-Info:
[856806.498037] Node 0 DMA per-cpu:
[856806.498039] CPU    0: hi:    0, btch:   1 usd:   0
[856806.498041] CPU    1: hi:    0, btch:   1 usd:   0
[856806.498042] CPU    2: hi:    0, btch:   1 usd:   0
[856806.498044] CPU    3: hi:    0, btch:   1 usd:   0
[856806.498045] Node 0 DMA32 per-cpu:
[856806.498047] CPU    0: hi:  186, btch:  31 usd:   0
[856806.498048] CPU    1: hi:  186, btch:  31 usd:   0
[856806.498050] CPU    2: hi:  186, btch:  31 usd:   0
[856806.498051] CPU    3: hi:  186, btch:  31 usd:   0
[856806.498052] Node 0 Normal per-cpu:
[856806.498054] CPU    0: hi:  186, btch:  31 usd:   0
[856806.498055] CPU    1: hi:  186, btch:  31 usd:   0
[856806.498057] CPU    2: hi:  186, btch:  31 usd:   0
[856806.498058] CPU    3: hi:  186, btch:  31 usd:   0
[856806.498062] active_anon:880341 inactive_anon:274439 isolated_anon:0
[856806.498062]  active_file:222778 inactive_file:228271 isolated_file:0
[856806.498062]  unevictable:1436 dirty:369 writeback:0 unstable:0
[856806.498062]  free:137592 slab_reclaimable:167927 slab_unreclaimable:17618
[856806.498062]  mapped:27053 shmem:29116 pagetables:23832 bounce:0
[856806.498065] Node 0 DMA free:15900kB min:132kB low:164kB high:196kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15676kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[856806.498071] lowmem_reserve[]: 0 3257 7777 7777
[856806.498074] Node 0 DMA32 free:454560kB min:28252kB low:35312kB high:42376kB active_anon:1412512kB inactive_anon:513084kB active_file:333072kB inactive_file:323580kB unevictable:196kB isolated(anon):0kB isolated(file):0kB present:3335900kB mlocked:196kB dirty:108kB writeback:0kB mapped:43284kB shmem:27472kB slab_reclaimable:281024kB slab_unreclaimable:20952kB kernel_stack:4200kB pagetables:27640kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[856806.498079] lowmem_reserve[]: 0 0 4519 4519
[856806.498083] Node 0 Normal free:79908kB min:39196kB low:48992kB high:58792kB active_anon:2108852kB inactive_anon:584672kB active_file:558040kB inactive_file:589504kB unevictable:5548kB isolated(anon):0kB isolated(file):0kB present:4627820kB mlocked:5548kB dirty:1368kB writeback:0kB mapped:64928kB shmem:88992kB slab_reclaimable:390684kB slab_unreclaimable:49520kB kernel_stack:3496kB pagetables:67688kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[856806.498088] lowmem_reserve[]: 0 0 0 0
[856806.498090] Node 0 DMA: 1*4kB 1*8kB 1*16kB 0*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15900kB
[856806.498098] Node 0 DMA32: 60562*4kB 25568*8kB 264*16kB 4*32kB 1*64kB 1*128kB 0*256kB 2*512kB 2*1024kB 0*2048kB 0*4096kB = 454408kB
[856806.498106] Node 0 Normal: 15497*4kB 861*8kB 162*16kB 79*32kB 22*64kB 4*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 80012kB
[856806.498115] 660922 total pagecache pages
[856806.498116] 180029 pages in swap cache
[856806.498118] Swap cache stats: add 7904087, delete 7724058, find 2010810/2392461
[856806.498119] Free swap  = 5831292kB
[856806.498121] Total swap = 10485756kB
[856806.520762] 2057712 pages RAM
[856806.520764] 63301 pages reserved
[856806.520765] 543630 pages shared
[856806.520766] 1544767 pages non-shared
[856806.520771] iwlwifi 0000:03:00.0: failed to allocate pci memory

It will typically fix itself and work again later.

Any ideas?

Thanks,
Marc
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
