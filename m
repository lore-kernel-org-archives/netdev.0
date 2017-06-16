From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 03/11] au1100fb: remove a bogus dma_free_nonconsistent call
Date: Fri, 16 Jun 2017 09:17:08 +0200
Message-ID: <20170616071716.17321-4-hch@lst.de>
References: <20170616071716.17321-1-hch@lst.de>
Cc: linux-kernel@vger.kernel.org
To: linux-scsi@vger.kernel.org, linux-serial@vger.kernel.org,
        netdev@vger.kernel.org, linux-metag@vger.kernel.org,
        nios2-dev@lists.rocketboards.org, linux-fbdev@vger.kernel.org,
        alsa-devel@alsa-project.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:52793 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752134AbdFPHRo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 03:17:44 -0400
In-Reply-To: <20170616071716.17321-1-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

au1100fb is using managed dma allocations, so it doesn't need to
explicitly free the dma memory in the error path (and if it did
it would have to use the managed version).

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/video/fbdev/au1100fb.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/video/fbdev/au1100fb.c b/drivers/video/fbdev/au1100fb.c
index 35df2c1a8a63..8de42f617d16 100644
--- a/drivers/video/fbdev/au1100fb.c
+++ b/drivers/video/fbdev/au1100fb.c
@@ -532,10 +532,6 @@ static int au1100fb_drv_probe(struct platform_device *dev)
 		clk_disable_unprepare(fbdev->lcdclk);
 		clk_put(fbdev->lcdclk);
 	}
-	if (fbdev->fb_mem) {
-		dma_free_noncoherent(&dev->dev, fbdev->fb_len, fbdev->fb_mem,
-				     fbdev->fb_phys);
-	}
 	if (fbdev->info.cmap.len != 0) {
 		fb_dealloc_cmap(&fbdev->info.cmap);
 	}
-- 
2.11.0
