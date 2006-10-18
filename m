From: Andi Kleen <ak@suse.de>
Subject: 2.6.19rc2 XFRM does too large direct mapping allocations for hashes
Date: Wed, 18 Oct 2006 13:50:22 +0200
Message-ID: <200610181350.22049.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:38557 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1030247AbWJRLu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 07:50:27 -0400
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id C861D20CD1
	for <netdev@vger.kernel.org>; Wed, 18 Oct 2006 13:50:25 +0200 (CEST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I got this while restarting ipsec on a 2.6.19rc2 system that was
up for a few days.

Order 8 is really a bit big to get from the direct mapping after
boot.

Should the hash allocation fall back to vmalloc?

-Andi

Initializing XFRM netlink socket
events/0: page allocation failure. order:8, mode:0xd0

Call Trace:
 [<ffffffff8024be30>] __alloc_pages+0x297/0x2ae
 [<ffffffff804a3127>] xfrm_hash_resize+0x0/0x27e
 [<ffffffff8024c301>] __get_free_pages+0x33/0x6d
 [<ffffffff804a4a21>] xfrm_hash_alloc+0x56/0x6d
 [<ffffffff804a3185>] xfrm_hash_resize+0x5e/0x27e
 [<ffffffff804a3127>] xfrm_hash_resize+0x0/0x27e
 [<ffffffff802369ca>] run_workqueue+0x92/0xe3
 [<ffffffff80236ab9>] worker_thread+0x0/0x119
 [<ffffffff80236ba0>] worker_thread+0xe7/0x119
 [<ffffffff80224a6e>] default_wake_function+0x0/0xe
 [<ffffffff80239900>] kthread+0xcb/0xf5
 [<ffffffff8020a1c5>] child_rip+0xa/0x15
 [<ffffffff80239835>] kthread+0x0/0xf5
 [<ffffffff8020a1bb>] child_rip+0x0/0x15

Mem-info:
DMA per-cpu:
CPU    0: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd:   0
CPU    1: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: Hot: hi:  186, btch:  31 usd: 168   Cold: hi:   62, btch:  15 usd:  51
CPU    1: Hot: hi:  186, btch:  31 usd:  14   Cold: hi:   62, btch:  15 usd:  58
Active:293384 inactive:157186 Initializing XFRM netlink socket
events/0: page allocation failure. order:8, mode:0xd0

Call Trace:
 [<ffffffff8024be30>] __alloc_pages+0x297/0x2ae
 [<ffffffff804a3127>] xfrm_hash_resize+0x0/0x27e
 [<ffffffff8024c301>] __get_free_pages+0x33/0x6d
 [<ffffffff804a4a21>] xfrm_hash_alloc+0x56/0x6d
 [<ffffffff804a3185>] xfrm_hash_resize+0x5e/0x27e
 [<ffffffff804a3127>] xfrm_hash_resize+0x0/0x27e
 [<ffffffff802369ca>] run_workqueue+0x92/0xe3
 [<ffffffff80236ab9>] worker_thread+0x0/0x119
 [<ffffffff80236ba0>] worker_thread+0xe7/0x119
 [<ffffffff80224a6e>] default_wake_function+0x0/0xe
 [<ffffffff80239900>] kthread+0xcb/0xf5
 [<ffffffff8020a1c5>] child_rip+0xa/0x15
 [<ffffffff80239835>] kthread+0x0/0xf5
 [<ffffffff8020a1bb>] child_rip+0x0/0x15

Mem-info:
DMA per-cpu:
CPU    0: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd:   0
CPU    1: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: Hot: hi:  186, btch:  31 usd: 168   Cold: hi:   62, btch:  15 usd:  51
CPU    1: Hot: hi:  186, btch:  31 usd:  14   Cold: hi:   62, btch:  15 usd:  58
Active:293384 inactive:157186 dirty:94 writeback:0 unstable:0 free:10372 slab:46328 mapped:18292 pagetables:1952
DMA free:8040kB min:28kB low:32kB high:40kB active:2720kB inactive:40kB present:10396kB pages_scanned:32 all_unreclaimable? no
lowmem_reserve[]: 0 2002 2002
DMA32 free:33448kB min:5708kB low:7132kB high:8560kB active:1170816kB inactive:628704kB present:2050208kB pages_scanned:152 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 0*4kB 1*8kB 0*16kB 1*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 8040kB
DMA32: 6862*4kB 260*8kB 41*16kB 18*32kB 10*64kB 2*128kB 1*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 33448kB
Swap cache: add 92, delete 92, find 27/32, race 0+0
Free swap  = 987988kB
Total swap = 987988kB
Free swap:       987988kB
524032 pages of RAM
9689 reserved pages
260692 pages shared
0 pages swap cached
events/0: page allocation failure. order:8, mode:0xd0
dirty:94 writeback:0 unstable:0 free:10372 slab:46328 mapped:18292 pagetables:1952
DMA free:8040kB min:28kB low:32kB high:40kB active:2720kB inactive:40kB present:10396kB pages_scanned:32 all_unreclaimable? no
lowmem_reserve[]: 0 2002 2002
DMA32 free:33448kB min:5708kB low:7132kB high:8560kB active:1170816kB inactive:628704kB present:2050208kB pages_scanned:152 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 0*4kB 1*8kB 0*16kB 1*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 8040kB
DMA32: 6862*4kB 260*8kB 41*16kB 18*32kB 10*64kB 2*128kB 1*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 33448kB
Swap cache: add 92, delete 92, find 27/32, race 0+0
Free swap  = 987988kB
Total swap = 987988kB
Free swap:       987988kB
524032 pages of RAM
9689 reserved pages
260692 pages shared
0 pages swap cached
events/0: page allocation failure. order:8, mode:0xd0

... repeated a few times with the same backtrace ...
