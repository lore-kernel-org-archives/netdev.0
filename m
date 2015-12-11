From: Saurabh Sengar <saurabh.truth@gmail.com>
Subject: [PATCH] wan: wanxl: add pci_disable_device in case of error
Date: Sat, 12 Dec 2015 00:58:19 +0530
Message-ID: <1449862099-6256-1-git-send-email-saurabh.truth@gmail.com>
Cc: Saurabh Sengar <saurabh.truth@gmail.com>
To: khc@pm.waw.pl, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33000 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbbLKT23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 14:28:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If there is 'no suitable DMA available' error, device should be disabled
before returning

Signed-off-by: Saurabh Sengar <saurabh.truth@gmail.com>
---
 drivers/net/wan/wanxl.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
index e73f138..a20d688 100644
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -586,6 +586,7 @@ static int wanxl_pci_init_one(struct pci_dev *pdev,
 	if (pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(28)) ||
 	    pci_set_dma_mask(pdev, DMA_BIT_MASK(28))) {
 		pr_err("No usable DMA configuration\n");
+		pci_disable_device(pdev);
 		return -EIO;
 	}
 
-- 
1.9.1
