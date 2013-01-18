From: Dirk Hohndel <dirk@hohndel.org>
Subject: surprising memory request
Date: Fri, 18 Jan 2013 08:58:18 -0800 (PST)
Message-ID: <20130118085818.147220.FMU5901@air.gr8dns.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Woodhouse <dwmw2@infradead.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.hohndel.org ([198.145.64.135]:50032 "EHLO mail.hohndel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752466Ab3ARRHc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2013 12:07:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Running openconnect on a very recent 3.8 (a few commits before Linus cut
RC4) I get this allocation failure. I'm unclear why we would need 128
contiguous pages here...

/D

[66015.673818] openconnect: page allocation failure: order:7, mode:0x10c0d0
[66015.673827] Pid: 3292, comm: openconnect Tainted: G        W    3.8.0-rc3-00352-gdfdebc2 #94
[66015.673830] Call Trace:
[66015.673841]  [<ffffffff810e9c29>] warn_alloc_failed+0xe9/0x140
[66015.673849]  [<ffffffff81093967>] ? on_each_cpu_mask+0x87/0xa0
[66015.673854]  [<ffffffff810ec349>] __alloc_pages_nodemask+0x579/0x720
[66015.673859]  [<ffffffff810ec507>] __get_free_pages+0x17/0x50
[66015.673866]  [<ffffffff81123979>] kmalloc_order_trace+0x39/0xf0
[66015.673874]  [<ffffffff81666178>] ? __hw_addr_add_ex+0x78/0xc0
[66015.673879]  [<ffffffff811260d8>] __kmalloc+0xc8/0x180
[66015.673883]  [<ffffffff81666616>] ? dev_addr_init+0x66/0x90
[66015.673889]  [<ffffffff81660985>] alloc_netdev_mqs+0x145/0x300
[66015.673896]  [<ffffffff81513830>] ? tun_net_fix_features+0x20/0x20
[66015.673902]  [<ffffffff815168aa>] __tun_chr_ioctl+0xd0a/0xec0
[66015.673908]  [<ffffffff81516a93>] tun_chr_ioctl+0x13/0x20
[66015.673913]  [<ffffffff8113b197>] do_vfs_ioctl+0x97/0x530
[66015.673917]  [<ffffffff811256f3>] ? kmem_cache_free+0x33/0x170
[66015.673923]  [<ffffffff81134896>] ? final_putname+0x26/0x50
[66015.673927]  [<ffffffff8113b6c1>] sys_ioctl+0x91/0xb0
[66015.673935]  [<ffffffff8180e3d2>] system_call_fastpath+0x16/0x1b
[66015.673938] Mem-Info:
[66015.673940] DMA per-cpu:
[66015.673943] CPU    0: hi:    0, btch:   1 usd:   0
[66015.673945] CPU    1: hi:    0, btch:   1 usd:   0
[66015.673947] CPU    2: hi:    0, btch:   1 usd:   0
[66015.673949] CPU    3: hi:    0, btch:   1 usd:   0
[66015.673951] DMA32 per-cpu:
[66015.673953] CPU    0: hi:  186, btch:  31 usd:   0
[66015.673956] CPU    1: hi:  186, btch:  31 usd:  42
[66015.673958] CPU    2: hi:  186, btch:  31 usd:   0
[66015.673960] CPU    3: hi:  186, btch:  31 usd:   0
[66015.673962] Normal per-cpu:
[66015.673964] CPU    0: hi:  186, btch:  31 usd:   0
[66015.673966] CPU    1: hi:  186, btch:  31 usd:  46
[66015.673968] CPU    2: hi:  186, btch:  31 usd:   0
[66015.673970] CPU    3: hi:  186, btch:  31 usd:   0
[66015.673976] active_anon:1241168 inactive_anon:243402 isolated_anon:0
[66015.673976]  active_file:171470 inactive_file:184344 isolated_file:0
[66015.673976]  unevictable:41 dirty:2 writeback:0 unstable:0
[66015.673976]  free:84294 slab_reclaimable:45897 slab_unreclaimable:8765
[66015.673976]  mapped:37635 shmem:185852 pagetables:18316 bounce:0
[66015.673976]  free_cma:0
[66015.673987] DMA free:15900kB min:20kB low:24kB high:28kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15644kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[66015.673989] lowmem_reserve[]: 0 2138 7924 7924
[66015.674001] DMA32 free:308944kB min:3068kB low:3832kB high:4600kB active_anon:789936kB inactive_anon:270492kB active_file:302520kB inactive_file:346788kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2190060kB managed:2136000kB mlocked:0kB dirty:0kB writeback:0kB mapped:36180kB shmem:227796kB slab_reclaimable:111048kB slab_unreclaimable:2632kB kernel_stack:376kB pagetables:6084kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:21 all_unreclaimable? no
[66015.674004] lowmem_reserve[]: 0 0 5786 5786
[66015.674014] Normal free:12332kB min:8308kB low:10384kB high:12460kB active_anon:4174736kB inactive_anon:703116kB active_file:383360kB inactive_file:390588kB unevictable:164kB isolated(anon):0kB isolated(file):0kB present:5925024kB managed:5874208kB mlocked:164kB dirty:8kB writeback:0kB mapped:114360kB shmem:515612kB slab_reclaimable:72540kB slab_unreclaimable:32428kB kernel_stack:4264kB pagetables:67180kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:46 all_unreclaimable? no
[66015.674016] lowmem_reserve[]: 0 0 0 0
[66015.674021] DMA: 1*4kB (U) 1*8kB (U) 1*16kB (U) 2*32kB (U) 1*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15900kB
[66015.674040] DMA32: 4730*4kB (UEM) 14656*8kB (UEM) 6007*16kB (UEM) 1577*32kB (UEMR) 269*64kB (UEMR) 68*128kB (UEMR) 2*256kB (M) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 309176kB
[66015.674057] Normal: 2772*4kB (UEM) 44*8kB (UEM) 17*16kB (UEM) 6*32kB (R) 1*64kB (R) 0*128kB 1*256kB (R) 1*512kB (R) 0*1024kB 0*2048kB 0*4096kB = 12736kB
[66015.674074] 541777 total pagecache pages
[66015.674075] 142 pages in swap cache
[66015.674078] Swap cache stats: add 4420, delete 4278, find 106/118
[66015.674080] Free swap  = 9197216kB
[66015.674082] Total swap = 9213948kB
[66015.710738] 2094576 pages RAM
[66015.710745] 85536 pages reserved
[66015.710746] 1755663 pages shared
[66015.710748] 1488520 pages non-shared
[66015.710752] netdev: Unable to allocate 1024 tx queues


-- 
Dirk Hohndel
Intel Open Source Technology Center
