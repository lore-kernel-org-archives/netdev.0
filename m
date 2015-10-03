From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Subject: [PATCH 05/15] cx88: use pci_set_dma_mask insted of pci_dma_supported
Date: Sat,  3 Oct 2015 17:19:29 +0200
Message-ID: <1443885579-7094-6-git-send-email-hch@lst.de>
References: <1443885579-7094-1-git-send-email-hch@lst.de>
Cc: linux-net-drivers-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
	linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Don Fry <pcnet32-/1bC63wxbnBWk0Htik3J/w@public.gmane.org>,
	Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1443885579-7094-1-git-send-email-hch-jcswGhMUV9g@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This ensures the dma mask that is supported by the driver is recorded
in the device structure.

Signed-off-by: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
---
 drivers/media/pci/cx88/cx88-alsa.c  | 2 +-
 drivers/media/pci/cx88/cx88-mpeg.c  | 2 +-
 drivers/media/pci/cx88/cx88-video.c | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/media/pci/cx88/cx88-alsa.c b/drivers/media/pci/cx88/cx88-alsa.c
index 7f8dc60..0703a81 100644
--- a/drivers/media/pci/cx88/cx88-alsa.c
+++ b/drivers/media/pci/cx88/cx88-alsa.c
@@ -890,7 +890,7 @@ static int snd_cx88_create(struct snd_card *card, struct pci_dev *pci,
 		return err;
 	}
 
-	if (!pci_dma_supported(pci,DMA_BIT_MASK(32))) {
+	if (!pci_set_dma_mask(pci,DMA_BIT_MASK(32))) {
 		dprintk(0, "%s/1: Oops: no 32bit PCI DMA ???\n",core->name);
 		err = -EIO;
 		cx88_core_put(core, pci);
diff --git a/drivers/media/pci/cx88/cx88-mpeg.c b/drivers/media/pci/cx88/cx88-mpeg.c
index 34f5057..9b3b565 100644
--- a/drivers/media/pci/cx88/cx88-mpeg.c
+++ b/drivers/media/pci/cx88/cx88-mpeg.c
@@ -393,7 +393,7 @@ static int cx8802_init_common(struct cx8802_dev *dev)
 	if (pci_enable_device(dev->pci))
 		return -EIO;
 	pci_set_master(dev->pci);
-	if (!pci_dma_supported(dev->pci,DMA_BIT_MASK(32))) {
+	if (!pci_set_dma_mask(dev->pci,DMA_BIT_MASK(32))) {
 		printk("%s/2: Oops: no 32bit PCI DMA ???\n",dev->core->name);
 		return -EIO;
 	}
diff --git a/drivers/media/pci/cx88/cx88-video.c b/drivers/media/pci/cx88/cx88-video.c
index 400e5ca..f12af31 100644
--- a/drivers/media/pci/cx88/cx88-video.c
+++ b/drivers/media/pci/cx88/cx88-video.c
@@ -1311,7 +1311,7 @@ static int cx8800_initdev(struct pci_dev *pci_dev,
 	       dev->pci_lat,(unsigned long long)pci_resource_start(pci_dev,0));
 
 	pci_set_master(pci_dev);
-	if (!pci_dma_supported(pci_dev,DMA_BIT_MASK(32))) {
+	if (!pci_set_dma_mask(pci_dev,DMA_BIT_MASK(32))) {
 		printk("%s/0: Oops: no 32bit PCI DMA ???\n",core->name);
 		err = -EIO;
 		goto fail_core;
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
