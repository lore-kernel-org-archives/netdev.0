From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 02/15] tw68-core: use pci_set_dma_mask insted of pci_dma_supported
Date: Sat,  3 Oct 2015 17:19:26 +0200
Message-ID: <1443885579-7094-3-git-send-email-hch@lst.de>
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

This ensures the dma mask that is supported by the driver is recorded
in the device structure.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/media/pci/tw68/tw68-core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/media/pci/tw68/tw68-core.c b/drivers/media/pci/tw68/tw68-core.c
index 04706cc..8c5655d 100644
--- a/drivers/media/pci/tw68/tw68-core.c
+++ b/drivers/media/pci/tw68/tw68-core.c
@@ -257,7 +257,7 @@ static int tw68_initdev(struct pci_dev *pci_dev,
 		dev->name, pci_name(pci_dev), dev->pci_rev, pci_dev->irq,
 		dev->pci_lat, (u64)pci_resource_start(pci_dev, 0));
 	pci_set_master(pci_dev);
-	if (!pci_dma_supported(pci_dev, DMA_BIT_MASK(32))) {
+	if (!pci_set_dma_mask(pci_dev, DMA_BIT_MASK(32))) {
 		pr_info("%s: Oops: no 32bit PCI DMA ???\n", dev->name);
 		err = -EIO;
 		goto fail1;
-- 
1.9.1
