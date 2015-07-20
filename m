From: Lucas Stach <l.stach@pengutronix.de>
Subject: [PATCH 1/2] net: fec: use managed DMA API functions to allocate BD ring
Date: Mon, 20 Jul 2015 15:51:37 +0200
Message-ID: <1437400298-17379-1-git-send-email-l.stach@pengutronix.de>
Cc: Duan Andy <fugang.duan@freescale.com>,
	Frank Li <Frank.Li@freescale.com>, netdev@vger.kernel.org,
	kernel@pengutronix.de, patchwork-lst@pengutronix.de
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42021 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333AbbGTNvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 09:51:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So it gets freed when the device is going away.
This fixes a DMA memory leak on driver probe() fail and driver
remove().

Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
---
 drivers/net/ethernet/freescale/fec_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 349365d85b92..b3287c6b069b 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3142,7 +3142,7 @@ static int fec_enet_init(struct net_device *ndev)
 			fep->bufdesc_size;
 
 	/* Allocate memory for buffer descriptors. */
-	cbd_base = dma_alloc_coherent(NULL, bd_size, &bd_dma,
+	cbd_base = dmam_alloc_coherent(&fep->pdev->dev, bd_size, &bd_dma,
 				      GFP_KERNEL);
 	if (!cbd_base) {
 		return -ENOMEM;
-- 
2.1.4
