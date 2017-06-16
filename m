From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 27/44] sparc: remove leon_dma_ops
Date: Fri, 16 Jun 2017 20:10:42 +0200
Message-ID: <20170616181059.19206-28-hch@lst.de>
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
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20170616181059.19206-1-hch@lst.de>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We can just use pci32_dma_ops directly.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Acked-by: David S. Miller <davem@davemloft.net>
---
 arch/sparc/include/asm/dma-mapping.h | 3 +--
 arch/sparc/kernel/ioport.c           | 5 +----
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/arch/sparc/include/asm/dma-mapping.h b/arch/sparc/include/asm/dma-mapping.h
index b8e8dfcd065d..98da9f92c318 100644
--- a/arch/sparc/include/asm/dma-mapping.h
+++ b/arch/sparc/include/asm/dma-mapping.h
@@ -17,7 +17,6 @@ static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
 }
 
 extern const struct dma_map_ops *dma_ops;
-extern const struct dma_map_ops *leon_dma_ops;
 extern const struct dma_map_ops pci32_dma_ops;
 
 extern struct bus_type pci_bus_type;
@@ -26,7 +25,7 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 {
 #ifdef CONFIG_SPARC_LEON
 	if (sparc_cpu_model == sparc_leon)
-		return leon_dma_ops;
+		return &pci32_dma_ops;
 #endif
 #if defined(CONFIG_SPARC32) && defined(CONFIG_PCI)
 	if (bus == &pci_bus_type)
diff --git a/arch/sparc/kernel/ioport.c b/arch/sparc/kernel/ioport.c
index cf20033a1458..dd081d557609 100644
--- a/arch/sparc/kernel/ioport.c
+++ b/arch/sparc/kernel/ioport.c
@@ -637,6 +637,7 @@ static void pci32_sync_sg_for_device(struct device *device, struct scatterlist *
 	}
 }
 
+/* note: leon re-uses pci32_dma_ops */
 const struct dma_map_ops pci32_dma_ops = {
 	.alloc			= pci32_alloc_coherent,
 	.free			= pci32_free_coherent,
@@ -651,10 +652,6 @@ const struct dma_map_ops pci32_dma_ops = {
 };
 EXPORT_SYMBOL(pci32_dma_ops);
 
-/* leon re-uses pci32_dma_ops */
-const struct dma_map_ops *leon_dma_ops = &pci32_dma_ops;
-EXPORT_SYMBOL(leon_dma_ops);
-
 const struct dma_map_ops *dma_ops = &sbus_dma_ops;
 EXPORT_SYMBOL(dma_ops);
 
-- 
2.11.0

