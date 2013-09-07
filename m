From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: [PATCH] bcm63xx_enet: remove deprecated IRQF_DISABLED
Date: Sat,  7 Sep 2013 08:56:50 +0200
Message-ID: <1378537010-7128-1-git-send-email-michael.opdenacker@free-electrons.com>
Cc: jogo@openwrt.org, joe@perches.com, jg1.han@samsung.com,
	mbizon@freebox.fr, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch proposes to remove the IRQF_DISABLED flag from
drivers/net/ethernet/broadcom/bcm63xx_enet.c

It's a NOOP since 2.6.35 and it will be removed one day.

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 8ac48fb..b9a5fb6 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -926,13 +926,13 @@ static int bcm_enet_open(struct net_device *dev)
 	if (ret)
 		goto out_phy_disconnect;
 
-	ret = request_irq(priv->irq_rx, bcm_enet_isr_dma, IRQF_DISABLED,
+	ret = request_irq(priv->irq_rx, bcm_enet_isr_dma, 0,
 			  dev->name, dev);
 	if (ret)
 		goto out_freeirq;
 
 	ret = request_irq(priv->irq_tx, bcm_enet_isr_dma,
-			  IRQF_DISABLED, dev->name, dev);
+			  0, dev->name, dev);
 	if (ret)
 		goto out_freeirq_rx;
 
@@ -2156,13 +2156,13 @@ static int bcm_enetsw_open(struct net_device *dev)
 	enet_dmac_writel(priv, 0, ENETDMAC_IRMASK, priv->tx_chan);
 
 	ret = request_irq(priv->irq_rx, bcm_enet_isr_dma,
-			  IRQF_DISABLED, dev->name, dev);
+			  0, dev->name, dev);
 	if (ret)
 		goto out_freeirq;
 
 	if (priv->irq_tx != -1) {
 		ret = request_irq(priv->irq_tx, bcm_enet_isr_dma,
-				  IRQF_DISABLED, dev->name, dev);
+				  0, dev->name, dev);
 		if (ret)
 			goto out_freeirq_rx;
 	}
-- 
1.8.1.2
