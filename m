From: Lucas Stach <l.stach@pengutronix.de>
Subject: [Patch v2 resend 1/2] net: fec: use managed DMA API functions to allocate BD ring
Date: Thu, 23 Jul 2015 16:06:19 +0200
Message-ID: <1437660380-21164-1-git-send-email-l.stach@pengutronix.de>
Cc: Duan Andy <fugang.duan@freescale.com>,
	Frank Li <Frank.Li@freescale.com>, netdev@vger.kernel.org,
	patchwork-lst@pengutronix.de
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34551 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753256AbbGWOG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 10:06:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So it gets freed when the device is going away.
This fixes a DMA memory leak on driver probe() fail and driver
remove().

Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
---
v2: Fix indentation of second line to fix alignment with opening bracket.
---
 drivers/net/ethernet/freescale/fec_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 349365d85b92..a7f1bdf718f8 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3142,8 +3142,8 @@ static int fec_enet_init(struct net_device *ndev)
 			fep->bufdesc_size;
 
 	/* Allocate memory for buffer descriptors. */
-	cbd_base = dma_alloc_coherent(NULL, bd_size, &bd_dma,
-				      GFP_KERNEL);
+	cbd_base = dmam_alloc_coherent(&fep->pdev->dev, bd_size, &bd_dma,
+				       GFP_KERNEL);
 	if (!cbd_base) {
 		return -ENOMEM;
 	}
-- 
2.1.4
