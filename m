From: Justin Piszcz <jpiszcz@lucidpixels.com>
Subject: 3.1.0-rc2: irq/112-eth0-Tx: page allocation failure: (w/frame pointers
 enabled)
Date: Fri, 26 Aug 2011 08:14:12 -0400 (EDT)
Message-ID: <alpine.DEB.2.02.1108260802590.14539@p34.internal.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: netdev@vger.kernel.org, Alan Piszcz <ap@solarrain.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Why does this occur on a machine with 48GB of memory (used mainly as a router)
and backup server, is it a kernel bug?

top - 08:12:19 up 8 days, 21 min, 73 users,  load average: 0.05, 0.10, 0.15
Tasks: 604 total,   1 running, 603 sleeping,   0 stopped,   0 zombie
Cpu(s):  1.4%us,  1.0%sy,  0.1%ni, 97.0%id,  0.4%wa,  0.0%hi,  0.1%si,  0.0%st
Mem:  49556624k total, 49038776k used,   517848k free,   619836k buffers
Swap:  2097148k total,   489076k used,  1608072k free, 36790936k cached


Kernel messages:

[687946.708409] irq/112-eth0-Tx: page allocation failure: order:1, mode:0x20
[687946.711519] Pid: 18665, comm: irq/112-eth0-Tx Not tainted 3.1.0-rc2 #1
[687946.714289] Call Trace:
[687946.716759]  <IRQ>  [<ffffffff8108673e>] warn_alloc_failed+0xee/0x140
[687946.719998]  [<ffffffff8108970c>] __alloc_pages_nodemask+0x54c/0x770
[687946.722422]  [<ffffffff810b8d8d>] kmem_getpages+0x5d/0x160
[687946.724869]  [<ffffffff810b9f4e>] fallback_alloc+0x1be/0x1d0
[687946.727044]  [<ffffffff810b9c2e>] ? cache_grow+0x26e/0x290
[687946.729379]  [<ffffffff810b9cdc>] ____cache_alloc_node+0x8c/0x140
[687946.731666]  [<ffffffff810ba413>] kmem_cache_alloc+0xa3/0xf0
[687946.733784]  [<ffffffff814b3bec>] sk_prot_alloc.isra.40+0x3c/0x180
[687946.735996]  [<ffffffff814b3dc9>] sk_clone+0x19/0x2d0
[687946.738418]  [<ffffffff81508453>] inet_csk_clone+0x13/0xb0
[687946.740798]  [<ffffffff81520144>] tcp_create_openreq_child+0x24/0x490
[687946.743286]  [<ffffffff8151d307>] tcp_v4_syn_recv_sock+0x47/0x270
[687946.746065]  [<ffffffff8151ff46>] tcp_check_req+0x2d6/0x4b0
[687946.748966]  [<ffffffff8151d1ba>] tcp_v4_do_rcv+0x1aa/0x2b0
[687946.751572]  [<ffffffff8151f704>] tcp_v4_rcv+0x5d4/0x8d0
[687946.754272]  [<ffffffff814fe5e5>] ip_local_deliver_finish+0xc5/0x200
[687946.756948]  [<ffffffff814fe8d8>] ip_local_deliver+0x88/0x90
[687946.759554]  [<ffffffff814fe331>] ip_rcv_finish+0x121/0x310
[687946.762137]  [<ffffffff814feace>] ip_rcv+0x1ee/0x2b0
[687946.764603]  [<ffffffff8158fa66>] ? packet_rcv_spkt+0x136/0x180
[687946.767380]  [<ffffffff814c2572>] __netif_receive_skb+0x4b2/0x5a0
[687946.769913]  [<ffffffff814c2848>] netif_receive_skb+0x78/0x80
[687946.772275]  [<ffffffff814c2cd8>] ? dev_gro_receive+0x1b8/0x2c0
[687946.775044]  [<ffffffff814c33c8>] napi_skb_finish+0x48/0x60
[687946.777626]  [<ffffffff814c348d>] napi_gro_receive+0xad/0xc0
[687946.780175]  [<ffffffff8141b8f7>] igb_poll+0x707/0xd60
[687946.782682]  [<ffffffff812ed7e4>] ? timerqueue_add+0x74/0xc0
[687946.785204]  [<ffffffff8102ece0>] ? enqueue_task_rt+0x150/0x280
[687946.787789]  [<ffffffff814c2a99>] net_rx_action+0x109/0x190
[687946.790282]  [<ffffffff8102dead>] ? enqueue_task+0x3d/0x80
[687946.792884]  [<ffffffff8103d1c8>] __do_softirq+0x98/0x120
[687946.795446]  [<ffffffff81071680>] ? irq_thread_fn+0x50/0x50
[687946.798037]  [<ffffffff815d1f6c>] call_softirq+0x1c/0x30
[687946.800530]  <EOI>  [<ffffffff81003abd>] do_softirq+0x4d/0x80
[687946.803066]  [<ffffffff8103cf3c>] local_bh_enable+0x8c/0xa0
[687946.805471]  [<ffffffff810716be>] irq_forced_thread_fn+0x3e/0x50
[687946.807945]  [<ffffffff810715a7>] irq_thread+0x157/0x1e0
[687946.810228]  [<ffffffff81071450>] ? irq_finalize_oneshot+0x120/0x120
[687946.812385]  [<ffffffff81052277>] kthread+0x87/0x90
[687946.814488]  [<ffffffff815d1e74>] kernel_thread_helper+0x4/0x10
[687946.816581]  [<ffffffff810521f0>] ? kthread_worker_fn+0x130/0x130
[687946.819500]  [<ffffffff815d1e70>] ? gs_change+0xb/0xb
[687946.821890] Mem-Info:
[687946.824226] Node 0 DMA per-cpu:
[687946.826667] CPU    0: hi:    0, btch:   1 usd:   0
[687946.829035] CPU    1: hi:    0, btch:   1 usd:   0
[687946.831210] CPU    2: hi:    0, btch:   1 usd:   0
[687946.833331] CPU    3: hi:    0, btch:   1 usd:   0
[687946.835359] CPU    4: hi:    0, btch:   1 usd:   0
[687946.837274] CPU    5: hi:    0, btch:   1 usd:   0
[687946.839086] CPU    6: hi:    0, btch:   1 usd:   0
[687946.839088] CPU    7: hi:    0, btch:   1 usd:   0
[687946.839089] CPU    8: hi:    0, btch:   1 usd:   0
[687946.839090] CPU    9: hi:    0, btch:   1 usd:   0
[687946.839093] CPU   10: hi:    0, btch:   1 usd:   0
[687946.839095] CPU   11: hi:    0, btch:   1 usd:   0
[687946.839128] CPU   12: hi:    0, btch:   1 usd:   0
[687946.839129] CPU   13: hi:    0, btch:   1 usd:   0
[687946.839131] CPU   14: hi:    0, btch:   1 usd:   0
[687946.839132] CPU   15: hi:    0, btch:   1 usd:   0
[687946.839134] CPU   16: hi:    0, btch:   1 usd:   0
[687946.839135] CPU   17: hi:    0, btch:   1 usd:   0
[687946.839136] CPU   18: hi:    0, btch:   1 usd:   0
[687946.839138] CPU   19: hi:    0, btch:   1 usd:   0
[687946.839139] CPU   20: hi:    0, btch:   1 usd:   0
[687946.839141] CPU   21: hi:    0, btch:   1 usd:   0
[687946.839142] CPU   22: hi:    0, btch:   1 usd:   0
[687946.839143] CPU   23: hi:    0, btch:   1 usd:   0
[687946.839144] Node 0 DMA32 per-cpu:
[687946.839146] CPU    0: hi:  186, btch:  31 usd: 104
[687946.839147] CPU    1: hi:  186, btch:  31 usd: 183
[687946.839149] CPU    2: hi:  186, btch:  31 usd:  35
[687946.839150] CPU    3: hi:  186, btch:  31 usd: 189
[687946.839152] CPU    4: hi:  186, btch:  31 usd:  26
[687946.839153] CPU    5: hi:  186, btch:  31 usd: 171
[687946.839154] CPU    6: hi:  186, btch:  31 usd:   7
[687946.839156] CPU    7: hi:  186, btch:  31 usd: 151
[687946.839157] CPU    8: hi:  186, btch:  31 usd:  24
[687946.839158] CPU    9: hi:  186, btch:  31 usd: 159
[687946.839160] CPU   10: hi:  186, btch:  31 usd:   0
[687946.839161] CPU   11: hi:  186, btch:  31 usd:   0
[687946.839162] CPU   12: hi:  186, btch:  31 usd: 161
[687946.839164] CPU   13: hi:  186, btch:  31 usd: 166
[687946.839165] CPU   14: hi:  186, btch:  31 usd: 162
[687946.839166] CPU   15: hi:  186, btch:  31 usd: 166
[687946.839168] CPU   16: hi:  186, btch:  31 usd:  60
[687946.839169] CPU   17: hi:  186, btch:  31 usd: 160
[687946.839170] CPU   18: hi:  186, btch:  31 usd:   1
[687946.839172] CPU   19: hi:  186, btch:  31 usd:   0
[687946.839173] CPU   20: hi:  186, btch:  31 usd:   0
[687946.839174] CPU   21: hi:  186, btch:  31 usd: 127
[687946.839176] CPU   22: hi:  186, btch:  31 usd:   0
[687946.839177] CPU   23: hi:  186, btch:  31 usd: 185
[687946.839178] Node 0 Normal per-cpu:
[687946.839179] CPU    0: hi:  186, btch:  31 usd:   7
[687946.839181] CPU    1: hi:  186, btch:  31 usd: 149
[687946.839182] CPU    2: hi:  186, btch:  31 usd:  22
[687946.839183] CPU    3: hi:  186, btch:  31 usd: 117
[687946.839185] CPU    4: hi:  186, btch:  31 usd: 101
[687946.839186] CPU    5: hi:  186, btch:  31 usd: 171
[687946.839188] CPU    6: hi:  186, btch:  31 usd:  56
[687946.839189] CPU    7: hi:  186, btch:  31 usd:  95
[687946.839190] CPU    8: hi:  186, btch:  31 usd:  51
[687946.839192] CPU    9: hi:  186, btch:  31 usd: 157
[687946.839193] CPU   10: hi:  186, btch:  31 usd:   0
[687946.839195] CPU   11: hi:  186, btch:  31 usd:  13
[687946.839196] CPU   12: hi:  186, btch:  31 usd:  33
[687946.839197] CPU   13: hi:  186, btch:  31 usd: 168
[687946.839199] CPU   14: hi:  186, btch:  31 usd: 176
[687946.839200] CPU   15: hi:  186, btch:  31 usd: 156
[687946.839202] CPU   16: hi:  186, btch:  31 usd: 124
[687946.839203] CPU   17: hi:  186, btch:  31 usd:  38
[687946.839204] CPU   18: hi:  186, btch:  31 usd:  22
[687946.839206] CPU   19: hi:  186, btch:  31 usd: 103
[687946.839207] CPU   20: hi:  186, btch:  31 usd:  32
[687946.839209] CPU   21: hi:  186, btch:  31 usd: 185
[687946.839210] CPU   22: hi:  186, btch:  31 usd:  48
[687946.839211] CPU   23: hi:  186, btch:  31 usd: 145
[687946.839213] Node 1 Normal per-cpu:
[687946.839214] CPU    0: hi:  186, btch:  31 usd:  93
[687946.839216] CPU    1: hi:  186, btch:  31 usd:  77
[687946.839217] CPU    2: hi:  186, btch:  31 usd:  40
[687946.839218] CPU    3: hi:  186, btch:  31 usd: 165
[687946.839220] CPU    4: hi:  186, btch:  31 usd:   4
[687946.839221] CPU    5: hi:  186, btch:  31 usd: 180
[687946.839222] CPU    6: hi:  186, btch:  31 usd:  29
[687946.839224] CPU    7: hi:  186, btch:  31 usd:  83
[687946.839225] CPU    8: hi:  186, btch:  31 usd:  78
[687946.839227] CPU    9: hi:  186, btch:  31 usd: 163
[687946.839228] CPU   10: hi:  186, btch:  31 usd: 171
[687946.839230] CPU   11: hi:  186, btch:  31 usd: 167
[687946.839231] CPU   12: hi:  186, btch:  31 usd:  21
[687946.839232] CPU   13: hi:  186, btch:  31 usd:  27
[687946.839234] CPU   14: hi:  186, btch:  31 usd:  30
[687946.839235] CPU   15: hi:  186, btch:  31 usd: 180
[687946.839236] CPU   16: hi:  186, btch:  31 usd:   4
[687946.839238] CPU   17: hi:  186, btch:  31 usd:  17
[687946.839239] CPU   18: hi:  186, btch:  31 usd:  83
[687946.839241] CPU   19: hi:  186, btch:  31 usd: 126
[687946.839242] CPU   20: hi:  186, btch:  31 usd: 161
[687946.839244] CPU   21: hi:  186, btch:  31 usd: 157
[687946.839245] CPU   22: hi:  186, btch:  31 usd: 172
[687946.839246] CPU   23: hi:  186, btch:  31 usd: 113
[687946.839250] active_anon:2415853 inactive_anon:207634 isolated_anon:0
[687946.839251]  active_file:4112085 inactive_file:4489987 isolated_file:33
[687946.839252]  unevictable:0 dirty:4489 writeback:0 unstable:0
[687946.839253]  free:137513 slab_reclaimable:852856 slab_unreclaimable:39114
[687946.839254]  mapped:15723 shmem:5214 pagetables:15849 bounce:0
[687946.839255] Node 0 DMA free:15896kB min:56kB low:68kB high:84kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15672kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[687946.839262] lowmem_reserve[]: 0 2991 24201 24201
[687946.839264] Node 0 DMA32 free:133556kB min:11124kB low:13904kB high:16684kB active_anon:509940kB inactive_anon:138796kB active_file:732776kB inactive_file:1063388kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3063520kB mlocked:0kB dirty:152kB writeback:0kB mapped:1472kB shmem:120kB slab_reclaimable:435724kB slab_unreclaimable:8988kB kernel_stack:320kB pagetables:1132kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[687946.839272] lowmem_reserve[]: 0 0 21210 21210
[687946.839274] Node 0 Normal free:215052kB min:78884kB low:98604kB high:118324kB active_anon:4096588kB inactive_anon:322760kB active_file:7572688kB inactive_file:7578964kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:21719040kB mlocked:0kB dirty:12488kB writeback:0kB mapped:29660kB shmem:15064kB slab_reclaimable:1546068kB slab_unreclaimable:78700kB kernel_stack:3480kB pagetables:35252kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[687946.839282] lowmem_reserve[]: 0 0 0 0
[687946.839283] Node 1 Normal free:185548kB min:90152kB low:112688kB high:135228kB active_anon:5056884kB inactive_anon:368980kB active_file:8142876kB inactive_file:9317596kB unevictable:0kB isolated(anon):0kB isolated(file):132kB present:24821760kB mlocked:0kB dirty:5316kB writeback:0kB mapped:31760kB shmem:5672kB slab_reclaimable:1429632kB slab_unreclaimable:68768kB kernel_stack:2648kB pagetables:27012kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[687946.839292] lowmem_reserve[]: 0 0 0 0
[687946.839294] Node 0 DMA: 0*4kB 1*8kB 1*16kB 0*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15896kB
[687946.839299] Node 0 DMA32: 31847*4kB 718*8kB 8*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 133260kB
[687946.839304] Node 0 Normal: 38479*4kB 5294*8kB 1090*16kB 11*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 214060kB
[687946.839309] Node 1 Normal: 29327*4kB 5080*8kB 910*16kB 102*32kB 19*64kB 11*128kB 26*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 185052kB
[687946.839314] 8618791 total pagecache pages
[687946.839315] 11459 pages in swap cache
[687946.839317] Swap cache stats: add 258693, delete 247234, find 26065392/26080490
[687946.839318] Free swap  = 1628596kB
[687946.839319] Total swap = 2097148kB
[687947.017273] 12582896 pages RAM
[687947.020203] 193740 pages reserved
[687947.023090] 3702079 pages shared
[687947.025938] 8692980 pages non-shared
[687949.743902] irq/112-eth0-Tx: page allocation failure: order:1, mode:0x20
[687949.746909] Pid: 18665, comm: irq/112-eth0-Tx Not tainted 3.1.0-rc2 #1
[687949.749718] Call Trace:
[687949.752521]  <IRQ>  [<ffffffff8108673e>] warn_alloc_failed+0xee/0x140
[687949.755407]  [<ffffffff8108970c>] __alloc_pages_nodemask+0x54c/0x770
[687949.758276]  [<ffffffff810b8d8d>] kmem_getpages+0x5d/0x160
[687949.761157]  [<ffffffff810b9f4e>] fallback_alloc+0x1be/0x1d0
[687949.764182]  [<ffffffff810b9c2e>] ? cache_grow+0x26e/0x290
[687949.767350]  [<ffffffff810b9cdc>] ____cache_alloc_node+0x8c/0x140
[687949.770514]  [<ffffffff810ba413>] kmem_cache_alloc+0xa3/0xf0
[687949.773699]  [<ffffffff814b3bec>] sk_prot_alloc.isra.40+0x3c/0x180
[687949.776947]  [<ffffffff814b3dc9>] sk_clone+0x19/0x2d0
[687949.780172]  [<ffffffff81508453>] inet_csk_clone+0x13/0xb0
[687949.783425]  [<ffffffff81520144>] tcp_create_openreq_child+0x24/0x490
[687949.786686]  [<ffffffff8151d307>] tcp_v4_syn_recv_sock+0x47/0x270
[687949.789977]  [<ffffffff8151ff46>] tcp_check_req+0x2d6/0x4b0
[687949.793264]  [<ffffffff8151d1ba>] tcp_v4_do_rcv+0x1aa/0x2b0
[687949.796565]  [<ffffffff8151f704>] tcp_v4_rcv+0x5d4/0x8d0
[687949.799867]  [<ffffffff814fe5e5>] ip_local_deliver_finish+0xc5/0x200
[687949.803162]  [<ffffffff814fe8d8>] ip_local_deliver+0x88/0x90
[687949.806463]  [<ffffffff814fe331>] ip_rcv_finish+0x121/0x310
[687949.809779]  [<ffffffff814feace>] ip_rcv+0x1ee/0x2b0
[687949.813105]  [<ffffffff8158fa66>] ? packet_rcv_spkt+0x136/0x180
[687949.816446]  [<ffffffff814c2572>] __netif_receive_skb+0x4b2/0x5a0
[687949.819794]  [<ffffffff814c2848>] netif_receive_skb+0x78/0x80
[687949.823157]  [<ffffffff814c2cd8>] ? dev_gro_receive+0x1b8/0x2c0
[687949.826529]  [<ffffffff814c33c8>] napi_skb_finish+0x48/0x60
[687949.829918]  [<ffffffff814c348d>] napi_gro_receive+0xad/0xc0
[687949.833315]  [<ffffffff8141b8f7>] igb_poll+0x707/0xd60
[687949.833324]  [<ffffffff8101db39>] ? physflat_send_IPI_mask+0x9/0x10
[687949.833330]  [<ffffffff8102ece0>] ? enqueue_task_rt+0x150/0x280
[687949.833338]  [<ffffffff814c2a99>] net_rx_action+0x109/0x190
[687949.833342]  [<ffffffff8102dead>] ? enqueue_task+0x3d/0x80
[687949.833348]  [<ffffffff8103d1c8>] __do_softirq+0x98/0x120
[687949.833353]  [<ffffffff81071680>] ? irq_thread_fn+0x50/0x50
[687949.833359]  [<ffffffff815d1f6c>] call_softirq+0x1c/0x30
[687949.833361]  <EOI>  [<ffffffff81003abd>] do_softirq+0x4d/0x80
[687949.833369]  [<ffffffff8103cf3c>] local_bh_enable+0x8c/0xa0
[687949.833372]  [<ffffffff810716be>] irq_forced_thread_fn+0x3e/0x50
[687949.833375]  [<ffffffff810715a7>] irq_thread+0x157/0x1e0
[687949.833379]  [<ffffffff81071450>] ? irq_finalize_oneshot+0x120/0x120
[687949.833384]  [<ffffffff81052277>] kthread+0x87/0x90
[687949.833388]  [<ffffffff815d1e74>] kernel_thread_helper+0x4/0x10
[687949.833392]  [<ffffffff810521f0>] ? kthread_worker_fn+0x130/0x130
[687949.833395]  [<ffffffff815d1e70>] ? gs_change+0xb/0xb
[687949.833398] Mem-Info:
[687949.833400] Node 0 DMA per-cpu:
[687949.833402] CPU    0: hi:    0, btch:   1 usd:   0
[687949.833405] CPU    1: hi:    0, btch:   1 usd:   0
[687949.833407] CPU    2: hi:    0, btch:   1 usd:   0
[687949.833409] CPU    3: hi:    0, btch:   1 usd:   0
[687949.833411] CPU    4: hi:    0, btch:   1 usd:   0
[687949.833413] CPU    5: hi:    0, btch:   1 usd:   0
[687949.833415] CPU    6: hi:    0, btch:   1 usd:   0
[687949.833417] CPU    7: hi:    0, btch:   1 usd:   0
[687949.833419] CPU    8: hi:    0, btch:   1 usd:   0
[687949.833421] CPU    9: hi:    0, btch:   1 usd:   0
[687949.833423] CPU   10: hi:    0, btch:   1 usd:   0
[687949.833425] CPU   11: hi:    0, btch:   1 usd:   0
[687949.833427] CPU   12: hi:    0, btch:   1 usd:   0
[687949.833429] CPU   13: hi:    0, btch:   1 usd:   0
[687949.833432] CPU   14: hi:    0, btch:   1 usd:   0
[687949.833434] CPU   15: hi:    0, btch:   1 usd:   0
[687949.833436] CPU   16: hi:    0, btch:   1 usd:   0
[687949.833438] CPU   17: hi:    0, btch:   1 usd:   0
[687949.833440] CPU   18: hi:    0, btch:   1 usd:   0
[687949.833442] CPU   19: hi:    0, btch:   1 usd:   0
[687949.833444] CPU   20: hi:    0, btch:   1 usd:   0
[687949.833446] CPU   21: hi:    0, btch:   1 usd:   0
[687949.833448] CPU   22: hi:    0, btch:   1 usd:   0
[687949.833450] CPU   23: hi:    0, btch:   1 usd:   0
[687949.833451] Node 0 DMA32 per-cpu:
[687949.833454] CPU    0: hi:  186, btch:  31 usd:  31
[687949.833456] CPU    1: hi:  186, btch:  31 usd: 177
[687949.833458] CPU    2: hi:  186, btch:  31 usd:  44
[687949.833460] CPU    3: hi:  186, btch:  31 usd: 186
[687949.833462] CPU    4: hi:  186, btch:  31 usd:  26
[687949.833465] CPU    5: hi:  186, btch:  31 usd: 161
[687949.833467] CPU    6: hi:  186, btch:  31 usd:  19
[687949.833469] CPU    7: hi:  186, btch:  31 usd: 120
[687949.833471] CPU    8: hi:  186, btch:  31 usd:  24
[687949.833473] CPU    9: hi:  186, btch:  31 usd: 129
[687949.833475] CPU   10: hi:  186, btch:  31 usd:   0
[687949.833477] CPU   11: hi:  186, btch:  31 usd:   0
[687949.833479] CPU   12: hi:  186, btch:  31 usd: 159
[687949.833481] CPU   13: hi:  186, btch:  31 usd: 170
[687949.833483] CPU   14: hi:  186, btch:  31 usd: 181
[687949.833485] CPU   15: hi:  186, btch:  31 usd: 166
[687949.833488] CPU   16: hi:  186, btch:  31 usd:  60
[687949.833490] CPU   17: hi:  186, btch:  31 usd: 160
[687949.833492] CPU   18: hi:  186, btch:  31 usd:   1
[687949.833494] CPU   19: hi:  186, btch:  31 usd:   0
[687949.833496] CPU   20: hi:  186, btch:  31 usd:   0
[687949.833498] CPU   21: hi:  186, btch:  31 usd: 127
[687949.833500] CPU   22: hi:  186, btch:  31 usd:   0
[687949.833502] CPU   23: hi:  186, btch:  31 usd: 185
[687949.833503] Node 0 Normal per-cpu:
[687949.833505] CPU    0: hi:  186, btch:  31 usd:  43
[687949.833508] CPU    1: hi:  186, btch:  31 usd:  81
[687949.833510] CPU    2: hi:  186, btch:  31 usd:  51
[687949.833512] CPU    3: hi:  186, btch:  31 usd: 114
[687949.833514] CPU    4: hi:  186, btch:  31 usd:  95
[687949.833516] CPU    5: hi:  186, btch:  31 usd: 154
[687949.833518] CPU    6: hi:  186, btch:  31 usd: 108
[687949.833520] CPU    7: hi:  186, btch:  31 usd:  69
[687949.833522] CPU    8: hi:  186, btch:  31 usd:  22
[687949.833524] CPU    9: hi:  186, btch:  31 usd: 181
[687949.833526] CPU   10: hi:  186, btch:  31 usd: 174
[687949.833528] CPU   11: hi:  186, btch:  31 usd:   0
[687949.833530] CPU   12: hi:  186, btch:  31 usd: 157
[687949.833532] CPU   13: hi:  186, btch:  31 usd: 157
[687949.833534] CPU   14: hi:  186, btch:  31 usd: 110
[687949.833536] CPU   15: hi:  186, btch:  31 usd: 164
[687949.833538] CPU   16: hi:  186, btch:  31 usd: 114
[687949.833541] CPU   17: hi:  186, btch:  31 usd:  38
[687949.833543] CPU   18: hi:  186, btch:  31 usd:   0
[687949.833545] CPU   19: hi:  186, btch:  31 usd:  72
[687949.833547] CPU   20: hi:  186, btch:  31 usd:   1
[687949.833549] CPU   21: hi:  186, btch:  31 usd: 164
[687949.833551] CPU   22: hi:  186, btch:  31 usd:  55
[687949.833553] CPU   23: hi:  186, btch:  31 usd: 118
[687949.833554] Node 1 Normal per-cpu:
[687949.833557] CPU    0: hi:  186, btch:  31 usd:  64
[687949.833559] CPU    1: hi:  186, btch:  31 usd: 125
[687949.833561] CPU    2: hi:  186, btch:  31 usd:  56
[687949.833563] CPU    3: hi:  186, btch:  31 usd: 148
[687949.833565] CPU    4: hi:  186, btch:  31 usd:   0
[687949.833567] CPU    5: hi:  186, btch:  31 usd: 149
[687949.833569] CPU    6: hi:  186, btch:  31 usd: 151
[687949.833571] CPU    7: hi:  186, btch:  31 usd:  79
[687949.833573] CPU    8: hi:  186, btch:  31 usd:  61
[687949.833575] CPU    9: hi:  186, btch:  31 usd: 183
[687949.833577] CPU   10: hi:  186, btch:  31 usd: 171
[687949.833579] CPU   11: hi:  186, btch:  31 usd: 167
[687949.833581] CPU   12: hi:  186, btch:  31 usd: 174
[687949.833584] CPU   13: hi:  186, btch:  31 usd: 171
[687949.833586] CPU   14: hi:  186, btch:  31 usd: 158
[687949.833588] CPU   15: hi:  186, btch:  31 usd: 149
[687949.833590] CPU   16: hi:  186, btch:  31 usd:   6
[687949.833592] CPU   17: hi:  186, btch:  31 usd:  17
[687949.833594] CPU   18: hi:  186, btch:  31 usd:  82
[687949.833596] CPU   19: hi:  186, btch:  31 usd: 111
[687949.833598] CPU   20: hi:  186, btch:  31 usd: 159
[687949.833600] CPU   21: hi:  186, btch:  31 usd: 157
[687949.833602] CPU   22: hi:  186, btch:  31 usd: 160
[687949.833604] CPU   23: hi:  186, btch:  31 usd:  74
[687949.833610] active_anon:2415858 inactive_anon:207589 isolated_anon:0
[687949.833611]  active_file:4112461 inactive_file:4495431 isolated_file:0
[687949.833612]  unevictable:0 dirty:5362 writeback:0 unstable:0
[687949.833614]  free:135634 slab_reclaimable:847992 slab_unreclaimable:39054
[687949.833615]  mapped:15726 shmem:5214 pagetables:15849 bounce:0
[687949.833617] Node 0 DMA free:15896kB min:56kB low:68kB high:84kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15672kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[687949.833627] lowmem_reserve[]: 0 2991 24201 24201
[687949.833631] Node 0 DMA32 free:121756kB min:11124kB low:13904kB high:16684kB active_anon:509940kB inactive_anon:138796kB active_file:732776kB inactive_file:1077800kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3063520kB mlocked:0kB dirty:384kB writeback:0kB mapped:1472kB shmem:120kB slab_reclaimable:435700kB slab_unreclaimable:9008kB kernel_stack:320kB pagetables:1132kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[687949.833643] lowmem_reserve[]: 0 0 21210 21210
[687949.833645] Node 0 Normal free:178800kB min:78884kB low:98604kB high:118324kB active_anon:4096596kB inactive_anon:322580kB active_file:7573100kB inactive_file:7623984kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:21719040kB mlocked:0kB dirty:13852kB writeback:0kB mapped:29672kB shmem:15064kB slab_reclaimable:1532288kB slab_unreclaimable:78968kB kernel_stack:3480kB pagetables:35252kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[687949.833657] lowmem_reserve[]: 0 0 0 0
[687949.833660] Node 1 Normal free:226084kB min:90152kB low:112688kB high:135228kB active_anon:5056896kB inactive_anon:368980kB active_file:8143968kB inactive_file:9279940kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:24821760kB mlocked:0kB dirty:7212kB writeback:0kB mapped:31760kB shmem:5672kB slab_reclaimable:1423980kB slab_unreclaimable:68240kB kernel_stack:2648kB pagetables:27012kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[687949.833672] lowmem_reserve[]: 0 0 0 0
[687949.833674] Node 0 DMA: 0*4kB 1*8kB 1*16kB 0*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15896kB
[687949.833682] Node 0 DMA32: 28319*4kB 870*8kB 95*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 121756kB
[687949.833689] Node 0 Normal: 29680*4kB 4095*8kB 1649*16kB 27*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 178728kB
[687949.833697] Node 1 Normal: 39478*4kB 6538*8kB 637*16kB 111*32kB 9*64kB 7*128kB 4*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 226456kB
[687949.833704] 8624516 total pagecache pages
[687949.833706] 11462 pages in swap cache
[687949.833708] Swap cache stats: add 258724, delete 247262, find 26065393/26080492
[687949.833710] Free swap  = 1628508kB
[687949.833711] Total swap = 2097148kB
[687950.051707] 12582896 pages RAM
[687950.054637] 193740 pages reserved
[687950.057542] 3675896 pages shared
[687950.060450] 8720032 pages non-shared

Justin.
