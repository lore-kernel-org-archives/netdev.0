From: Vincent Palatin <vpalatin@chromium.org>
Subject: [PATCH] net: stmmac: dwmac-rk: keep PHY up for WoL
Date: Fri,  3 Jun 2016 10:29:20 -0700
Message-ID: <1464974960-26672-1-git-send-email-vpalatin@chromium.org>
Cc: linux-kernel@vger.kernel.org,
	Alexandre Torgue <alexandre.torgue@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	=?UTF-8?q?Heiko=20St=C3=BCbner?= <heiko@sntech.de>,
	Vincent Palatin <vpalatin@chromium.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do not shutdown the PHY if Wake-on-Lan is enabled, else it cannot wake
us up.

Signed-off-by: Vincent Palatin <vpalatin@chromium.org>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 0cd3ecf..2e45e75 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -534,6 +534,10 @@ static int rk_gmac_init(struct platform_device *pdev, void *priv)
 	struct rk_priv_data *bsp_priv = priv;
 	int ret;
 
+	/* Keep the PHY up if we use Wake-on-Lan. */
+	if (device_may_wakeup(&pdev->dev))
+		return 0;
+
 	ret = phy_power_on(bsp_priv, true);
 	if (ret)
 		return ret;
@@ -549,6 +553,10 @@ static void rk_gmac_exit(struct platform_device *pdev, void *priv)
 {
 	struct rk_priv_data *gmac = priv;
 
+	/* The PHY was up for Wake-on-Lan. */
+	if (device_may_wakeup(&pdev->dev))
+		return;
+
 	phy_power_on(gmac, false);
 	gmac_clk_enable(gmac, false);
 }
-- 
2.8.0.rc3.226.g39d4020
