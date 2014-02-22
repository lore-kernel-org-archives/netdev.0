From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: stmmac: Check return value of alloc_dma_desc_resources()
Date: Sat, 22 Feb 2014 13:09:03 +0100
Message-ID: <1393070943-3466-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:55612 "EHLO sym2.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750866AbaBVMQR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Feb 2014 07:16:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

alloc_dma_desc_resources() returns an error value and the next line
actually checks for it, so assign the return value properly.

Found by the coverity scanner.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index a2e7d2c..078ad0e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1705,7 +1705,7 @@ static int stmmac_open(struct net_device *dev)
 	priv->dma_rx_size = STMMAC_ALIGN(dma_rxsize);
 	priv->dma_buf_sz = STMMAC_ALIGN(buf_sz);
 
-	alloc_dma_desc_resources(priv);
+	ret = alloc_dma_desc_resources(priv);
 	if (ret < 0) {
 		pr_err("%s: DMA descriptors allocation failed\n", __func__);
 		goto dma_desc_error;
-- 
1.8.5.3
