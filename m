From: Peter Griffin <peter.griffin@linaro.org>
Subject: [PATCH 18/19] stmmac: dwmac-sti: Remove obsolete STi platforms
Date: Wed, 14 Sep 2016 14:27:56 +0100
Message-ID: <1473859677-9231-19-git-send-email-peter.griffin@linaro.org>
References: <1473859677-9231-1-git-send-email-peter.griffin@linaro.org>
Cc: peter.griffin@linaro.org, lee.jones@linaro.org,
        <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>
To: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        kernel@stlinux.com, patrice.chotard@st.com,
        devicetree@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473859677-9231-1-git-send-email-peter.griffin@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes support for STiH415/6 SoC's from the
dwmac-sti driver and dt binding doc, as support for these
platforms is being removed from the kernel. It also removes
STiD127 related code, which has never actually been supported
upstream.

Signed-off-by: Peter Griffin <peter.griffin@linaro.org>
Cc: <peppe.cavallaro@st.com>
Cc: <alexandre.torgue@st.com>
Cc: <netdev@vger.kernel.org>
---
 .../devicetree/bindings/net/sti-dwmac.txt          |  3 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c    | 37 ----------------------
 2 files changed, 1 insertion(+), 39 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/sti-dwmac.txt b/Documentation/devicetree/bindings/net/sti-dwmac.txt
index d05c1e1..2031786 100644
--- a/Documentation/devicetree/bindings/net/sti-dwmac.txt
+++ b/Documentation/devicetree/bindings/net/sti-dwmac.txt
@@ -7,8 +7,7 @@ and what is needed on STi platforms to program the stmmac glue logic.
 The device node has following properties.
 
 Required properties:
- - compatible	: Can be "st,stih415-dwmac", "st,stih416-dwmac",
-   "st,stih407-dwmac", "st,stid127-dwmac".
+ - compatible	: Should be "st,stih407-dwmac".
  - st,syscon : Should be phandle/offset pair. The phandle to the syscon node which
    encompases the glue register, and the offset of the control register.
  - st,gmac_en: this is to enable the gmac into a dedicated sysctl control
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
index 58c05ac..fcbe374 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
@@ -198,36 +198,6 @@ static void stih4xx_fix_retime_src(void *priv, u32 spd)
 			   stih4xx_tx_retime_val[src]);
 }
 
-static void stid127_fix_retime_src(void *priv, u32 spd)
-{
-	struct sti_dwmac *dwmac = priv;
-	u32 reg = dwmac->ctrl_reg;
-	u32 freq = 0;
-	u32 val = 0;
-
-	if (dwmac->interface == PHY_INTERFACE_MODE_MII) {
-		val = STID127_ETH_SEL_INTERNAL_NOTEXT_TXCLK;
-	} else if (dwmac->interface == PHY_INTERFACE_MODE_RMII) {
-		if (!dwmac->ext_phyclk) {
-			val = STID127_ETH_SEL_INTERNAL_NOTEXT_PHYCLK;
-			freq = DWMAC_50MHZ;
-		}
-	} else if (IS_PHY_IF_MODE_RGMII(dwmac->interface)) {
-		val = STID127_ETH_SEL_INTERNAL_NOTEXT_TXCLK;
-		if (spd == SPEED_1000)
-			freq = DWMAC_125MHZ;
-		else if (spd == SPEED_100)
-			freq = DWMAC_25MHZ;
-		else if (spd == SPEED_10)
-			freq = DWMAC_2_5MHZ;
-	}
-
-	if (dwmac->clk && freq)
-		clk_set_rate(dwmac->clk, freq);
-
-	regmap_update_bits(dwmac->regmap, reg, STID127_RETIME_SRC_MASK, val);
-}
-
 static int sti_dwmac_init(struct platform_device *pdev, void *priv)
 {
 	struct sti_dwmac *dwmac = priv;
@@ -372,14 +342,7 @@ static const struct sti_dwmac_of_data stih4xx_dwmac_data = {
 	.fix_retime_src = stih4xx_fix_retime_src,
 };
 
-static const struct sti_dwmac_of_data stid127_dwmac_data = {
-	.fix_retime_src = stid127_fix_retime_src,
-};
-
 static const struct of_device_id sti_dwmac_match[] = {
-	{ .compatible = "st,stih415-dwmac", .data = &stih4xx_dwmac_data},
-	{ .compatible = "st,stih416-dwmac", .data = &stih4xx_dwmac_data},
-	{ .compatible = "st,stid127-dwmac", .data = &stid127_dwmac_data},
 	{ .compatible = "st,stih407-dwmac", .data = &stih4xx_dwmac_data},
 	{ }
 };
-- 
1.9.1
