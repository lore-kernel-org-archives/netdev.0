From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH 1/6] net: calxedaxgmac: enable operate on 2nd frame mode
Date: Fri, 12 Oct 2012 10:15:03 -0500
Message-ID: <1350054908-30646-2-git-send-email-robherring2@gmail.com>
References: <1350054908-30646-1-git-send-email-robherring2@gmail.com>
Cc: jonathan@jonmasters.org, eric.dumazet@gmail.com,
	Mark Langsdorf <mark.langsdorf@calxeda.com>,
	Rob Herring <rob.herring@calxeda.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1350054908-30646-1-git-send-email-robherring2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <rob.herring@calxeda.com>

Enable the tx dma to start reading the next frame while sending the current
frame.

Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
 drivers/net/ethernet/calxeda/xgmac.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 16814b3..7f5fd17 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -191,6 +191,7 @@
 #define DMA_CONTROL_ST		0x00002000	/* Start/Stop Transmission */
 #define DMA_CONTROL_SR		0x00000002	/* Start/Stop Receive */
 #define DMA_CONTROL_DFF		0x01000000	/* Disable flush of rx frames */
+#define DMA_CONTROL_OSF		0x00000004	/* Operate on 2nd tx frame */
 
 /* DMA Normal interrupt */
 #define DMA_INTR_ENA_NIE	0x00010000	/* Normal Summary */
@@ -965,8 +966,7 @@ static int xgmac_hw_init(struct net_device *dev)
 		ctrl |= XGMAC_CONTROL_IPC;
 	writel(ctrl, ioaddr + XGMAC_CONTROL);
 
-	value = DMA_CONTROL_DFF;
-	writel(value, ioaddr + XGMAC_DMA_CONTROL);
+	writel(DMA_CONTROL_DFF | DMA_CONTROL_OSF, ioaddr + XGMAC_DMA_CONTROL);
 
 	/* Set the HW DMA mode and the COE */
 	writel(XGMAC_OMR_TSF | XGMAC_OMR_RFD | XGMAC_OMR_RFA |
-- 
1.7.9.5
