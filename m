From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 5/5] stmmac: dwmac-socfpga: kill init() and rename setup() to set_phy_mode()
Date: Tue, 26 Apr 2016 23:24:59 +0200
Message-ID: <1461705899-17015-6-git-send-email-manabian@gmail.com>
References: <1461705899-17015-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, marex@denx.de,
	dinguyen@opensource.altera.com, peppe.cavallaro@st.com,
	alexandre.torgue@st.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35952 "EHLO
	mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752861AbcDZVZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 17:25:34 -0400
Received: by mail-lf0-f68.google.com with SMTP id y84so4293668lfc.3
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 14:25:33 -0700 (PDT)
In-Reply-To: <1461705899-17015-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove old init callback which now contains only a call to
socfpga_dwmac_setup(). Also rename socfpga_dwmac_setup() to indicate
what the function really does.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
Tested-by: Marek Vasut <marex@denx.de>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c | 17 +++--------------
 1 file changed, 3 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index ba49d8c..cd9764a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -136,7 +136,7 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
 	return 0;
 }
 
-static int socfpga_dwmac_setup(struct socfpga_dwmac *dwmac)
+static int socfpga_dwmac_set_phy_mode(struct socfpga_dwmac *dwmac)
 {
 	struct regmap *sys_mgr_base_addr = dwmac->sys_mgr_base_addr;
 	int phymode = dwmac->interface;
@@ -195,16 +195,6 @@ static int socfpga_dwmac_setup(struct socfpga_dwmac *dwmac)
 	return 0;
 }
 
-static int socfpga_dwmac_init(struct platform_device *pdev, void *priv)
-{
-	struct socfpga_dwmac *dwmac = priv;
-
-	/* Setup the phy mode in the system manager registers according to
-	 * devicetree configuration
-	 */
-	return socfpga_dwmac_setup(dwmac);
-}
-
 static int socfpga_dwmac_probe(struct platform_device *pdev)
 {
 	struct plat_stmmacenet_data *plat_dat;
@@ -245,7 +235,7 @@ static int socfpga_dwmac_probe(struct platform_device *pdev)
 		 */
 		dwmac->stmmac_rst = stpriv->stmmac_rst;
 
-		ret = socfpga_dwmac_init(pdev, dwmac);
+		ret = socfpga_dwmac_set_phy_mode(dwmac);
 	}
 
 	return ret;
@@ -254,11 +244,10 @@ static int socfpga_dwmac_probe(struct platform_device *pdev)
 #ifdef CONFIG_PM_SLEEP
 static int socfpga_dwmac_resume(struct device *dev)
 {
-	struct platform_device *pdev = to_platform_device(dev);
 	struct net_device *ndev = dev_get_drvdata(dev);
 	struct stmmac_priv *priv = netdev_priv(ndev);
 
-	socfpga_dwmac_init(pdev, priv->plat->bsp_priv);
+	socfpga_dwmac_set_phy_mode(priv->plat->bsp_priv);
 
 	/* Before the enet controller is suspended, the phy is suspended.
 	 * This causes the phy clock to be gated. The enet controller is
-- 
2.8.0
