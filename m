From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 39/44] xen-swiotlb: remove xen_swiotlb_set_dma_mask
Date: Fri, 16 Jun 2017 20:10:54 +0200
Message-ID: <20170616181059.19206-40-hch@lst.de>
References: <20170616181059.19206-1-hch@lst.de>
Cc: linux-kernel@vger.kernel.org
To: x86@kernel.org, linux-arm-kernel@lists.infradead.org,
        xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org,
        linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org,
        linux-mips@linux-mips.org, openrisc@lists.librecores.org,
        linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org,
        linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org,
        linux-samsung-soc@vger.kernel.org,
        iommu@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170616181059.19206-1-hch@lst.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This just duplicates the generic implementation.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/xen/swiotlb-xen.c | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/drivers/xen/swiotlb-xen.c b/drivers/xen/swiotlb-xen.c
index c3a04b2d7532..82fc54f8eb77 100644
--- a/drivers/xen/swiotlb-xen.c
+++ b/drivers/xen/swiotlb-xen.c
@@ -661,17 +661,6 @@ xen_swiotlb_dma_supported(struct device *hwdev, u64 mask)
 	return xen_virt_to_bus(xen_io_tlb_end - 1) <= mask;
 }
 
-static int
-xen_swiotlb_set_dma_mask(struct device *dev, u64 dma_mask)
-{
-	if (!dev->dma_mask || !xen_swiotlb_dma_supported(dev, dma_mask))
-		return -EIO;
-
-	*dev->dma_mask = dma_mask;
-
-	return 0;
-}
-
 /*
  * Create userspace mapping for the DMA-coherent memory.
  * This function should be called with the pages from the current domain only,
@@ -734,7 +723,6 @@ const struct dma_map_ops xen_swiotlb_dma_ops = {
 	.map_page = xen_swiotlb_map_page,
 	.unmap_page = xen_swiotlb_unmap_page,
 	.dma_supported = xen_swiotlb_dma_supported,
-	.set_dma_mask = xen_swiotlb_set_dma_mask,
 	.mmap = xen_swiotlb_dma_mmap,
 	.get_sgtable = xen_swiotlb_get_sgtable,
 	.mapping_error	= xen_swiotlb_mapping_error,
-- 
2.11.0
