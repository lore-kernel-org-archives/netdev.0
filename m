From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 08/11] sgiseeq: switch to dma_alloc_attrs
Date: Fri, 16 Jun 2017 09:17:13 +0200
Message-ID: <20170616071716.17321-9-hch@lst.de>
References: <20170616071716.17321-1-hch@lst.de>
Cc: linux-kernel@vger.kernel.org
To: linux-scsi@vger.kernel.org, linux-serial@vger.kernel.org,
        netdev@vger.kernel.org, linux-metag@vger.kernel.org,
        nios2-dev@lists.rocketboards.org, linux-fbdev@vger.kernel.org,
        alsa-devel@alsa-project.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:49178 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752693AbdFPHSA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 03:18:00 -0400
In-Reply-To: <20170616071716.17321-1-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use dma_alloc_attrs directly instead of the dma_alloc_noncoherent wrapper.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/net/ethernet/seeq/sgiseeq.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/seeq/sgiseeq.c b/drivers/net/ethernet/seeq/sgiseeq.c
index 70347720fdf9..573691bc3b71 100644
--- a/drivers/net/ethernet/seeq/sgiseeq.c
+++ b/drivers/net/ethernet/seeq/sgiseeq.c
@@ -737,8 +737,8 @@ static int sgiseeq_probe(struct platform_device *pdev)
 	sp = netdev_priv(dev);
 
 	/* Make private data page aligned */
-	sr = dma_alloc_noncoherent(&pdev->dev, sizeof(*sp->srings),
-				&sp->srings_dma, GFP_KERNEL);
+	sr = dma_alloc_attrs(&pdev->dev, sizeof(*sp->srings), &sp->srings_dma,
+			     GFP_KERNEL, DMA_ATTR_NON_CONSISTENT);
 	if (!sr) {
 		printk(KERN_ERR "Sgiseeq: Page alloc failed, aborting.\n");
 		err = -ENOMEM;
@@ -813,8 +813,8 @@ static int sgiseeq_remove(struct platform_device *pdev)
 	struct sgiseeq_private *sp = netdev_priv(dev);
 
 	unregister_netdev(dev);
-	dma_free_noncoherent(&pdev->dev, sizeof(*sp->srings), sp->srings,
-			     sp->srings_dma);
+	dma_free_attrs(&pdev->dev, sizeof(*sp->srings), sp->srings,
+		       sp->srings_dma, DMA_ATTR_NON_CONSISTENT);
 	free_netdev(dev);
 
 	return 0;
-- 
2.11.0
