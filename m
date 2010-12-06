From: Frederik Himpe <fhimpe@telenet.be>
Subject: 2.6.32 bnx2: unable to handle kernel NULL pointer dereference at
 (null) on OOM
Date: Mon, 6 Dec 2010 11:06:31 +0000 (UTC)
Message-ID: <idig3m$uo7$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:48502 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750985Ab0LFLGs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Dec 2010 06:06:48 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1PPYu6-00081D-O4
	for netdev@vger.kernel.org; Mon, 06 Dec 2010 12:06:46 +0100
Received: from artipc9.vub.ac.be ([134.184.26.59])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 06 Dec 2010 12:06:46 +0100
Received: from fhimpe by artipc9.vub.ac.be with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 06 Dec 2010 12:06:46 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With kernel 2.6.32.15 I can reproducibly kill networking on a system 
using the bnx2 driver by starting up memory hogs triggering the OOM 
killer.

I could not find any indication in the 2.6.32 stable changelogs that
this is fixed in a later 2.6.32 update.

Here is the log including the OOM killer traces and the bnx2 null
pointer deference captured with netconsole:

Dec  5 19:26:19 node001.cvos.cluster [4445292.253420] IN invoked oom-killer: gfp_mask=0x280da, order=0, oom_adj=0 
Dec  5 19:26:19 node001.cvos.cluster [4445292.253498] Pid: 30009, comm: IN Not tainted 2.6.32.15 #1 
Dec  5 19:26:19 node001.cvos.cluster [4445292.253559] Call Trace: 
Dec  5 19:26:19 node001.cvos.cluster [4445292.253624]  [<ffffffff8106bd0c>] ? cpuset_print_task_mems_allowed+0x8c/0x97 
Dec  5 19:26:19 node001.cvos.cluster [4445292.253690]  [<ffffffff81080439>] oom_kill_process+0x84/0x291 
Dec  5 19:26:19 node001.cvos.cluster [4445292.253753]  [<ffffffff81080955>] ? select_bad_process+0xab/0xf0 
Dec  5 19:26:19 node001.cvos.cluster [4445292.253816]  [<ffffffff81080a1f>] __out_of_memory+0x85/0x94 
Dec  5 19:26:19 node001.cvos.cluster [4445292.253878]  [<ffffffff81080b76>] out_of_memory+0x148/0x17a 
Dec  5 19:26:19 node001.cvos.cluster [4445292.253942]  [<ffffffff81089bc0>] ? try_to_free_pages+0x69/0x6b 
Dec  5 19:26:19 node001.cvos.cluster [4445292.254005]  [<ffffffff81084017>] __alloc_pages_nodemask+0x4a4/0x593 
Dec  5 19:26:19 node001.cvos.cluster [4445292.254071]  [<ffffffff810a5793>] alloc_page_vma+0xc9/0xcb 
Dec  5 19:26:19 node001.cvos.cluster [4445292.254134]  [<ffffffff81086423>] ? lru_cache_add_lru+0x22/0x24 
Dec  5 19:26:19 node001.cvos.cluster [4445292.254211]  [<ffffffff8109420a>] handle_mm_fault+0x1cf/0x771 
Dec  5 19:26:19 node001.cvos.cluster [4445292.254289]  [<ffffffff81026078>] do_page_fault+0x233/0x24b 
Dec  5 19:26:19 node001.cvos.cluster [4445292.254367]  [<ffffffff8134573f>] page_fault+0x1f/0x30 
Dec  5 19:26:19 node001.cvos.cluster [4445292.254444] Node 0 
Dec  5 19:26:19 node001.cvos.cluster DMA per-cpu: 
Dec  5 19:26:19 node001.cvos.cluster [4445292.254563] CPU    0: hi:    0, btch:   1 usd:   0 
Dec  5 19:26:19 node001.cvos.cluster [4445292.254636] CPU    1: hi:    0, btch:   1 usd:   0 
Dec  5 19:26:19 node001.cvos.cluster [4445292.254709] CPU    2: hi:    0, btch:   1 usd:   0 
Dec  5 19:26:19 node001.cvos.cluster [4445292.254782] CPU    3: hi:    0, btch:   1 usd:   0 
Dec  5 19:26:19 node001.cvos.cluster [4445292.254856] CPU    4: hi:    0, btch:   1 usd:   0 
Dec  5 19:26:19 node001.cvos.cluster [4445292.254929] CPU    5: hi:    0, btch:   1 usd:   0 
Dec  5 19:26:19 node001.cvos.cluster [4445292.255002] CPU    6: hi:    0, btch:   1 usd:   0 
Dec  5 19:26:19 node001.cvos.cluster [4445292.255075] CPU    7: hi:    0, btch:   1 usd:   0 
Dec  5 19:26:19 node001.cvos.cluster [4445292.255147] Node 0 
Dec  5 19:26:19 node001.cvos.cluster DMA32 per-cpu: 
Dec  5 19:26:19 node001.cvos.cluster [4445292.255266] CPU    0: hi:  186, btch:  31 usd:  28 
Dec  5 19:26:19 node001.cvos.cluster [4445292.255339] CPU    1: hi:  186, btch:  31 usd:  47 
Dec  5 19:26:19 node001.cvos.cluster [4445292.255413] CPU    2: hi:  186, btch:  31 usd: 119 
Dec  5 19:26:19 node001.cvos.cluster [4445292.255485] CPU    3: hi:  186, btch:  31 usd: 171 
Dec  5 19:26:19 node001.cvos.cluster [4445292.255558] CPU    4: hi:  186, btch:  31 usd: 111 
Dec  5 19:26:19 node001.cvos.cluster [4445292.255631] CPU    5: hi:  186, btch:  31 usd: 128 
Dec  5 19:26:19 node001.cvos.cluster [4445292.255704] CPU    6: hi:  186, btch:  31 usd:  76 
Dec  5 19:26:19 node001.cvos.cluster [4445292.255777] CPU    7: hi:  186, btch:  31 usd: 128 
Dec  5 19:26:19 node001.cvos.cluster [4445292.255849] Node 0 
Dec  5 19:26:19 node001.cvos.cluster Normal per-cpu: 
Dec  5 19:26:19 node001.cvos.cluster [4445292.255967] CPU    0: hi:  186, btch:  31 usd:  91 
Dec  5 19:26:19 node001.cvos.cluster [4445292.256057] CPU    1: hi:  186, btch:  31 usd:  68 
Dec  5 19:26:19 node001.cvos.cluster [4445292.256130] CPU    2: hi:  186, btch:  31 usd: 176 
Dec  5 19:26:19 node001.cvos.cluster [4445292.256204] CPU    3: hi:  186, btch:  31 usd:  23 
Dec  5 19:26:19 node001.cvos.cluster [4445292.256277] CPU    4: hi:  186, btch:  31 usd: 104 
Dec  5 19:26:19 node001.cvos.cluster [4445292.256349] CPU    5: hi:  186, btch:  31 usd:  34 
Dec  5 19:26:19 node001.cvos.cluster [4445292.256423] CPU    6: hi:  186, btch:  31 usd:  25 
Dec  5 19:26:19 node001.cvos.cluster [4445292.256496] CPU    7: hi:  186, btch:  31 usd: 116 
Dec  5 19:26:19 node001.cvos.cluster [4445292.256573] active_anon:1650726 inactive_anon:323194 isolated_anon:160 
Dec  5 19:26:19 node001.cvos.cluster [4445292.256575]  active_file:278 inactive_file:187 isolated_file:0 
Dec  5 19:26:19 node001.cvos.cluster [4445292.256576]  unevictable:3447 dirty:8 writeback:661 unstable:3 
Dec  5 19:26:19 node001.cvos.cluster [4445292.256578]  free:11853 slab_reclaimable:1635 slab_unreclaimable:3043 
Dec  5 19:26:19 node001.cvos.cluster [4445292.256579]  mapped:1332 shmem:0 pagetables:12323 bounce:0 
Dec  5 19:26:19 node001.cvos.cluster [4445292.256949] Node 0 
Dec  5 19:26:19 node001.cvos.cluster DMA free:15896kB min:20kB low:24kB high:28kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15304kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes 
Dec  5 19:26:19 node001.cvos.cluster [4445292.257214] lowmem_reserve[]:
Dec  5 19:26:19 node001.cvos.cluster  0
Dec  5 19:26:19 node001.cvos.cluster  2999
Dec  5 19:26:19 node001.cvos.cluster  8049
Dec  5 19:26:19 node001.cvos.cluster  8049
Dec  5 19:26:19 node001.cvos.cluster  
Dec  5 19:26:19 node001.cvos.cluster [4445292.257532] Node 0 
Dec  5 19:26:19 node001.cvos.cluster DMA32 free:24400kB min:4272kB low:5340kB high:6408kB active_anon:2316300kB inactive_anon:578492kB active_file:428kB inactive_file:20kB unevictable:0kB isolated(anon):256kB isolated(file):0kB present:3071996kB mlocked:0kB dirty:8kB writeback:348kB mapped:156kB shmem:0kB slab_reclaimable:492kB slab_unreclaimable:564kB kernel_stack:16kB pagetables:16756kB unstable:4kB bounce:0kB writeback_tmp:0kB pages_scanned:217 all_unreclaimable? no 
Dec  5 19:26:19 node001.cvos.cluster [4445292.257879] lowmem_reserve[]:
Dec  5 19:26:19 node001.cvos.cluster  0
Dec  5 19:26:19 node001.cvos.cluster  0
Dec  5 19:26:19 node001.cvos.cluster  5050
Dec  5 19:26:19 node001.cvos.cluster  5050
Dec  5 19:26:19 node001.cvos.cluster  
Dec  5 19:26:19 node001.cvos.cluster [4445292.258210] Node 0 
Dec  5 19:26:19 node001.cvos.cluster Normal free:7116kB min:7192kB low:8988kB high:10788kB active_anon:4286896kB inactive_anon:714540kB active_file:684kB inactive_file:496kB unevictable:13788kB isolated(anon):384kB isolated(file):0kB present:5171200kB mlocked:5528kB dirty:24kB writeback:1956kB mapped:5172kB shmem:0kB slab_reclaimable:6048kB slab_unreclaimable:11608kB kernel_stack:1624kB pagetables:32536kB unstable:8kB bounce:0kB writeback_tmp:0kB pages_scanned:2263 all_unreclaimable? no 
Dec  5 19:26:19 node001.cvos.cluster [4445292.258477] lowmem_reserve[]:
Dec  5 19:26:19 node001.cvos.cluster  0
Dec  5 19:26:19 node001.cvos.cluster last message repeated 3 times
Dec  5 19:26:19 node001.cvos.cluster  
Dec  5 19:26:19 node001.cvos.cluster [4445292.258795] Node 0 
Dec  5 19:26:19 node001.cvos.cluster DMA: 
Dec  5 19:26:19 node001.cvos.cluster 0*4kB 
Dec  5 19:26:19 node001.cvos.cluster 1*8kB 
Dec  5 19:26:19 node001.cvos.cluster 1*16kB 
Dec  5 19:26:19 node001.cvos.cluster 2*32kB 
Dec  5 19:26:19 node001.cvos.cluster 3*64kB 
Dec  5 19:26:19 node001.cvos.cluster 2*128kB 
Dec  5 19:26:19 node001.cvos.cluster 0*256kB 
Dec  5 19:26:19 node001.cvos.cluster 0*512kB 
Dec  5 19:26:19 node001.cvos.cluster 1*1024kB 
Dec  5 19:26:19 node001.cvos.cluster 1*2048kB 
Dec  5 19:26:19 node001.cvos.cluster 3*4096kB 
Dec  5 19:26:19 node001.cvos.cluster = 15896kB 
Dec  5 19:26:19 node001.cvos.cluster [4445292.265993] Node 0 
Dec  5 19:26:19 node001.cvos.cluster DMA32: 
Dec  5 19:26:19 node001.cvos.cluster 2*4kB 
Dec  5 19:26:19 node001.cvos.cluster 3*8kB 
Dec  5 19:26:19 node001.cvos.cluster 9*16kB 
Dec  5 19:26:19 node001.cvos.cluster 7*32kB 
Dec  5 19:26:19 node001.cvos.cluster 2*64kB 
Dec  5 19:26:19 node001.cvos.cluster 3*128kB 
Dec  5 19:26:19 node001.cvos.cluster 14*256kB 
Dec  5 19:26:19 node001.cvos.cluster 10*512kB 
Dec  5 19:26:19 node001.cvos.cluster 6*1024kB 
Dec  5 19:26:19 node001.cvos.cluster 2*2048kB 
Dec  5 19:26:19 node001.cvos.cluster 1*4096kB 
Dec  5 19:26:19 node001.cvos.cluster = 23952kB 
Dec  5 19:26:19 node001.cvos.cluster [4445292.266722] Node 0 
Dec  5 19:26:19 node001.cvos.cluster Normal: 
Dec  5 19:26:19 node001.cvos.cluster 31*4kB 
Dec  5 19:26:19 node001.cvos.cluster 32*8kB 
Dec  5 19:26:19 node001.cvos.cluster 46*16kB 
Dec  5 19:26:19 node001.cvos.cluster 15*32kB 
Dec  5 19:26:19 node001.cvos.cluster 6*64kB 
Dec  5 19:26:19 node001.cvos.cluster 5*128kB 
Dec  5 19:26:19 node001.cvos.cluster 2*256kB 
Dec  5 19:26:19 node001.cvos.cluster 0*512kB 
Dec  5 19:26:19 node001.cvos.cluster 0*1024kB 
Dec  5 19:26:19 node001.cvos.cluster 0*2048kB 
Dec  5 19:26:19 node001.cvos.cluster 1*4096kB 
Dec  5 19:26:19 node001.cvos.cluster = 7228kB 
Dec  5 19:26:19 node001.cvos.cluster [4445292.267449] 5337 total pagecache pages 
Dec  5 19:26:19 node001.cvos.cluster [4445292.267520] 2009 pages in swap cache 
Dec  5 19:26:19 node001.cvos.cluster [4445292.267591] Swap cache stats: add 15770704, delete 15768695, find 334248/348086 
Dec  5 19:26:19 node001.cvos.cluster [4445292.267683] Free swap  = 0kB 
Dec  5 19:26:19 node001.cvos.cluster [4445292.267751] Total swap = 15639700kB 
Dec  5 19:26:19 node001.cvos.cluster [4445292.309854] Out of memory: kill process 29969 (IN) score 1493120 or a child 
Dec  5 19:26:19 node001.cvos.cluster [4445292.309942] Killed process 29969 (IN) 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.253420] IN invoked oom-killer: gfp_mask=0x280da, order=0, oom_adj=0 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.253494] IN cpuset=/ mems_allowed=0 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.253498] Pid: 30009, comm: IN Not tainted 2.6.32.15 #1 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.253559] Call Trace: 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.253624]  [<ffffffff8106bd0c>] ? cpuset_print_task_mems_allowed+0x8c/0x97 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.253690]  [<ffffffff81080439>] oom_kill_process+0x84/0x291 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.253753]  [<ffffffff81080955>] ? select_bad_process+0xab/0xf0 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.253816]  [<ffffffff81080a1f>] __out_of_memory+0x85/0x94 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.253878]  [<ffffffff81080b76>] out_of_memory+0x148/0x17a 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.253942]  [<ffffffff81089bc0>] ? try_to_free_pages+0x69/0x6b 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.254005]  [<ffffffff81084017>] __alloc_pages_nodemask+0x4a4/0x593 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.254071]  [<ffffffff810a5793>] alloc_page_vma+0xc9/0xcb 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.254134]  [<ffffffff81086423>] ? lru_cache_add_lru+0x22/0x24 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.254211]  [<ffffffff8109420a>] handle_mm_fault+0x1cf/0x771 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.254289]  [<ffffffff81026078>] do_page_fault+0x233/0x24b 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.254367]  [<ffffffff8134573f>] page_fault+0x1f/0x30 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.254442] Mem-Info: 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.254444] Node 0 DMA per-cpu: 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.254563] CPU    0: hi:    0, btch:   1 usd:   0 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.254636] CPU    1: hi:    0, btch:   1 usd:   0 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.254709] CPU    2: hi:    0, btch:   1 usd:   0 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.254782] CPU    3: hi:    0, btch:   1 usd:   0 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.254856] CPU    4: hi:    0, btch:   1 usd:   0 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.254929] CPU    5: hi:    0, btch:   1 usd:   0 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.255002] CPU    6: hi:    0, btch:   1 usd:   0 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.255075] CPU    7: hi:    0, btch:   1 usd:   0 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.255147] Node 0 DMA32 per-cpu: 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.255266] CPU    0: hi:  186, btch:  31 usd:  28 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.255339] CPU    1: hi:  186, btch:  31 usd:  47 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.255413] CPU    2: hi:  186, btch:  31 usd: 119 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.255485] CPU    3: hi:  186, btch:  31 usd: 171 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.255558] CPU    4: hi:  186, btch:  31 usd: 111 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.255631] CPU    5: hi:  186, btch:  31 usd: 128 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.255704] CPU    6: hi:  186, btch:  31 usd:  76 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.255777] CPU    7: hi:  186, btch:  31 usd: 128 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.255849] Node 0 Normal per-cpu: 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.255967] CPU    0: hi:  186, btch:  31 usd:  91 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.256057] CPU    1: hi:  186, btch:  31 usd:  68 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.256130] CPU    2: hi:  186, btch:  31 usd: 176 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.256204] CPU    3: hi:  186, btch:  31 usd:  23 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.256277] CPU    4: hi:  186, btch:  31 usd: 104 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.256349] CPU    5: hi:  186, btch:  31 usd:  34 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.256423] CPU    6: hi:  186, btch:  31 usd:  25 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.256496] CPU    7: hi:  186, btch:  31 usd: 116 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.256573] active_anon:1650726 inactive_anon:323194 isolated_anon:160 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.256575]  active_file:278 inactive_file:187 isolated_file:0 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.256576]  unevictable:3447 dirty:8 writeback:661 unstable:3 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.256578]  free:11853 slab_reclaimable:1635 slab_unreclaimable:3043 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.256579]  mapped:1332 shmem:0 pagetables:12323 bounce:0 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.256949] Node 0 DMA free:15896kB min:20kB low:24kB high:28kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15304kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.257214] lowmem_reserve[]: 0 2999 8049 8049 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.257532] Node 0 DMA32 free:24400kB min:4272kB low:5340kB high:6408kB active_anon:2316300kB inactive_anon:578492kB active_file:428kB inactive_file:20kB unevictable:0kB isolated(anon):256kB isolated(file):0kB present:3071996kB mlocked:0kB dirty:8kB writeback:348kB mapped:156kB shmem:0kB slab_reclaimable:492kB slab_unreclaimable:564kB kernel_stack:16kB pagetables:16756kB unstable:4kB bounce:0kB writeback_tmp:0kB pages_scanned:217 all_unreclaimable? no 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.257879] lowmem_reserve[]: 0 0 5050 5050 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.258210] Node 0 Normal free:7116kB min:7192kB low:8988kB high:10788kB active_anon:4286896kB inactive_anon:714540kB active_file:684kB inactive_file:496kB unevictable:13788kB isolated(anon):384kB isolated(file):0kB present:5171200kB mlocked:5528kB dirty:24kB writeback:1956kB mapped:5172kB shmem:0kB slab_reclaimable:6048kB slab_unreclaimable:11608kB kernel_stack:1624kB pagetables:32536kB unstable:8kB bounce:0kB writeback_tmp:0kB pages_scanned:2263 all_unreclaimable? no 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.258477] lowmem_reserve[]: 0 0 0 0 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.258795] Node 0 DMA: 0*4kB 1*8kB 1*16kB 2*32kB 3*64kB 2*128kB 0*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15896kB 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.265993] Node 0 DMA32: 2*4kB 3*8kB 9*16kB 7*32kB 2*64kB 3*128kB 14*256kB 10*512kB 6*1024kB 2*2048kB 1*4096kB = 23952kB 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.266722] Node 0 Normal: 31*4kB 32*8kB 46*16kB 15*32kB 6*64kB 5*128kB 2*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 7228kB 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.267449] 5337 total pagecache pages 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.267520] 2009 pages in swap cache 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.267591] Swap cache stats: add 15770704, delete 15768695, find 334248/348086 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.267683] Free swap  = 0kB 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.267751] Total swap = 15639700kB 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.309843] 2097152 pages RAM 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.309846] 47211 pages reserved 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.309848] 5736 pages shared 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.309850] 2034961 pages non-shared 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.309854] Out of memory: kill process 29969 (IN) score 1493120 or a child 
Dec  5 19:26:20 node001.cvos.cluster kernel: [4445292.309942] Killed process 29969 (IN) 
Dec  5 19:27:37 node001.cvos.cluster nscd: nss_ldap: reconnected to LDAP server ldap://master/ after 1 attempt 
Dec  5 19:29:38 node001.cvos.cluster [4445490.905133] IN invoked oom-killer: gfp_mask=0x280da, order=0, oom_adj=0 
Dec  5 19:29:38 node001.cvos.cluster [4445490.905212] Pid: 30009, comm: IN Not tainted 2.6.32.15 #1 
Dec  5 19:29:38 node001.cvos.cluster [4445490.905275] Call Trace: 
Dec  5 19:29:38 node001.cvos.cluster [4445490.905341]  [<ffffffff8106bd0c>] ? cpuset_print_task_mems_allowed+0x8c/0x97 
Dec  5 19:29:38 node001.cvos.cluster [4445490.905409]  [<ffffffff81080439>] oom_kill_process+0x84/0x291 
Dec  5 19:29:38 node001.cvos.cluster [4445490.905472]  [<ffffffff81080955>] ? select_bad_process+0xab/0xf0 
Dec  5 19:29:38 node001.cvos.cluster [4445490.905548]  [<ffffffff81080a1f>] __out_of_memory+0x85/0x94 
Dec  5 19:29:38 node001.cvos.cluster [4445490.905614]  [<ffffffff81080b76>] out_of_memory+0x148/0x17a 
Dec  5 19:29:38 node001.cvos.cluster [4445490.905682]  [<ffffffff81089bc0>] ? try_to_free_pages+0x69/0x6b 
Dec  5 19:29:38 node001.cvos.cluster [4445490.905747]  [<ffffffff81084017>] __alloc_pages_nodemask+0x4a4/0x593 
Dec  5 19:29:38 node001.cvos.cluster [4445490.905815]  [<ffffffff810a5793>] alloc_page_vma+0xc9/0xcb 
Dec  5 19:29:38 node001.cvos.cluster [4445490.905881]  [<ffffffff8109420a>] handle_mm_fault+0x1cf/0x771 
Dec  5 19:29:38 node001.cvos.cluster [4445490.905959]  [<ffffffff8100b9ae>] ? invalidate_interrupt0+0xe/0x20 
Dec  5 19:29:38 node001.cvos.cluster [4445490.906038]  [<ffffffff81026078>] do_page_fault+0x233/0x24b 
Dec  5 19:29:38 node001.cvos.cluster [4445490.906116]  [<ffffffff8134573f>] page_fault+0x1f/0x30 
Dec  5 19:29:38 node001.cvos.cluster [4445490.906193] Node 0 
Dec  5 19:29:38 node001.cvos.cluster DMA per-cpu: 
Dec  5 19:29:38 node001.cvos.cluster [4445490.906311] CPU    0: hi:    0, btch:   1 usd:   0 
Dec  5 19:29:38 node001.cvos.cluster [4445490.906384] CPU    1: hi:    0, btch:   1 usd:   0 
Dec  5 19:29:38 node001.cvos.cluster [4445490.906457] CPU    2: hi:    0, btch:   1 usd:   0 
Dec  5 19:29:38 node001.cvos.cluster [4445490.906530] CPU    3: hi:    0, btch:   1 usd:   0 
Dec  5 19:29:38 node001.cvos.cluster [4445490.906603] CPU    4: hi:    0, btch:   1 usd:   0 
Dec  5 19:29:38 node001.cvos.cluster [4445490.906676] CPU    5: hi:    0, btch:   1 usd:   0 
Dec  5 19:29:38 node001.cvos.cluster [4445490.906749] CPU    6: hi:    0, btch:   1 usd:   0 
Dec  5 19:29:38 node001.cvos.cluster [4445490.906821] CPU    7: hi:    0, btch:   1 usd:   0 
Dec  5 19:29:38 node001.cvos.cluster [4445490.906894] Node 0 
Dec  5 19:29:38 node001.cvos.cluster DMA32 per-cpu: 
Dec  5 19:29:38 node001.cvos.cluster [4445490.907013] CPU    0: hi:  186, btch:  31 usd: 130 
Dec  5 19:29:38 node001.cvos.cluster [4445490.907087] CPU    1: hi:  186, btch:  31 usd:  88 
Dec  5 19:29:38 node001.cvos.cluster [4445490.907160] CPU    2: hi:  186, btch:  31 usd: 178 
Dec  5 19:29:38 node001.cvos.cluster [4445490.907233] CPU    3: hi:  186, btch:  31 usd:  52 
Dec  5 19:29:38 node001.cvos.cluster [4445490.907306] CPU    4: hi:  186, btch:  31 usd:  95 
Dec  5 19:29:38 node001.cvos.cluster [4445490.907379] CPU    5: hi:  186, btch:  31 usd: 117 
Dec  5 19:29:38 node001.cvos.cluster [4445490.907452] CPU    6: hi:  186, btch:  31 usd:  79 
Dec  5 19:29:38 node001.cvos.cluster [4445490.907525] CPU    7: hi:  186, btch:  31 usd: 158 
Dec  5 19:29:38 node001.cvos.cluster [4445490.907597] Node 0 
Dec  5 19:29:38 node001.cvos.cluster Normal per-cpu: 
Dec  5 19:29:38 node001.cvos.cluster [4445490.907716] CPU    0: hi:  186, btch:  31 usd:  65 
Dec  5 19:29:38 node001.cvos.cluster [4445490.907789] CPU    1: hi:  186, btch:  31 usd: 132 
Dec  5 19:29:38 node001.cvos.cluster [4445490.907862] CPU    2: hi:  186, btch:  31 usd:  98 
Dec  5 19:29:38 node001.cvos.cluster [4445490.907935] CPU    3: hi:  186, btch:  31 usd:  86 
Dec  5 19:29:38 node001.cvos.cluster [4445490.908009] CPU    4: hi:  186, btch:  31 usd:  99 
Dec  5 19:29:38 node001.cvos.cluster [4445490.908082] CPU    5: hi:  186, btch:  31 usd:  70 
Dec  5 19:29:38 node001.cvos.cluster [4445490.908155] CPU    6: hi:  186, btch:  31 usd: 163 
Dec  5 19:29:38 node001.cvos.cluster [4445490.908228] CPU    7: hi:  186, btch:  31 usd: 153 
Dec  5 19:29:38 node001.cvos.cluster [4445490.908305] active_anon:1649919 inactive_anon:323308 isolated_anon:0 
Dec  5 19:29:38 node001.cvos.cluster [4445490.908306]  active_file:146 inactive_file:147 isolated_file:0 
Dec  5 19:29:38 node001.cvos.cluster [4445490.908308]  unevictable:3447 dirty:1 writeback:6 unstable:0 
Dec  5 19:29:38 node001.cvos.cluster [4445490.908309]  free:11723 slab_reclaimable:1961 slab_unreclaimable:3022 
Dec  5 19:29:38 node001.cvos.cluster [4445490.908311]  mapped:1231 shmem:0 pagetables:12289 bounce:0 
Dec  5 19:29:38 node001.cvos.cluster [4445490.908676] Node 0 
Dec  5 19:29:38 node001.cvos.cluster DMA free:15896kB min:20kB low:24kB high:28kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15304kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes 
Dec  5 19:29:38 node001.cvos.cluster [4445490.908933] lowmem_reserve[]:
Dec  5 19:29:38 node001.cvos.cluster  0
Dec  5 19:29:38 node001.cvos.cluster  2999
Dec  5 19:29:38 node001.cvos.cluster  8049
Dec  5 19:29:38 node001.cvos.cluster  8049
Dec  5 19:29:38 node001.cvos.cluster  
Dec  5 19:29:38 node001.cvos.cluster [4445490.909248] Node 0 
Dec  5 19:29:38 node001.cvos.cluster DMA32 free:24040kB min:4272kB low:5340kB high:6408kB active_anon:2315284kB inactive_anon:579132kB active_file:140kB inactive_file:128kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3071996kB mlocked:0kB dirty:0kB writeback:20kB mapped:192kB shmem:0kB slab_reclaimable:364kB slab_unreclaimable:524kB kernel_stack:16kB pagetables:16688kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:225 all_unreclaimable? no 
Dec  5 19:29:38 node001.cvos.cluster [4445490.909527] lowmem_reserve[]:
Dec  5 19:29:38 node001.cvos.cluster  0
Dec  5 19:29:38 node001.cvos.cluster  0
Dec  5 19:29:38 node001.cvos.cluster  5050
Dec  5 19:29:38 node001.cvos.cluster  5050
Dec  5 19:29:38 node001.cvos.cluster  
Dec  5 19:29:38 node001.cvos.cluster [4445490.909840] Node 0 
Dec  5 19:29:38 node001.cvos.cluster Normal free:6956kB min:7192kB low:8988kB high:10788kB active_anon:4284392kB inactive_anon:714100kB active_file:444kB inactive_file:460kB unevictable:13788kB isolated(anon):0kB isolated(file):0kB present:5171200kB mlocked:5528kB dirty:4kB writeback:4kB mapped:4732kB shmem:0kB slab_reclaimable:7480kB slab_unreclaimable:11564kB kernel_stack:1632kB pagetables:32468kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:2272 all_unreclaimable? no 
Dec  5 19:29:38 node001.cvos.cluster [4445490.910106] lowmem_reserve[]:
Dec  5 19:29:38 node001.cvos.cluster  0
Dec  5 19:29:38 node001.cvos.cluster last message repeated 3 times
Dec  5 19:29:38 node001.cvos.cluster  
Dec  5 19:29:38 node001.cvos.cluster [4445490.910418] Node 0 
Dec  5 19:29:38 node001.cvos.cluster DMA: 
Dec  5 19:29:38 node001.cvos.cluster 0*4kB 
Dec  5 19:29:38 node001.cvos.cluster 1*8kB 
Dec  5 19:29:38 node001.cvos.cluster 1*16kB 
Dec  5 19:29:38 node001.cvos.cluster 2*32kB 
Dec  5 19:29:38 node001.cvos.cluster 3*64kB 
Dec  5 19:29:38 node001.cvos.cluster 2*128kB 
Dec  5 19:29:38 node001.cvos.cluster 0*256kB 
Dec  5 19:29:38 node001.cvos.cluster 0*512kB 
Dec  5 19:29:38 node001.cvos.cluster 1*1024kB 
Dec  5 19:29:38 node001.cvos.cluster 1*2048kB 
Dec  5 19:29:38 node001.cvos.cluster 3*4096kB 
Dec  5 19:29:38 node001.cvos.cluster = 15896kB 
Dec  5 19:29:38 node001.cvos.cluster [4445490.911147] Node 0 
Dec  5 19:29:38 node001.cvos.cluster DMA32: 
Dec  5 19:29:38 node001.cvos.cluster 19*4kB 
Dec  5 19:29:38 node001.cvos.cluster 3*8kB 
Dec  5 19:29:38 node001.cvos.cluster 6*16kB 
Dec  5 19:29:38 node001.cvos.cluster 45*32kB 
Dec  5 19:29:38 node001.cvos.cluster 6*64kB 
Dec  5 19:29:38 node001.cvos.cluster 3*128kB 
Dec  5 19:29:38 node001.cvos.cluster 9*256kB 
Dec  5 19:29:38 node001.cvos.cluster 10*512kB 
Dec  5 19:29:38 node001.cvos.cluster 6*1024kB 
Dec  5 19:29:38 node001.cvos.cluster 2*2048kB 
Dec  5 19:29:38 node001.cvos.cluster 1*4096kB 
Dec  5 19:29:38 node001.cvos.cluster = 24164kB 
Dec  5 19:29:38 node001.cvos.cluster [4445490.911877] Node 0 
Dec  5 19:29:38 node001.cvos.cluster Normal: 
Dec  5 19:29:38 node001.cvos.cluster 100*4kB 
Dec  5 19:29:38 node001.cvos.cluster 19*8kB 
Dec  5 19:29:38 node001.cvos.cluster 15*16kB 
Dec  5 19:29:38 node001.cvos.cluster 63*32kB 
Dec  5 19:29:38 node001.cvos.cluster 1*64kB 
Dec  5 19:29:38 node001.cvos.cluster 1*128kB 
Dec  5 19:29:38 node001.cvos.cluster 1*256kB 
Dec  5 19:29:38 node001.cvos.cluster 1*512kB 
Dec  5 19:29:38 node001.cvos.cluster 1*1024kB 
Dec  5 19:29:38 node001.cvos.cluster 1*2048kB 
Dec  5 19:29:38 node001.cvos.cluster 0*4096kB 
Dec  5 19:29:38 node001.cvos.cluster = 6840kB 
Dec  5 19:29:38 node001.cvos.cluster [4445490.912610] 28387 total pagecache pages 
Dec  5 19:29:38 node001.cvos.cluster [4445490.912681] 24865 pages in swap cache 
Dec  5 19:29:38 node001.cvos.cluster [4445490.912752] Swap cache stats: add 16262569, delete 16237704, find 334415/348361 
Dec  5 19:29:38 node001.cvos.cluster [4445490.912844] Free swap  = 0kB 
Dec  5 19:29:38 node001.cvos.cluster [4445490.912914] Total swap = 15639700kB 
Dec  5 19:29:38 node001.cvos.cluster [4445490.953112] Out of memory: kill process 29986 (2986853) score 870776 or a child 
Dec  5 19:29:38 node001.cvos.cluster [4445490.953213] Killed process 30011 (IN) 
Dec  5 19:29:38 node001.cvos.cluster [4445491.020475] IN invoked oom-killer: gfp_mask=0x280da, order=0, oom_adj=0 
Dec  5 19:29:38 node001.cvos.cluster [4445491.020584] Pid: 29979, comm: IN Not tainted 2.6.32.15 #1 
Dec  5 19:29:38 node001.cvos.cluster [4445491.020662] Call Trace: 
Dec  5 19:29:38 node001.cvos.cluster [4445491.020745]  [<ffffffff8106bd0c>] ? cpuset_print_task_mems_allowed+0x8c/0x97 
Dec  5 19:29:38 node001.cvos.cluster [4445491.020866]  [<ffffffff81080439>] oom_kill_process+0x84/0x291 
Dec  5 19:29:38 node001.cvos.cluster [4445491.020945]  [<ffffffff81080955>] ? select_bad_process+0xab/0xf0 
Dec  5 19:29:38 node001.cvos.cluster [4445491.021027]  [<ffffffff81080a1f>] __out_of_memory+0x85/0x94 
Dec  5 19:29:38 node001.cvos.cluster [4445491.021107]  [<ffffffff81080b76>] out_of_memory+0x148/0x17a 
Dec  5 19:29:38 node001.cvos.cluster [4445491.021187]  [<ffffffff81089bc0>] ? try_to_free_pages+0x69/0x6b 
Dec  5 19:29:38 node001.cvos.cluster [4445491.021268]  [<ffffffff81084017>] __alloc_pages_nodemask+0x4a4/0x593 
Dec  5 19:29:38 node001.cvos.cluster [4445491.021352]  [<ffffffff810a5793>] alloc_page_vma+0xc9/0xcb 
Dec  5 19:29:38 node001.cvos.cluster [4445491.021431]  [<ffffffff81086423>] ? lru_cache_add_lru+0x22/0x24 
Dec  5 19:29:38 node001.cvos.cluster [4445491.021512]  [<ffffffff8109420a>] handle_mm_fault+0x1cf/0x771 
Dec  5 19:29:38 node001.cvos.cluster [4445491.021593]  [<ffffffff81026078>] do_page_fault+0x233/0x24b 
Dec  5 19:29:38 node001.cvos.cluster [4445491.021676]  [<ffffffff8134573f>] page_fault+0x1f/0x30 
Dec  5 19:29:38 node001.cvos.cluster [4445491.021758] Node 0 
Dec  5 19:29:38 node001.cvos.cluster DMA per-cpu: 
Dec  5 19:29:38 node001.cvos.cluster [4445491.021890] CPU    0: hi:    0, btch:   1 usd:   0 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.905133] IN invoked oom-killer: gfp_mask=0x280da, order=0, oom_adj=0 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.905208] IN cpuset=/ mems_allowed=0 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.905212] Pid: 30009, comm: IN Not tainted 2.6.32.15 #1 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.905275] Call Trace: 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.905341]  [<ffffffff8106bd0c>] ? cpuset_print_task_mems_allowed+0x8c/0x97 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.905409]  [<ffffffff81080439>] oom_kill_process+0x84/0x291 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.905472]  [<ffffffff81080955>] ? select_bad_process+0xab/0xf0 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.905548]  [<ffffffff81080a1f>] __out_of_memory+0x85/0x94 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.905614]  [<ffffffff81080b76>] out_of_memory+0x148/0x17a 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.905682]  [<ffffffff81089bc0>] ? try_to_free_pages+0x69/0x6b 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.905747]  [<ffffffff81084017>] __alloc_pages_nodemask+0x4a4/0x593 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.905815]  [<ffffffff810a5793>] alloc_page_vma+0xc9/0xcb 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.905881]  [<ffffffff8109420a>] handle_mm_fault+0x1cf/0x771 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.905959]  [<ffffffff8100b9ae>] ? invalidate_interrupt0+0xe/0x20 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.906038]  [<ffffffff81026078>] do_page_fault+0x233/0x24b 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.906116]  [<ffffffff8134573f>] page_fault+0x1f/0x30 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.906190] Mem-Info: 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.906193] Node 0 DMA per-cpu: 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.906311] CPU    0: hi:    0, btch:   1 usd:   0 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.906384] CPU    1: hi:    0, btch:   1 usd:   0 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.906457] CPU    2: hi:    0, btch:   1 usd:   0 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.906530] CPU    3: hi:    0, btch:   1 usd:   0 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.906603] CPU    4: hi:    0, btch:   1 usd:   0 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.906676] CPU    5: hi:    0, btch:   1 usd:   0 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.906749] CPU    6: hi:    0, btch:   1 usd:   0 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.906821] CPU    7: hi:    0, btch:   1 usd:   0 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.906894] Node 0 DMA32 per-cpu: 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.907013] CPU    0: hi:  186, btch:  31 usd: 130 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.907087] CPU    1: hi:  186, btch:  31 usd:  88 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.907160] CPU    2: hi:  186, btch:  31 usd: 178 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.907233] CPU    3: hi:  186, btch:  31 usd:  52 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.907306] CPU    4: hi:  186, btch:  31 usd:  95 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.907379] CPU    5: hi:  186, btch:  31 usd: 117 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.907452] CPU    6: hi:  186, btch:  31 usd:  79 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.907525] CPU    7: hi:  186, btch:  31 usd: 158 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.907597] Node 0 Normal per-cpu: 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.907716] CPU    0: hi:  186, btch:  31 usd:  65 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.907789] CPU    1: hi:  186, btch:  31 usd: 132 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.907862] CPU    2: hi:  186, btch:  31 usd:  98 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.907935] CPU    3: hi:  186, btch:  31 usd:  86 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.908009] CPU    4: hi:  186, btch:  31 usd:  99 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.908082] CPU    5: hi:  186, btch:  31 usd:  70 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.908155] CPU    6: hi:  186, btch:  31 usd: 163 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.908228] CPU    7: hi:  186, btch:  31 usd: 153 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.908305] active_anon:1649919 inactive_anon:323308 isolated_anon:0 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.908306]  active_file:146 inactive_file:147 isolated_file:0 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.908308]  unevictable:3447 dirty:1 writeback:6 unstable:0 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.908309]  free:11723 slab_reclaimable:1961 slab_unreclaimable:3022 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.908311]  mapped:1231 shmem:0 pagetables:12289 bounce:0 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.908676] Node 0 DMA free:15896kB min:20kB low:24kB high:28kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15304kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.908933] lowmem_reserve[]: 0 2999 8049 8049 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.909248] Node 0 DMA32 free:24040kB min:4272kB low:5340kB high:6408kB active_anon:2315284kB inactive_anon:579132kB active_file:140kB inactive_file:128kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3071996kB mlocked:0kB dirty:0kB writeback:20kB mapped:192kB shmem:0kB slab_reclaimable:364kB slab_unreclaimable:524kB kernel_stack:16kB pagetables:16688kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:225 all_unreclaimable? no 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.909527] lowmem_reserve[]: 0 0 5050 5050 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.909840] Node 0 Normal free:6956kB min:7192kB low:8988kB high:10788kB active_anon:4284392kB inactive_anon:714100kB active_file:444kB inactive_file:460kB unevictable:13788kB isolated(anon):0kB isolated(file):0kB present:5171200kB mlocked:5528kB dirty:4kB writeback:4kB mapped:4732kB shmem:0kB slab_reclaimable:7480kB slab_unreclaimable:11564kB kernel_stack:1632kB pagetables:32468kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:2272 all_unreclaimable? no 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.910106] lowmem_reserve[]: 0 0 0 0 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.910418] Node 0 DMA: 0*4kB 1*8kB 1*16kB 2*32kB 3*64kB 2*128kB 0*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15896kB 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.911147] Node 0 DMA32: 19*4kB 3*8kB 6*16kB 45*32kB 6*64kB 3*128kB 9*256kB 10*512kB 6*1024kB 2*2048kB 1*4096kB = 24164kB 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.911877] Node 0 Normal: 100*4kB 19*8kB 15*16kB 63*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 6840kB 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.912610] 28387 total pagecache pages 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.912681] 24865 pages in swap cache 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.912752] Swap cache stats: add 16262569, delete 16237704, find 334415/348361 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.912844] Free swap  = 0kB 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.912914] Total swap = 15639700kB 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.953100] 2097152 pages RAM 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.953104] 47211 pages reserved 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.953106] 5570 pages shared 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.953107] 2034676 pages non-shared 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.953112] Out of memory: kill process 29986 (2986853) score 870776 or a child 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445490.953213] Killed process 30011 (IN) 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445491.020475] IN invoked oom-killer: gfp_mask=0x280da, order=0, oom_adj=0 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445491.020578] IN cpuset=/ mems_allowed=0 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445491.020584] Pid: 29979, comm: IN Not tainted 2.6.32.15 #1 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445491.020662] Call Trace: 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445491.020745]  [<ffffffff8106bd0c>] ? cpuset_print_task_mems_allowed+0x8c/0x97 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445491.020866]  [<ffffffff81080439>] oom_kill_process+0x84/0x291 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445491.020945]  [<ffffffff81080955>] ? select_bad_process+0xab/0xf0 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445491.021027]  [<ffffffff81080a1f>] __out_of_memory+0x85/0x94 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445491.021107]  [<ffffffff81080b76>] out_of_memory+0x148/0x17a 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445491.021187]  [<ffffffff81089bc0>] ? try_to_free_pages+0x69/0x6b 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445491.021268]  [<ffffffff81084017>] __alloc_pages_nodemask+0x4a4/0x593 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445491.021352]  [<ffffffff810a5793>] alloc_page_vma+0xc9/0xcb 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445491.021431]  [<ffffffff81086423>] ? lru_cache_add_lru+0x22/0x24 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445491.021512]  [<ffffffff8109420a>] handle_mm_fault+0x1cf/0x771 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445491.021593]  [<ffffffff81026078>] do_page_fault+0x233/0x24b 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445491.021676]  [<ffffffff8134573f>] page_fault+0x1f/0x30 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445491.021756] Mem-Info: 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445491.021758] Node 0 DMA per-cpu: 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445491.021890] CPU    0: hi:    0, btch:   1 usd:   0 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445491.021968] CPU    1: hi:    0, btch:   1 usd:   0 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445491.022070] BUG: unable to handle kernel NULL pointer dereference at (null) 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445491.022073] IP: [<ffffffff812527c8>] bnx2_poll_work+0x2a/0x989 
Dec  5 19:29:38 node001.cvos.cluster kernel: [4445491.022081] PGD 234ca4067 PUD 224558067 PMD 0  

-- 
Frederik Himpe

