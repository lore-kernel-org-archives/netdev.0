From: Dave Jones <davej@redhat.com>
Subject: loading sctp fails an order 10 allocation.
Date: Wed, 30 Mar 2011 19:40:21 -0400
Message-ID: <20110330234020.GA24517@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

modprobe sctp on my laptop does this which looks crazy..


[28106.742435] modprobe: page allocation failure. order:10, mode:0x20
[28106.742744] Pid: 8839, comm: modprobe Not tainted 2.6.38-09065-g89078d5-dirty #6
[28106.743129] Call Trace:
[28106.743262]  [<ffffffff810f6811>] __alloc_pages_nodemask+0x7f6/0x885
[28106.743578]  [<ffffffff81193604>] ? proc_register+0x129/0x1ad
[28106.743864]  [<ffffffff81121e29>] alloc_pages_current+0xb1/0xca
[28106.744175]  [<ffffffff8126b35d>] ? __raw_spin_lock_init+0x31/0x50
[28106.744478]  [<ffffffff810f2a21>] __get_free_pages+0x16/0x53
[28106.744766]  [<ffffffffa03061a0>] sctp_init+0x1a0/0x7d5 [sctp]
[28106.745066]  [<ffffffff8103403f>] ? set_memory_ro+0x21/0x23
[28106.745349]  [<ffffffffa0306000>] ? 0xffffffffa0305fff
[28106.745607]  [<ffffffff81002193>] do_one_initcall+0x7f/0x13c
[28106.745889]  [<ffffffff81096ffb>] sys_init_module+0xe2/0x231
[28106.746184]  [<ffffffff814d6bc2>] system_call_fastpath+0x16/0x1b
[28106.746478] Mem-Info:
[28106.746595] Node 0 DMA per-cpu:
[28106.746762] CPU    0: hi:    0, btch:   1 usd:   0
[28106.746998] CPU    1: hi:    0, btch:   1 usd:   0
[28106.747256] Node 0 DMA32 per-cpu:
[28106.747433] CPU    0: hi:  186, btch:  31 usd: 164
[28106.747672] CPU    1: hi:  186, btch:  31 usd: 156
[28106.747909] Node 0 Normal per-cpu:
[28106.748103] CPU    0: hi:  186, btch:  31 usd:  93
[28106.748341] CPU    1: hi:  186, btch:  31 usd: 162
[28106.748582] active_anon:198288 inactive_anon:25897 isolated_anon:0
[28106.748584]  active_file:118670 inactive_file:224764 isolated_file:0
[28106.748585]  unevictable:4 dirty:39 writeback:0 unstable:0
[28106.748586]  free:309311 slab_reclaimable:56405 slab_unreclaimable:38498
[28106.748587]  mapped:59632 shmem:28756 pagetables:8080 bounce:0
[28106.750099] Node 0 DMA free:15900kB min:256kB low:320kB high:384kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15676kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[28106.751887] lowmem_reserve[]: 0 2959 3969 3969
[28106.752167] Node 0 DMA32 free:1208204kB min:50192kB low:62740kB high:75288kB active_anon:635892kB inactive_anon:83536kB active_file:268160kB inactive_file:620756kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3030584kB mlocked:0kB dirty:24kB writeback:0kB mapped:150448kB shmem:90868kB slab_reclaimable:152208kB slab_unreclaimable:22560kB kernel_stack:288kB pagetables:4496kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:32 all_unreclaimable? no
[28106.754183] lowmem_reserve[]: 0 0 1010 1010
[28106.754437] Node 0 Normal free:21944kB min:17128kB low:21408kB high:25692kB active_anon:154572kB inactive_anon:22740kB active_file:206520kB inactive_file:269424kB unevictable:16kB isolated(anon):0kB isolated(file):0kB present:1034240kB mlocked:16kB dirty:132kB writeback:0kB mapped:88080kB shmem:24156kB slab_reclaimable:73412kB slab_unreclaimable:131432kB kernel_stack:2352kB pagetables:27824kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:39 all_unreclaimable? no
[28106.756463] lowmem_reserve[]: 0 0 0 0
[28106.756693] Node 0 DMA: 1*4kB 1*8kB 1*16kB 0*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15900kB
[28106.757336] Node 0 DMA32: 27*4kB 46*8kB 15*16kB 170*32kB 2428*64kB 1505*128kB 894*256kB 427*512kB 377*1024kB 6*2048kB 2*4096kB = 1208204kB
[28106.758068] Node 0 Normal: 280*4kB 390*8kB 139*16kB 80*32kB 53*64kB 36*128kB 14*256kB 2*512kB 0*1024kB 1*2048kB 0*4096kB = 23680kB
[28106.758757] 369501 total pagecache pages
[28106.758950] 0 pages in swap cache
[28106.759131] Swap cache stats: add 0, delete 0, find 0/0
[28106.759388] Free swap  = 6127612kB
[28106.759558] Total swap = 6127612kB
[28106.779675] 1048560 pages RAM
[28106.779830] 47810 pages reserved
[28106.779996] 252000 pages shared
[28106.780169] 512980 pages non-shared
[28106.785199] sctp: Hash tables configured (established 26214 bind 26214)


it doesn't look like the hashtable allocation code has changed in ages, so I'm 
not sure why I've never triggered this before.

	Dave
