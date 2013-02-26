From: Syam Sidhardhan <syamsidhardh@gmail.com>
Subject: [PATCH] xilinx: ll_temac: Remove redundant NULL check before kfree
Date: Wed, 27 Feb 2013 01:29:37 +0530
Message-ID: <1361908777-3340-1-git-send-email-s.syam@samsung.com>
Cc: syamsidhardh@gmail.com, John.Linn@xilinx.com, anirudh@xilinx.com,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:62369 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759849Ab3BZT7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 14:59:52 -0500
Received: by mail-pa0-f49.google.com with SMTP id kp6so2663818pab.36
        for <netdev@vger.kernel.org>; Tue, 26 Feb 2013 11:59:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kfree on NULL pointer is a no-op.

Signed-off-by: Syam Sidhardhan <s.syam@samsung.com>
---
 drivers/net/ethernet/xilinx/ll_temac_main.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 9fc2ada..200a341 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -224,8 +224,7 @@ static void temac_dma_bd_release(struct net_device *ndev)
 		dma_free_coherent(ndev->dev.parent,
 				sizeof(*lp->tx_bd_v) * TX_BD_NUM,
 				lp->tx_bd_v, lp->tx_bd_p);
-	if (lp->rx_skb)
-		kfree(lp->rx_skb);
+	kfree(lp->rx_skb);
 }
 
 /**
-- 
1.7.9.5
