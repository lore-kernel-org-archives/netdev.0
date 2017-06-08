From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 44/44] powerpc: merge __dma_set_mask into dma_set_mask
Date: Thu,  8 Jun 2017 15:26:09 +0200
Message-ID: <20170608132609.32662-45-hch@lst.de>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:41986 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751892AbdFHN3P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 09:29:15 -0400
In-Reply-To: <20170608132609.32662-1-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/include/asm/dma-mapping.h |  1 -
 arch/powerpc/kernel/dma.c              | 13 ++++---------
 2 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
index 73aedbe6c977..eaece3d3e225 100644
--- a/arch/powerpc/include/asm/dma-mapping.h
+++ b/arch/powerpc/include/asm/dma-mapping.h
@@ -112,7 +112,6 @@ static inline void set_dma_offset(struct device *dev, dma_addr_t off)
 #define HAVE_ARCH_DMA_SET_MASK 1
 extern int dma_set_mask(struct device *dev, u64 dma_mask);
 
-extern int __dma_set_mask(struct device *dev, u64 dma_mask);
 extern u64 __dma_get_required_mask(struct device *dev);
 
 static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
index 466c9f07b288..4194bbbbdb10 100644
--- a/arch/powerpc/kernel/dma.c
+++ b/arch/powerpc/kernel/dma.c
@@ -314,14 +314,6 @@ EXPORT_SYMBOL(dma_set_coherent_mask);
 
 #define PREALLOC_DMA_DEBUG_ENTRIES (1 << 16)
 
-int __dma_set_mask(struct device *dev, u64 dma_mask)
-{
-	if (!dev->dma_mask || !dma_supported(dev, dma_mask))
-		return -EIO;
-	*dev->dma_mask = dma_mask;
-	return 0;
-}
-
 int dma_set_mask(struct device *dev, u64 dma_mask)
 {
 	if (ppc_md.dma_set_mask)
@@ -334,7 +326,10 @@ int dma_set_mask(struct device *dev, u64 dma_mask)
 			return phb->controller_ops.dma_set_mask(pdev, dma_mask);
 	}
 
-	return __dma_set_mask(dev, dma_mask);
+	if (!dev->dma_mask || !dma_supported(dev, dma_mask))
+		return -EIO;
+	*dev->dma_mask = dma_mask;
+	return 0;
 }
 EXPORT_SYMBOL(dma_set_mask);
 
-- 
2.11.0
