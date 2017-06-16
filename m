From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 06/11] sigwd93: switch to dma_alloc_attrs
Date: Fri, 16 Jun 2017 09:17:11 +0200
Message-ID: <20170616071716.17321-7-hch@lst.de>
References: <20170616071716.17321-1-hch@lst.de>
Cc: linux-kernel@vger.kernel.org
To: linux-scsi@vger.kernel.org, linux-serial@vger.kernel.org,
        netdev@vger.kernel.org, linux-metag@vger.kernel.org,
        nios2-dev@lists.rocketboards.org, linux-fbdev@vger.kernel.org,
        alsa-devel@alsa-project.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:33588 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752693AbdFPHRw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 03:17:52 -0400
In-Reply-To: <20170616071716.17321-1-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use dma_alloc_attrs directly instead of the dma_alloc_noncoherent wrapper.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/scsi/sgiwd93.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/scsi/sgiwd93.c b/drivers/scsi/sgiwd93.c
index 71b4b91d2215..80cfa93e407c 100644
--- a/drivers/scsi/sgiwd93.c
+++ b/drivers/scsi/sgiwd93.c
@@ -249,8 +249,8 @@ static int sgiwd93_probe(struct platform_device *pdev)
 
 	hdata = host_to_hostdata(host);
 	hdata->dev = &pdev->dev;
-	hdata->cpu = dma_alloc_noncoherent(&pdev->dev, HPC_DMA_SIZE,
-					   &hdata->dma, GFP_KERNEL);
+	hdata->cpu = dma_alloc_attrs(&pdev->dev, HPC_DMA_SIZE, &hdata->dma,
+				     GFP_KERNEL, DMA_ATTR_NON_CONSISTENT);
 	if (!hdata->cpu) {
 		printk(KERN_WARNING "sgiwd93: Could not allocate memory for "
 		       "host %d buffer.\n", unit);
@@ -289,7 +289,8 @@ static int sgiwd93_probe(struct platform_device *pdev)
 out_irq:
 	free_irq(irq, host);
 out_free:
-	dma_free_noncoherent(&pdev->dev, HPC_DMA_SIZE, hdata->cpu, hdata->dma);
+	dma_free_attrs(&pdev->dev, HPC_DMA_SIZE, hdata->cpu, hdata->dma,
+		       DMA_ATTR_NON_CONSISTENT);
 out_put:
 	scsi_host_put(host);
 out:
@@ -305,7 +306,8 @@ static int sgiwd93_remove(struct platform_device *pdev)
 
 	scsi_remove_host(host);
 	free_irq(pd->irq, host);
-	dma_free_noncoherent(&pdev->dev, HPC_DMA_SIZE, hdata->cpu, hdata->dma);
+	dma_free_attrs(&pdev->dev, HPC_DMA_SIZE, hdata->cpu, hdata->dma,
+		       DMA_ATTR_NON_CONSISTENT);
 	scsi_host_put(host);
 	return 0;
 }
-- 
2.11.0
