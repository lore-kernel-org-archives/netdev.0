From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH] r8169:Fill with zero Tx descriptors
Date: Wed,  5 Aug 2015 13:46:44 +0300
Message-ID: <1438771604-17621-1-git-send-email-corcodel.marian@gmail.com>
Cc: Corcodel Marian <corcodel.marian@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:36129 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752335AbbHEKq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 06:46:59 -0400
Received: by wicgj17 with SMTP id gj17so186753590wic.1
        for <netdev@vger.kernel.org>; Wed, 05 Aug 2015 03:46:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 This patch fill with zero Tx descriptors before use.Is only
 on    part by more patches but is critical.(critical)


Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 3df51fa..bf78f94 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7589,7 +7589,7 @@ static int rtl_open(struct net_device *dev)
 	 * Rx and Tx descriptors needs 256 bytes alignment.
 	 * dma_alloc_coherent provides more.
 	 */
-	tp->TxDescArray = dma_alloc_coherent(&pdev->dev, R8169_TX_RING_BYTES,
+	tp->TxDescArray = dma_zalloc_coherent(&pdev->dev, R8169_TX_RING_BYTES,
 					     &tp->TxPhyAddr, GFP_KERNEL);
 	if (!tp->TxDescArray)
 		goto err_pm_runtime_put;
-- 
2.1.4
