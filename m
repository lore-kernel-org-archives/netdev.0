From: Joachim Eastwood <manabian@gmail.com>
Subject: [net-next v2 6/7] stmmac: dwmac-sti: clean up and rename sti_dwmac_init
Date: Fri,  4 Nov 2016 18:54:10 +0100
Message-ID: <20161104175411.12943-7-manabian@gmail.com>
References: <20161104175411.12943-1-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:35413 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965321AbcKDRza (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 13:55:30 -0400
Received: by mail-lf0-f66.google.com with SMTP id p100so5009082lfg.2
        for <netdev@vger.kernel.org>; Fri, 04 Nov 2016 10:55:30 -0700 (PDT)
In-Reply-To: <20161104175411.12943-1-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename sti_dwmac_init to sti_dwmac_set_mode which is a better
description for what it really does.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Tested-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
index b71888a..ac17bff 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
@@ -229,9 +229,8 @@ static void stid127_fix_retime_src(void *priv, u32 spd)
 	regmap_update_bits(dwmac->regmap, reg, STID127_RETIME_SRC_MASK, val);
 }
 
-static int sti_dwmac_init(struct platform_device *pdev, void *priv)
+static int sti_dwmac_set_mode(struct sti_dwmac *dwmac)
 {
-	struct sti_dwmac *dwmac = priv;
 	struct regmap *regmap = dwmac->regmap;
 	int iface = dwmac->interface;
 	u32 reg = dwmac->ctrl_reg;
@@ -245,7 +244,7 @@ static int sti_dwmac_init(struct platform_device *pdev, void *priv)
 	val = (iface == PHY_INTERFACE_MODE_REVMII) ? 0 : ENMII;
 	regmap_update_bits(regmap, reg, ENMII_MASK, val);
 
-	dwmac->fix_retime_src(priv, dwmac->speed);
+	dwmac->fix_retime_src(dwmac, dwmac->speed);
 
 	return 0;
 }
@@ -350,7 +349,7 @@ static int sti_dwmac_probe(struct platform_device *pdev)
 	if (ret)
 		return ret;
 
-	ret = sti_dwmac_init(pdev, plat_dat->bsp_priv);
+	ret = sti_dwmac_set_mode(dwmac);
 	if (ret)
 		goto disable_clk;
 
@@ -389,10 +388,9 @@ static int sti_dwmac_suspend(struct device *dev)
 static int sti_dwmac_resume(struct device *dev)
 {
 	struct sti_dwmac *dwmac = get_stmmac_bsp_priv(dev);
-	struct platform_device *pdev = to_platform_device(dev);
 
 	clk_prepare_enable(dwmac->clk);
-	sti_dwmac_init(pdev, dwmac);
+	sti_dwmac_set_mode(dwmac);
 
 	return stmmac_resume(dev);
 }
-- 
2.10.2
