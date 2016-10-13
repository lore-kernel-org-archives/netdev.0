From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: axienet: Remove unused parameter from __axienet_device_reset
Date: Thu, 13 Oct 2016 13:28:33 +0200
Message-ID: <20161013112833.7581-1-tklauser@distanz.ch>
Cc: Michal Simek <michal.simek@xilinx.com>,
        =?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
        netdev@vger.kernel.org
To: Anirudha Sarangi <anirudh@xilinx.com>,
        John Linn <John.Linn@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:53044 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755136AbcJMLl1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Oct 2016 07:41:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dev parameter passed to __axienet_device_reset() is not used inside
the function, so remove it.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 35f9f9742a48..c688d68c39aa 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -431,8 +431,7 @@ static void axienet_setoptions(struct net_device *ndev, u32 options)
 	lp->options |= options;
 }
 
-static void __axienet_device_reset(struct axienet_local *lp,
-				   struct device *dev, off_t offset)
+static void __axienet_device_reset(struct axienet_local *lp, off_t offset)
 {
 	u32 timeout;
 	/* Reset Axi DMA. This would reset Axi Ethernet core as well. The reset
@@ -468,8 +467,8 @@ static void axienet_device_reset(struct net_device *ndev)
 	u32 axienet_status;
 	struct axienet_local *lp = netdev_priv(ndev);
 
-	__axienet_device_reset(lp, &ndev->dev, XAXIDMA_TX_CR_OFFSET);
-	__axienet_device_reset(lp, &ndev->dev, XAXIDMA_RX_CR_OFFSET);
+	__axienet_device_reset(lp, XAXIDMA_TX_CR_OFFSET);
+	__axienet_device_reset(lp, XAXIDMA_RX_CR_OFFSET);
 
 	lp->max_frm_size = XAE_MAX_VLAN_FRAME_SIZE;
 	lp->options |= XAE_OPTION_VLAN;
@@ -1338,8 +1337,8 @@ static void axienet_dma_err_handler(unsigned long data)
 	axienet_iow(lp, XAE_MDIO_MC_OFFSET, (mdio_mcreg &
 		    ~XAE_MDIO_MC_MDIOEN_MASK));
 
-	__axienet_device_reset(lp, &ndev->dev, XAXIDMA_TX_CR_OFFSET);
-	__axienet_device_reset(lp, &ndev->dev, XAXIDMA_RX_CR_OFFSET);
+	__axienet_device_reset(lp, XAXIDMA_TX_CR_OFFSET);
+	__axienet_device_reset(lp, XAXIDMA_RX_CR_OFFSET);
 
 	axienet_iow(lp, XAE_MDIO_MC_OFFSET, mdio_mcreg);
 	axienet_mdio_wait_until_ready(lp);
-- 
2.9.0
