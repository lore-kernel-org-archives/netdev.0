From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 38/44] arm: implement ->dma_supported instead of ->set_dma_mask
Date: Thu,  8 Jun 2017 15:26:03 +0200
Message-ID: <20170608132609.32662-39-hch@lst.de>
References: <20170608132609.32662-1-hch@lst.de>
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
In-Reply-To: <20170608132609.32662-1-hch@lst.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Same behavior, less code duplication.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/arm/common/dmabounce.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/arch/arm/common/dmabounce.c b/arch/arm/common/dmabounce.c
index 4aabf117e136..d89a0b56b245 100644
--- a/arch/arm/common/dmabounce.c
+++ b/arch/arm/common/dmabounce.c
@@ -445,12 +445,12 @@ static void dmabounce_sync_for_device(struct device *dev,
 	arm_dma_ops.sync_single_for_device(dev, handle, size, dir);
 }
 
-static int dmabounce_set_mask(struct device *dev, u64 dma_mask)
+static int dmabounce_dma_supported(struct device *dev, u64 dma_mask)
 {
 	if (dev->archdata.dmabounce)
 		return 0;
 
-	return arm_dma_ops.set_dma_mask(dev, dma_mask);
+	return arm_dma_ops.dma_supported(dev, dma_mask);
 }
 
 static int dmabounce_mapping_error(struct device *dev, dma_addr_t dma_addr)
@@ -474,9 +474,8 @@ static const struct dma_map_ops dmabounce_ops = {
 	.unmap_sg		= arm_dma_unmap_sg,
 	.sync_sg_for_cpu	= arm_dma_sync_sg_for_cpu,
 	.sync_sg_for_device	= arm_dma_sync_sg_for_device,
-	.set_dma_mask		= dmabounce_set_mask,
+	.dma_supported		= dmabounce_dma_supported,
 	.mapping_error		= dmabounce_mapping_error,
-	.dma_supported		= arm_dma_supported,
 };
 
 static int dmabounce_init_pool(struct dmabounce_pool *pool, struct device *dev,
-- 
2.11.0
