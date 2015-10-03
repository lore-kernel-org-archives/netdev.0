From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 15/15] dma: remove external references to dma_supported
Date: Sat,  3 Oct 2015 17:19:39 +0200
Message-ID: <1443885579-7094-16-git-send-email-hch@lst.de>
References: <1443885579-7094-1-git-send-email-hch@lst.de>
Cc: linux-net-drivers@solarflare.com, dri-devel@lists.freedesktop.org,
	linux-media@vger.kernel.org, netdev@vger.kernel.org,
	linux-parisc@vger.kernel.org, linux-serial@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Don Fry <pcnet32@frontier.com>,
	Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443885579-7094-1-git-send-email-hch@lst.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 Documentation/DMA-API.txt       | 13 -------------
 drivers/usb/host/ehci-hcd.c     |  2 +-
 drivers/usb/host/fotg210-hcd.c  |  2 +-
 drivers/usb/host/fusbh200-hcd.c |  2 +-
 drivers/usb/host/oxu210hp-hcd.c |  2 +-
 5 files changed, 4 insertions(+), 17 deletions(-)

diff --git a/Documentation/DMA-API.txt b/Documentation/DMA-API.txt
index edccacd..55f48684 100644
--- a/Documentation/DMA-API.txt
+++ b/Documentation/DMA-API.txt
@@ -142,19 +142,6 @@ Part Ic - DMA addressing limitations
 ------------------------------------
 
 int
-dma_supported(struct device *dev, u64 mask)
-
-Checks to see if the device can support DMA to the memory described by
-mask.
-
-Returns: 1 if it can and 0 if it can't.
-
-Notes: This routine merely tests to see if the mask is possible.  It
-won't change the current mask settings.  It is more intended as an
-internal API for use by the platform than an external API for use by
-driver writers.
-
-int
 dma_set_mask_and_coherent(struct device *dev, u64 mask)
 
 Checks to see if the mask is possible and updates the device
diff --git a/drivers/usb/host/ehci-hcd.c b/drivers/usb/host/ehci-hcd.c
index c63d82c..48c92bf 100644
--- a/drivers/usb/host/ehci-hcd.c
+++ b/drivers/usb/host/ehci-hcd.c
@@ -589,7 +589,7 @@ static int ehci_run (struct usb_hcd *hcd)
 	 * streaming mappings for I/O buffers, like pci_map_single(),
 	 * can return segments above 4GB, if the device allows.
 	 *
-	 * NOTE:  the dma mask is visible through dma_supported(), so
+	 * NOTE:  the dma mask is visible through dev->dma_mask, so
 	 * drivers can pass this info along ... like NETIF_F_HIGHDMA,
 	 * Scsi_Host.highmem_io, and so forth.  It's readonly to all
 	 * host side drivers though.
diff --git a/drivers/usb/host/fotg210-hcd.c b/drivers/usb/host/fotg210-hcd.c
index 000ed80..c5fc3ef 100644
--- a/drivers/usb/host/fotg210-hcd.c
+++ b/drivers/usb/host/fotg210-hcd.c
@@ -5258,7 +5258,7 @@ static int fotg210_run(struct usb_hcd *hcd)
 	 * streaming mappings for I/O buffers, like pci_map_single(),
 	 * can return segments above 4GB, if the device allows.
 	 *
-	 * NOTE:  the dma mask is visible through dma_supported(), so
+	 * NOTE:  the dma mask is visible through dev->dma_mask, so
 	 * drivers can pass this info along ... like NETIF_F_HIGHDMA,
 	 * Scsi_Host.highmem_io, and so forth.  It's readonly to all
 	 * host side drivers though.
diff --git a/drivers/usb/host/fusbh200-hcd.c b/drivers/usb/host/fusbh200-hcd.c
index 1fd8718..4a1243a 100644
--- a/drivers/usb/host/fusbh200-hcd.c
+++ b/drivers/usb/host/fusbh200-hcd.c
@@ -5181,7 +5181,7 @@ static int fusbh200_run (struct usb_hcd *hcd)
 	 * streaming mappings for I/O buffers, like pci_map_single(),
 	 * can return segments above 4GB, if the device allows.
 	 *
-	 * NOTE:  the dma mask is visible through dma_supported(), so
+	 * NOTE:  the dma mask is visible through dev->dma_mask, so
 	 * drivers can pass this info along ... like NETIF_F_HIGHDMA,
 	 * Scsi_Host.highmem_io, and so forth.  It's readonly to all
 	 * host side drivers though.
diff --git a/drivers/usb/host/oxu210hp-hcd.c b/drivers/usb/host/oxu210hp-hcd.c
index fe3bd1c..1f139d8 100644
--- a/drivers/usb/host/oxu210hp-hcd.c
+++ b/drivers/usb/host/oxu210hp-hcd.c
@@ -2721,7 +2721,7 @@ static int oxu_run(struct usb_hcd *hcd)
 	 * streaming mappings for I/O buffers, like pci_map_single(),
 	 * can return segments above 4GB, if the device allows.
 	 *
-	 * NOTE:  the dma mask is visible through dma_supported(), so
+	 * NOTE:  the dma mask is visible through dev->dma_mask, so
 	 * drivers can pass this info along ... like NETIF_F_HIGHDMA,
 	 * Scsi_Host.highmem_io, and so forth.  It's readonly to all
 	 * host side drivers though.
-- 
1.9.1
