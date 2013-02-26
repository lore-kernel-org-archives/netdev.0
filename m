From: Syam Sidhardhan <syamsidhardh@gmail.com>
Subject: [PATCH] myri10ge: Remove redundant NULL check before kfree
Date: Wed, 27 Feb 2013 01:21:06 +0530
Message-ID: <1361908266-3203-1-git-send-email-s.syam@samsung.com>
Cc: syamsidhardh@gmail.com, gallatin@myri.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f53.google.com ([209.85.210.53]:42393 "EHLO
	mail-da0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754377Ab3BZTvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 14:51:21 -0500
Received: by mail-da0-f53.google.com with SMTP id n34so1462094dal.12
        for <netdev@vger.kernel.org>; Tue, 26 Feb 2013 11:51:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kfree on NULL pointer is a no-op.

Signed-off-by: Syam Sidhardhan <s.syam@samsung.com>
---
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 4f9937e..2f9efe8 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -4005,8 +4005,7 @@ static void myri10ge_remove(struct pci_dev *pdev)
 		mtrr_del(mgp->mtrr, mgp->iomem_base, mgp->board_span);
 #endif
 	myri10ge_free_slices(mgp);
-	if (mgp->msix_vectors != NULL)
-		kfree(mgp->msix_vectors);
+	kfree(mgp->msix_vectors);
 	dma_free_coherent(&pdev->dev, sizeof(*mgp->cmd),
 			  mgp->cmd, mgp->cmd_bus);
 
-- 
1.7.9.5
