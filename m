From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH/RFC] dma-mapping: Provide dummy set_dma_ops() for NO_DMA=y
Date: Sun,  9 Jul 2017 21:33:45 +0200
Message-ID: <1499628825-16260-1-git-send-email-geert@linux-m68k.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert@linux-m68k.org>
To: Christoph Hellwig <hch@lst.de>,
        Marek Szyprowski <m.szyprowski@samsung.com>,
        Robin Murphy <robin.murphy@arm.com>,
        Madalin Bucur <madalin.bucur@nxp.com>,
        "David S . Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adding a dummy for set_dma_ops() allows to compile (sub)drivers that
don't actually use the DMA API, but propagate DMA ops configuration to a
second driver that may or may not use the DMA API.  Of course the second
driver does have to depend on HAS_DMA if it uses the DMA API.

An example is commit 5567e989198b5a8d ("fsl/fman: propagate dma_ops").

This allows to revert commit 85688d9adf685572 ("fsl/fman: add dependency
on HAS_DMA").

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 include/linux/dma-mapping.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 843ab866e0f487c2..0ab244b954418e2b 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -194,6 +194,8 @@ static inline const struct dma_map_ops *get_dma_ops(struct device *dev)
 {
 	return &bad_dma_ops;
 }
+static inline void set_dma_ops(struct device *dev,
+			       const struct dma_map_ops *dma_ops) {}
 #endif
 
 static inline dma_addr_t dma_map_single_attrs(struct device *dev, void *ptr,
-- 
2.7.4
