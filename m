From: Joachim Eastwood <manabian@gmail.com>
Subject: [net-next PATCH 2/7] stmmac: dwmac-sti: remove clk NULL checks
Date: Sun, 30 Oct 2016 21:05:02 +0100
Message-ID: <20161030200507.851-3-manabian@gmail.com>
References: <20161030200507.851-1-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:34803 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752842AbcJ3UGf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 16:06:35 -0400
Received: by mail-lf0-f66.google.com with SMTP id i187so6041555lfe.1
        for <netdev@vger.kernel.org>; Sun, 30 Oct 2016 13:06:34 -0700 (PDT)
In-Reply-To: <20161030200507.851-1-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since sti_dwmac_parse_data() sets dwmac->clk to NULL if not clock was
provided in DT and NULL is a valid clock there is no need to check for
NULL before using this clock.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
index 075ed42..f009bf4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
@@ -191,7 +191,7 @@ static void stih4xx_fix_retime_src(void *priv, u32 spd)
 		}
 	}
 
-	if (src == TX_RETIME_SRC_CLKGEN && dwmac->clk && freq)
+	if (src == TX_RETIME_SRC_CLKGEN && freq)
 		clk_set_rate(dwmac->clk, freq);
 
 	regmap_update_bits(dwmac->regmap, reg, STIH4XX_RETIME_SRC_MASK,
@@ -222,7 +222,7 @@ static void stid127_fix_retime_src(void *priv, u32 spd)
 			freq = DWMAC_2_5MHZ;
 	}
 
-	if (dwmac->clk && freq)
+	if (freq)
 		clk_set_rate(dwmac->clk, freq);
 
 	regmap_update_bits(dwmac->regmap, reg, STID127_RETIME_SRC_MASK, val);
@@ -238,8 +238,7 @@ static int sti_dwmac_init(struct platform_device *pdev, void *priv)
 	u32 reg = dwmac->ctrl_reg;
 	u32 val;
 
-	if (dwmac->clk)
-		clk_prepare_enable(dwmac->clk);
+	clk_prepare_enable(dwmac->clk);
 
 	if (of_property_read_bool(np, "st,gmac_en"))
 		regmap_update_bits(regmap, reg, EN_MASK, EN);
@@ -258,8 +257,7 @@ static void sti_dwmac_exit(struct platform_device *pdev, void *priv)
 {
 	struct sti_dwmac *dwmac = priv;
 
-	if (dwmac->clk)
-		clk_disable_unprepare(dwmac->clk);
+	clk_disable_unprepare(dwmac->clk);
 }
 static int sti_dwmac_parse_data(struct sti_dwmac *dwmac,
 				struct platform_device *pdev)
-- 
2.10.1
