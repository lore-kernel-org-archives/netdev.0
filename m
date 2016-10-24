From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH RFC 03/26] arch/arc: Add option to skip sync on DMA
 mapping
Date: Mon, 24 Oct 2016 08:04:42 -0400
Message-ID: <20161024120442.16276.95329.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Vineet Gupta <vgupta@synopsys.com>,
        linux-snps-arc@lists.infradead.org, davem@davemloft.net,
        brouer@redhat.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39999 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758032AbcJXSFT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Oct 2016 14:05:19 -0400
In-Reply-To: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
avoid invoking cache line invalidation if the driver will just handle it
later via a sync_for_cpu or sync_for_device call.

Cc: Vineet Gupta <vgupta@synopsys.com>
Cc: linux-snps-arc@lists.infradead.org
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/arc/mm/dma.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/arc/mm/dma.c b/arch/arc/mm/dma.c
index 20afc65..d0c4b28 100644
--- a/arch/arc/mm/dma.c
+++ b/arch/arc/mm/dma.c
@@ -133,7 +133,8 @@ static dma_addr_t arc_dma_map_page(struct device *dev, struct page *page,
 		unsigned long attrs)
 {
 	phys_addr_t paddr = page_to_phys(page) + offset;
-	_dma_cache_sync(paddr, size, dir);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		_dma_cache_sync(paddr, size, dir);
 	return plat_phys_to_dma(dev, paddr);
 }
 
