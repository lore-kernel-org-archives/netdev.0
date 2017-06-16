From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 07/11] 53c700: switch to dma_alloc_attrs
Date: Fri, 16 Jun 2017 09:17:12 +0200
Message-ID: <20170616071716.17321-8-hch@lst.de>
References: <20170616071716.17321-1-hch@lst.de>
Cc: linux-kernel@vger.kernel.org
To: linux-scsi@vger.kernel.org, linux-serial@vger.kernel.org,
        netdev@vger.kernel.org, linux-metag@vger.kernel.org,
        nios2-dev@lists.rocketboards.org, linux-fbdev@vger.kernel.org,
        alsa-devel@alsa-project.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:44824 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752728AbdFPHRv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 03:17:51 -0400
In-Reply-To: <20170616071716.17321-1-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use dma_alloc_attrs directly instead of the dma_alloc_noncoherent wrapper.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/scsi/53c700.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/scsi/53c700.c b/drivers/scsi/53c700.c
index 95e32a47face..4b3b08025ef6 100644
--- a/drivers/scsi/53c700.c
+++ b/drivers/scsi/53c700.c
@@ -296,8 +296,8 @@ NCR_700_detect(struct scsi_host_template *tpnt,
 	if(tpnt->sdev_attrs == NULL)
 		tpnt->sdev_attrs = NCR_700_dev_attrs;
 
-	memory = dma_alloc_noncoherent(hostdata->dev, TOTAL_MEM_SIZE,
-				       &pScript, GFP_KERNEL);
+	memory = dma_alloc_attrs(hostdata->dev, TOTAL_MEM_SIZE, &pScript,
+				 GFP_KERNEL, DMA_ATTR_NON_CONSISTENT);
 	if(memory == NULL) {
 		printk(KERN_ERR "53c700: Failed to allocate memory for driver, detaching\n");
 		return NULL;
@@ -410,8 +410,8 @@ NCR_700_release(struct Scsi_Host *host)
 	struct NCR_700_Host_Parameters *hostdata = 
 		(struct NCR_700_Host_Parameters *)host->hostdata[0];
 
-	dma_free_noncoherent(hostdata->dev, TOTAL_MEM_SIZE,
-			       hostdata->script, hostdata->pScript);
+	dma_free_attrs(hostdata->dev, TOTAL_MEM_SIZE, hostdata->script,
+		       hostdata->pScript, DMA_ATTR_NON_CONSISTENT);
 	return 1;
 }
 
-- 
2.11.0
