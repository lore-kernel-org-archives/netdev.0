From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 14/15] pci: remove pci_dma_supported
Date: Sat,  3 Oct 2015 17:19:38 +0200
Message-ID: <1443885579-7094-15-git-send-email-hch@lst.de>
References: <1443885579-7094-1-git-send-email-hch@lst.de>
Cc: linux-net-drivers@solarflare.com, dri-devel@lists.freedesktop.org,
	linux-media@vger.kernel.org, netdev@vger.kernel.org,
	linux-parisc@vger.kernel.org, linux-serial@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Don Fry <pcnet32@frontier.com>,
	Oliver Neukum <oneukum@suse.com>
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <1443885579-7094-1-git-send-email-hch@lst.de>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/parisc/ccio-dma.c            | 2 --
 include/asm-generic/pci-dma-compat.h | 6 ------
 2 files changed, 8 deletions(-)

diff --git a/drivers/parisc/ccio-dma.c b/drivers/parisc/ccio-dma.c
index 957b421..8e11fb2 100644
--- a/drivers/parisc/ccio-dma.c
+++ b/drivers/parisc/ccio-dma.c
@@ -704,8 +704,6 @@ ccio_mark_invalid(struct ioc *ioc, dma_addr_t iova, size_t byte_cnt)
  * ccio_dma_supported - Verify the IOMMU supports the DMA address range.
  * @dev: The PCI device.
  * @mask: A bit mask describing the DMA address range of the device.
- *
- * This function implements the pci_dma_supported function.
  */
 static int 
 ccio_dma_supported(struct device *dev, u64 mask)
diff --git a/include/asm-generic/pci-dma-compat.h b/include/asm-generic/pci-dma-compat.h
index c110843..eafce7b 100644
--- a/include/asm-generic/pci-dma-compat.h
+++ b/include/asm-generic/pci-dma-compat.h
@@ -6,12 +6,6 @@
 
 #include <linux/dma-mapping.h>
 
-static inline int
-pci_dma_supported(struct pci_dev *hwdev, u64 mask)
-{
-	return dma_supported(hwdev == NULL ? NULL : &hwdev->dev, mask);
-}
-
 static inline void *
 pci_alloc_consistent(struct pci_dev *hwdev, size_t size,
 		     dma_addr_t *dma_handle)
-- 
1.9.1
