From: Insu Yun <wuninsu@gmail.com>
Subject: [PATCH] et131x: check return value of dma_alloc_coherent
Date: Mon, 15 Feb 2016 21:23:47 -0500
Message-ID: <1455589427-6882-1-git-send-email-wuninsu@gmail.com>
Cc: taesoo@gatech.edu, yeongjin.jang@gatech.edu, insu@gatech.edu,
	changwoo@gatech.edu, Insu Yun <wuninsu@gmail.com>
To: mark.einon@gmail.com, andrew@lunn.ch, davem@davemloft.net,
	f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f170.google.com ([209.85.161.170]:36334 "EHLO
	mail-yw0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752231AbcBPCXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 21:23:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For error handling, dma_alloc_coherent's return value
needs to be checked, not argument.

Signed-off-by: Insu Yun <wuninsu@gmail.com>
---
 drivers/net/ethernet/agere/et131x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/agere/et131x.c b/drivers/net/ethernet/agere/et131x.c
index 3f3bcbe..0907ab6 100644
--- a/drivers/net/ethernet/agere/et131x.c
+++ b/drivers/net/ethernet/agere/et131x.c
@@ -2380,7 +2380,7 @@ static int et131x_tx_dma_memory_alloc(struct et131x_adapter *adapter)
 						    sizeof(u32),
 						    &tx_ring->tx_status_pa,
 						    GFP_KERNEL);
-	if (!tx_ring->tx_status_pa) {
+	if (!tx_ring->tx_status) {
 		dev_err(&adapter->pdev->dev,
 			"Cannot alloc memory for Tx status block\n");
 		return -ENOMEM;
-- 
1.9.1
