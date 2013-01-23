From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: tun mq failure
Date: Wed, 23 Jan 2013 12:05:16 +0200
Message-ID: <20130123100516.GB8108@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1530 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754690Ab3AWKzi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 05:55:38 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r0NA1hdd025827
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 05:01:44 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I see this with -rc3:

[531261.470349] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[531276.878261] openvpn: page allocation failure: order:7, mode:0x10c0d0
[531276.878270] Pid: 10421, comm: openvpn Tainted: G        W
3.8.0-rc3-mst #216
[531276.878274] Call Trace:
[531276.878289]  [<ffffffff8113c08b>] warn_alloc_failed+0xfb/0x180
[531276.878297]  [<ffffffff8113e9a0>] ? page_alloc_cpu_notify+0x60/0x60
[531276.878303]  [<ffffffff8113e9b6>] ? drain_local_pages+0x16/0x20
[531276.878312]  [<ffffffff810c3823>] ? on_each_cpu_mask+0x53/0x70
[531276.878318]  [<ffffffff8113f155>] __alloc_pages_nodemask+0x5a5/0x990
[531276.878329]  [<ffffffff8117c2b8>] alloc_pages_current+0xe8/0x200
[531276.878334]  [<ffffffff8113bf34>] __get_free_pages+0x14/0x50
[531276.878341]  [<ffffffff811856bf>] kmalloc_order_trace+0x3f/0xb0
[531276.878347]  [<ffffffff811888df>] __kmalloc+0x17f/0x190
[531276.878356]  [<ffffffff8154e7f5>] alloc_netdev_mqs+0x155/0x300
[531276.878395]  [<ffffffffa03761c0>] ? tun_chr_poll+0xf0/0xf0 [tun]
[531276.878420]  [<ffffffffa037904c>] __tun_chr_ioctl+0xa6c/0x1080 [tun]
[531276.878440]  [<ffffffffa0379694>] tun_chr_compat_ioctl+0x34/0x40
[tun]
[531276.878460]  [<ffffffff811e8cad>] compat_sys_ioctl+0x10d/0x1520
[531276.878468]  [<ffffffff81186f65>] ? kmem_cache_free+0x35/0x150
[531276.878476]  [<ffffffff811a2456>] ? final_putname+0x26/0x50
[531276.878487]  [<ffffffff810e51f3>] ? __audit_syscall_exit+0x1a3/0x2c0
[531276.878496]  [<ffffffff8165d72c>] sysenter_dispatch+0x7/0x21
[531276.878501] Mem-Info:
[531276.878505] Node 0 DMA per-cpu:
[531276.878513] CPU    0: hi:    0, btch:   1 usd:   0
[531276.878517] CPU    1: hi:    0, btch:   1 usd:   0
[531276.878522] CPU    2: hi:    0, btch:   1 usd:   0
[531276.878526] CPU    3: hi:    0, btch:   1 usd:   0
[531276.878530] Node 0 DMA32 per-cpu:
[531276.878536] CPU    0: hi:  186, btch:  31 usd:   0
[531276.878540] CPU    1: hi:  186, btch:  31 usd:   0
[531276.878544] CPU    2: hi:  186, btch:  31 usd:   0
[531276.878549] CPU    3: hi:  186, btch:  31 usd:   0
[531276.878552] Node 0 Normal per-cpu:
[531276.878557] CPU    0: hi:  186, btch:  31 usd:   0
[531276.878561] CPU    1: hi:  186, btch:  31 usd:   0
[531276.878565] CPU    2: hi:  186, btch:  31 usd:   0
[531276.878570] CPU    3: hi:  186, btch:  31 usd:   0
[531276.878581] active_anon:295155 inactive_anon:139890 isolated_anon:0
[531276.878581]  active_file:698789 inactive_file:703169 isolated_file:0
[531276.878581]  unevictable:0 dirty:35015 writeback:105138 unstable:0
[531276.878581]  free:39426 slab_reclaimable:76276
slab_unreclaimable:41668
[531276.878581]  mapped:37045 shmem:141260 pagetables:4302 bounce:0
[531276.878581]  free_cma:0
[531276.878593] Node 0 DMA free:15880kB min:128kB low:160kB high:192kB
active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB
unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15640kB
managed:15896kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB
slab_reclaimable:0kB slab_unreclaimable:16kB kernel_stack:0kB
pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB
pages_scanned:0 all_unreclaimable? yes
[531276.878609] lowmem_reserve[]: 0 3423 7933 7933
[531276.878618] Node 0 DMA32 free:81400kB min:29104kB low:36380kB
high:43656kB active_anon:214676kB inactive_anon:50704kB
active_file:1489740kB inactive_file:1496792kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB present:3505444kB
managed:3465472kB mlocked:0kB dirty:61408kB writeback:132556kB
mapped:73704kB shmem:50844kB slab_reclaimable:115032kB
slab_unreclaimable:33400kB kernel_stack:112kB pagetables:1052kB
unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0
all_unreclaimable? no
[531276.878645] lowmem_reserve[]: 0 0 4510 4510
[531276.878700] Node 0 Normal free:60424kB min:38348kB low:47932kB
high:57520kB active_anon:965944kB inactive_anon:508856kB
active_file:1305416kB inactive_file:1315884kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB present:4618656kB
managed:4559280kB mlocked:0kB dirty:78652kB writeback:287996kB
mapped:74476kB shmem:514196kB slab_reclaimable:190072kB
slab_unreclaimable:133256kB kernel_stack:2920kB pagetables:16156kB
unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0
all_unreclaimable? no
[531276.878721] lowmem_reserve[]: 0 0 0 0
[531276.878730] Node 0 DMA: 0*4kB 1*8kB (U) 0*16kB 0*32kB 2*64kB (U)
1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) =
15880kB
[531276.878762] Node 0 DMA32: 1464*4kB (UEMR) 1824*8kB (UEMR) 1051*16kB
(UEM) 833*32kB (EM) 252*64kB (UEM) 5*128kB (UEM) 4*256kB (E) 0*512kB
0*1024kB 0*2048kB 0*4096kB = 81712kB
[531276.878794] Node 0 Normal: 5035*4kB (UEM) 1907*8kB (UEM) 999*16kB
(UEM) 253*32kB (UEM) 8*64kB (EM) 4*128kB (EM) 1*256kB (M) 0*512kB
0*1024kB 0*2048kB 0*4096kB = 60756kB
[531276.878825] 1543233 total pagecache pages
[531276.878829] 0 pages in swap cache
[531276.878834] Swap cache stats: add 0, delete 0, find 0/0
[531276.878837] Free swap  = 0kB
[531276.878841] Total swap = 0kB
[531276.899643] 2090480 pages RAM
[531276.899645] 75724 pages reserved
[531276.899646] 2248928 pages shared
[531276.899646] 974316 pages non-shared
[531276.899648] netdev: Unable to allocate 1024 tx queues


This is when trying to start a VPN using some old openvpn binary so MQ
is not set.

So
1. I think we should limit allocation of MQ to when MQ flag is set in SETIFF.
2. order 7 allocation is 2^^7 pages - about half a megabyte of contigious
   memory. This is quite likely to fail.
   Let's start with a small limit on number of queues, like 8?
   Then we know it will succeed.
   Longer term we might want to solve it differently.

-- 
MST
