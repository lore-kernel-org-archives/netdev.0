From: Caesar Wang <wxt@rock-chips.com>
Subject: [PATCH 1/4] net: stmmac: dwmac-rk: fixes the gmac resume after PD on/off
Date: Wed, 31 Aug 2016 04:30:04 +0800
Message-ID: <1472589008-7713-2-git-send-email-wxt@rock-chips.com>
References: <1472589008-7713-1-git-send-email-wxt@rock-chips.com>
Cc: linux-rockchip@lists.infradead.org,
        Brian Norris <briannorris@chromium.org>,
        Douglas Anderson <dianders@chromium.org>,
        dbasehore@chromium.org, Roger Chen <roger.chen@rock-chips.com>,
        Caesar Wang <wxt@rock-chips.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        linux-kernel@vger.kernel.org
To: Heiko Stuebner <heiko@sntech.de>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472589008-7713-1-git-send-email-wxt@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roger Chen <roger.chen@rock-chips.com>

GMAC Power Domain(PD) will be disabled during suspend.
That will causes GRF registers reset.
So corresponding GRF registers for GMAC must be setup again.

Signed-off-by: Roger Chen <roger.chen@rock-chips.com>
Signed-off-by: Caesar Wang <wxt@rock-chips.com>
---

 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 9210591..ea0e493 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -629,6 +629,17 @@ static struct rk_priv_data *rk_gmac_setup(struct platform_device *pdev,
 							"rockchip,grf");
 	bsp_priv->pdev = pdev;
 
+	gmac_clk_init(bsp_priv);
+
+	return bsp_priv;
+}
+
+static int rk_gmac_init(struct platform_device *pdev, void *priv)
+{
+	struct rk_priv_data *bsp_priv = priv;
+	int ret;
+	struct device *dev = &pdev->dev;
+
 	/*rmii or rgmii*/
 	if (bsp_priv->phy_iface == PHY_INTERFACE_MODE_RGMII) {
 		dev_info(dev, "init for RGMII\n");
@@ -641,15 +652,6 @@ static struct rk_priv_data *rk_gmac_setup(struct platform_device *pdev,
 		dev_err(dev, "NO interface defined!\n");
 	}
 
-	gmac_clk_init(bsp_priv);
-
-	return bsp_priv;
-}
-
-static int rk_gmac_powerup(struct rk_priv_data *bsp_priv)
-{
-	int ret;
-
 	ret = phy_power_on(bsp_priv, true);
 	if (ret)
 		return ret;
-- 
1.9.1
