From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 26/44] dma-mapping: remove DMA_ERROR_CODE
Date: Thu,  8 Jun 2017 15:25:51 +0200
Message-ID: <20170608132609.32662-27-hch@lst.de>
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
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20170608132609.32662-1-hch@lst.de>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

And update the documentation - dma_mapping_error has been supported
everywhere for a long time.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 Documentation/DMA-API-HOWTO.txt | 31 +++++--------------------------
 include/linux/dma-mapping.h     |  5 -----
 2 files changed, 5 insertions(+), 31 deletions(-)

diff --git a/Documentation/DMA-API-HOWTO.txt b/Documentation/DMA-API-HOWTO.txt
index 979228bc9035..4ed388356898 100644
--- a/Documentation/DMA-API-HOWTO.txt
+++ b/Documentation/DMA-API-HOWTO.txt
@@ -550,32 +550,11 @@ and to unmap it:
 	dma_unmap_single(dev, dma_handle, size, direction);
 
 You should call dma_mapping_error() as dma_map_single() could fail and return
-error. Not all DMA implementations support the dma_mapping_error() interface.
-However, it is a good practice to call dma_mapping_error() interface, which
-will invoke the generic mapping error check interface. Doing so will ensure
-that the mapping code will work correctly on all DMA implementations without
-any dependency on the specifics of the underlying implementation. Using the
-returned address without checking for errors could result in failures ranging
-from panics to silent data corruption. A couple of examples of incorrect ways
-to check for errors that make assumptions about the underlying DMA
-implementation are as follows and these are applicable to dma_map_page() as
-well.
-
-Incorrect example 1:
-	dma_addr_t dma_handle;
-
-	dma_handle = dma_map_single(dev, addr, size, direction);
-	if ((dma_handle & 0xffff != 0) || (dma_handle >= 0x1000000)) {
-		goto map_error;
-	}
-
-Incorrect example 2:
-	dma_addr_t dma_handle;
-
-	dma_handle = dma_map_single(dev, addr, size, direction);
-	if (dma_handle == DMA_ERROR_CODE) {
-		goto map_error;
-	}
+error.  Doing so will ensure that the mapping code will work correctly on all
+DMA implementations without any dependency on the specifics of the underlying
+implementation. Using the returned address without checking for errors could
+result in failures ranging from panics to silent data corruption.  The same
+applies to dma_map_page() as well.
 
 You should call dma_unmap_single() when the DMA activity is finished, e.g.,
 from the interrupt which told you that the DMA transfer is done.
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 4f3eecedca2d..a57875309bfd 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -546,12 +546,7 @@ static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 
 	if (get_dma_ops(dev)->mapping_error)
 		return get_dma_ops(dev)->mapping_error(dev, dma_addr);
-
-#ifdef DMA_ERROR_CODE
-	return dma_addr == DMA_ERROR_CODE;
-#else
 	return 0;
-#endif
 }
 
 #ifndef HAVE_ARCH_DMA_SUPPORTED
-- 
2.11.0

