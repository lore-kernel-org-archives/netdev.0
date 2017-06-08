From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Subject: [PATCH 01/44] firmware/ivc: use dma_mapping_error
Date: Thu,  8 Jun 2017 15:25:26 +0200
Message-ID: <20170608132609.32662-2-hch@lst.de>
References: <20170608132609.32662-1-hch@lst.de>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org,
        linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, openrisc-cunTk1MwBs9a3B2Vnqf2dGD2FQJk+8+b@public.gmane.org,
        linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, dmaengine-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
        linux-samsung-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170608132609.32662-1-hch-jcswGhMUV9g@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

DMA_ERROR_CODE is not supposed to be used by drivers.

Signed-off-by: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
---
 drivers/firmware/tegra/ivc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/firmware/tegra/ivc.c b/drivers/firmware/tegra/ivc.c
index 29ecfd815320..a01461d63f68 100644
--- a/drivers/firmware/tegra/ivc.c
+++ b/drivers/firmware/tegra/ivc.c
@@ -646,12 +646,12 @@ int tegra_ivc_init(struct tegra_ivc *ivc, struct device *peer, void *rx,
 	if (peer) {
 		ivc->rx.phys = dma_map_single(peer, rx, queue_size,
 					      DMA_BIDIRECTIONAL);
-		if (ivc->rx.phys == DMA_ERROR_CODE)
+		if (dma_mapping_error(peer, ivc->rx.phys))
 			return -ENOMEM;
 
 		ivc->tx.phys = dma_map_single(peer, tx, queue_size,
 					      DMA_BIDIRECTIONAL);
-		if (ivc->tx.phys == DMA_ERROR_CODE) {
+		if (dma_mapping_error(peer, ivc->tx.phys)) {
 			dma_unmap_single(peer, ivc->rx.phys, queue_size,
 					 DMA_BIDIRECTIONAL);
 			return -ENOMEM;
-- 
2.11.0
