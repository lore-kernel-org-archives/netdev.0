From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 06/17] stmmac: dwmac-sunxi: move sun7i_gmac_setup function
Date: Wed, 29 Jul 2015 00:08:53 +0200
Message-ID: <1438121344-5304-7-git-send-email-manabian@gmail.com>
References: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org
To: peppe.cavallaro@st.com, wens@csie.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:34719 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751953AbbG1WJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 18:09:28 -0400
Received: by lbbzr7 with SMTP id zr7so83962548lbb.1
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 15:09:26 -0700 (PDT)
In-Reply-To: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move sun7i_gmac_setup in preparation for turning it into
a proper probe function.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c | 58 +++++++++++------------
 1 file changed, 29 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c
index 15048ca39759..c9d6e2d5bfc9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c
@@ -33,35 +33,6 @@ struct sunxi_priv_data {
 	struct regulator *regulator;
 };
 
-static void *sun7i_gmac_setup(struct platform_device *pdev)
-{
-	struct sunxi_priv_data *gmac;
-	struct device *dev = &pdev->dev;
-
-	gmac = devm_kzalloc(dev, sizeof(*gmac), GFP_KERNEL);
-	if (!gmac)
-		return ERR_PTR(-ENOMEM);
-
-	gmac->interface = of_get_phy_mode(dev->of_node);
-
-	gmac->tx_clk = devm_clk_get(dev, "allwinner_gmac_tx");
-	if (IS_ERR(gmac->tx_clk)) {
-		dev_err(dev, "could not get tx clock\n");
-		return gmac->tx_clk;
-	}
-
-	/* Optional regulator for PHY */
-	gmac->regulator = devm_regulator_get_optional(dev, "phy");
-	if (IS_ERR(gmac->regulator)) {
-		if (PTR_ERR(gmac->regulator) == -EPROBE_DEFER)
-			return ERR_PTR(-EPROBE_DEFER);
-		dev_info(dev, "no regulator found\n");
-		gmac->regulator = NULL;
-	}
-
-	return gmac;
-}
-
 #define SUN7I_GMAC_GMII_RGMII_RATE	125000000
 #define SUN7I_GMAC_MII_RATE		25000000
 
@@ -132,6 +103,35 @@ static void sun7i_fix_speed(void *priv, unsigned int speed)
 	}
 }
 
+static void *sun7i_gmac_setup(struct platform_device *pdev)
+{
+	struct sunxi_priv_data *gmac;
+	struct device *dev = &pdev->dev;
+
+	gmac = devm_kzalloc(dev, sizeof(*gmac), GFP_KERNEL);
+	if (!gmac)
+		return ERR_PTR(-ENOMEM);
+
+	gmac->interface = of_get_phy_mode(dev->of_node);
+
+	gmac->tx_clk = devm_clk_get(dev, "allwinner_gmac_tx");
+	if (IS_ERR(gmac->tx_clk)) {
+		dev_err(dev, "could not get tx clock\n");
+		return gmac->tx_clk;
+	}
+
+	/* Optional regulator for PHY */
+	gmac->regulator = devm_regulator_get_optional(dev, "phy");
+	if (IS_ERR(gmac->regulator)) {
+		if (PTR_ERR(gmac->regulator) == -EPROBE_DEFER)
+			return ERR_PTR(-EPROBE_DEFER);
+		dev_info(dev, "no regulator found\n");
+		gmac->regulator = NULL;
+	}
+
+	return gmac;
+}
+
 /* of_data specifying hardware features and callbacks.
  * hardware features were copied from Allwinner drivers. */
 static const struct stmmac_of_data sun7i_gmac_data = {
-- 
1.8.0
