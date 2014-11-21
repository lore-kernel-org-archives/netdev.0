From: Pranith Kumar <bobby.prani@gmail.com>
Subject: [PATCH v2 0/9] Replace smp_read_barrier_depends() with lockless_derefrence()
Date: Fri, 21 Nov 2014 10:05:54 -0500
Message-ID: <1416582363-20661-1-git-send-email-bobby.prani__48898.8674981103$1416582637$gmane$org@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Cristian Stoica <cristian.stoica@freescale.com>,
	Horia Geanta <horia.geanta@freescale.com>,
	Ruchika Gupta <ruchika.gupta@freescale.com>,
	Michael Neuling <mikey@neuling.org>,
	Wolfram Sang <wsa@the-dreams.de>,
	linux-crypto@vger.kernel.org (open list:CRYPTO API),
	linux-kernel@vger.kernel.org (open list),
	Vinod Koul <vinod.koul@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Kyungmin Park <kyungmin.park@samsung.com>,
	=?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>,
	Dave Jiang <dave.jiang@intel.com>,
	Rashika <rashika.kheria@gmail.com>,
	dmaengine@vger.kernel.org (open list:DMA GENERIC OFFLO...),
	"K. Y. Srinivasan" <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	devel@linuxdriverproject.org (open list:Hyp
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:46535 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754269AbaKUPGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 10:06:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently lockless_dereference() was added which can be used in place of
hard-coding smp_read_barrier_depends(). 

http://lkml.iu.edu/hypermail/linux/kernel/1410.3/04561.html

The following series tries to do this.

There are still some hard-coded locations which I was not sure how to replace
with. I will send in separate patches/questions regarding them.

Pranith Kumar (9):
  doc: memory-barriers.txt: Document use of lockless_dereference()
  drivers: dma: Replace smp_read_barrier_depends() with
    lockless_dereference()
  dcache: Replace smp_read_barrier_depends() with lockless_dereference()
  hyperv: Replace smp_read_barrier_depends() with lockless_dereference()
  percpu: Replace smp_read_barrier_depends() with lockless_dereference()
  perf: Replace smp_read_barrier_depends() with lockless_dereference()
  seccomp: Replace smp_read_barrier_depends() with
    lockless_dereference()
  task_work: Replace smp_read_barrier_depends() with
    lockless_dereference()
  netfilter: Replace smp_read_barrier_depends() with
    lockless_dereference()

 Documentation/memory-barriers.txt | 4 ++--
 drivers/dma/ioat/dma_v2.c         | 3 +--
 drivers/dma/ioat/dma_v3.c         | 3 +--
 fs/dcache.c                       | 7 ++-----
 include/linux/hyperv.h            | 9 ++++-----
 include/linux/percpu-refcount.h   | 4 +---
 kernel/events/core.c              | 3 +--
 kernel/events/uprobes.c           | 8 ++++----
 kernel/seccomp.c                  | 7 +++----
 kernel/task_work.c                | 3 +--
 net/ipv4/netfilter/arp_tables.c   | 3 +--
 net/ipv4/netfilter/ip_tables.c    | 3 +--
 net/ipv6/netfilter/ip6_tables.c   | 3 +--
 13 files changed, 23 insertions(+), 37 deletions(-)

-- 
1.9.1
