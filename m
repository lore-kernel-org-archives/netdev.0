From: Jonas Gorski <jogo@openwrt.org>
Subject: [PATCH 3/3] bcm63xx_enet: properly prepare/unprepare clocks before/after usage
Date: Sun, 10 Mar 2013 14:57:49 +0100
Message-ID: <1362923869-21346-3-git-send-email-jogo@openwrt.org>
References: <1362923869-21346-1-git-send-email-jogo@openwrt.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	Maxime Bizon <mbizon@freebox.fr>,
	Florian Fainelli <florian@openwrt.org>,
	Kevin Cernekee <cernekee@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:50587 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751373Ab3CJN6C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Mar 2013 09:58:02 -0400
In-Reply-To: <1362923869-21346-1-git-send-email-jogo@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use clk_prepare_enable/disable_unprepare calls in preparation for
switching to the generic clock framework.

Signed-off-by: Jonas Gorski <jogo@openwrt.org>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 8397d1c..aff3866 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1685,7 +1685,7 @@ static int bcm_enet_probe(struct platform_device *pdev)
 		ret = PTR_ERR(priv->mac_clk);
 		goto out;
 	}
-	clk_enable(priv->mac_clk);
+	clk_prepare_enable(priv->mac_clk);
 
 	/* initialize default and fetch platform data */
 	priv->rx_ring_size = BCMENET_DEF_RX_DESC;
@@ -1714,7 +1714,7 @@ static int bcm_enet_probe(struct platform_device *pdev)
 			priv->phy_clk = NULL;
 			goto out_put_clk_mac;
 		}
-		clk_enable(priv->phy_clk);
+		clk_prepare_enable(priv->phy_clk);
 	}
 
 	/* do minimal hardware init to be able to probe mii bus */
@@ -1815,12 +1815,12 @@ out_uninit_hw:
 	/* turn off mdc clock */
 	enet_writel(priv, 0, ENET_MIISC_REG);
 	if (priv->phy_clk) {
-		clk_disable(priv->phy_clk);
+		clk_disable_unprepare(priv->phy_clk);
 		clk_put(priv->phy_clk);
 	}
 
 out_put_clk_mac:
-	clk_disable(priv->mac_clk);
+	clk_disable_unprepare(priv->mac_clk);
 	clk_put(priv->mac_clk);
 out:
 	free_netdev(dev);
@@ -1858,10 +1858,10 @@ static int bcm_enet_remove(struct platform_device *pdev)
 
 	/* disable hw block clocks */
 	if (priv->phy_clk) {
-		clk_disable(priv->phy_clk);
+		clk_disable_unprepare(priv->phy_clk);
 		clk_put(priv->phy_clk);
 	}
-	clk_disable(priv->mac_clk);
+	clk_disable_unprepare(priv->mac_clk);
 	clk_put(priv->mac_clk);
 
 	platform_set_drvdata(pdev, NULL);
-- 
1.7.10.4
