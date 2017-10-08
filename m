From: Christos Gkekas <chris.gekas@gmail.com>
Subject: [PATCH] net: ethernet: stmmac: Clean up dead code
Date: Sun,  8 Oct 2017 20:13:49 +0100
Message-ID: <1507490029-26406-1-git-send-email-chris.gekas@gmail.com>
Cc: Christos Gkekas <chris.gekas@gmail.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many macros in dwmac-ipq806x are unused and should be removed.
Moreover gmac->id is an unsigned variable and therefore checking
whether it is less than zero is redundant.

Signed-off-by: Christos Gkekas <chris.gekas@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c
index 866444b..2c6d7c6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c
@@ -51,15 +51,11 @@
 #define NSS_COMMON_CLK_SRC_CTRL_RGMII(x)	1
 #define NSS_COMMON_CLK_SRC_CTRL_SGMII(x)	((x >= 2) ? 1 : 0)
 
-#define NSS_COMMON_MACSEC_CTL			0x28
-#define NSS_COMMON_MACSEC_CTL_EXT_BYPASS_EN(x)	(1 << x)
-
 #define NSS_COMMON_GMAC_CTL(x)			(0x30 + (x * 4))
 #define NSS_COMMON_GMAC_CTL_CSYS_REQ		BIT(19)
 #define NSS_COMMON_GMAC_CTL_PHY_IFACE_SEL	BIT(16)
 #define NSS_COMMON_GMAC_CTL_IFG_LIMIT_OFFSET	8
 #define NSS_COMMON_GMAC_CTL_IFG_OFFSET		0
-#define NSS_COMMON_GMAC_CTL_IFG_MASK		0x3f
 
 #define NSS_COMMON_CLK_DIV_RGMII_1000		1
 #define NSS_COMMON_CLK_DIV_RGMII_100		9
@@ -68,9 +64,6 @@
 #define NSS_COMMON_CLK_DIV_SGMII_100		4
 #define NSS_COMMON_CLK_DIV_SGMII_10		49
 
-#define QSGMII_PCS_MODE_CTL			0x68
-#define QSGMII_PCS_MODE_CTL_AUTONEG_EN(x)	BIT((x * 8) + 7)
-
 #define QSGMII_PCS_CAL_LCKDT_CTL		0x120
 #define QSGMII_PCS_CAL_LCKDT_CTL_RST		BIT(19)
 
@@ -83,15 +76,10 @@
 #define QSGMII_PHY_TX_DRIVER_EN			BIT(3)
 #define QSGMII_PHY_QSGMII_EN			BIT(7)
 #define QSGMII_PHY_PHASE_LOOP_GAIN_OFFSET	12
-#define QSGMII_PHY_PHASE_LOOP_GAIN_MASK		0x7
 #define QSGMII_PHY_RX_DC_BIAS_OFFSET		18
-#define QSGMII_PHY_RX_DC_BIAS_MASK		0x3
 #define QSGMII_PHY_RX_INPUT_EQU_OFFSET		20
-#define QSGMII_PHY_RX_INPUT_EQU_MASK		0x3
 #define QSGMII_PHY_CDR_PI_SLEW_OFFSET		22
-#define QSGMII_PHY_CDR_PI_SLEW_MASK		0x3
 #define QSGMII_PHY_TX_DRV_AMP_OFFSET		28
-#define QSGMII_PHY_TX_DRV_AMP_MASK		0xf
 
 struct ipq806x_gmac {
 	struct platform_device *pdev;
@@ -217,7 +205,7 @@ static int ipq806x_gmac_of_parse(struct ipq806x_gmac *gmac)
 	 * code and keep it consistent with the Linux convention, we'll number
 	 * them from 0 to 3 here.
 	 */
-	if (gmac->id < 0 || gmac->id > 3) {
+	if (gmac->id > 3) {
 		dev_err(dev, "invalid gmac id\n");
 		return -EINVAL;
 	}
-- 
2.7.4
