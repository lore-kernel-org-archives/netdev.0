From: Philipp Zabel <p.zabel@pengutronix.de>
Subject: [PATCH 047/102] net: stmmac: explicitly request exclusive reset control
Date: Wed, 19 Jul 2017 17:25:51 +0200
Message-ID: <20170719152646.25903-48-p.zabel@pengutronix.de>
References: <20170719152646.25903-1-p.zabel@pengutronix.de>
Cc: Philipp Zabel <p.zabel@pengutronix.de>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Maxime Ripard <maxime.ripard@free-electrons.com>,
        Chen-Yu Tsai <wens@csie.org>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170719152646.25903-1-p.zabel@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit a53e35db70d1 ("reset: Ensure drivers are explicit when requesting
reset lines") started to transition the reset control request API calls
to explicitly state whether the driver needs exclusive or shared reset
control behavior. Convert all drivers requesting exclusive resets to the
explicit API call so the temporary transition helpers can be removed.

No functional changes.

Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Alexandre Torgue <alexandre.torgue@st.com>
Cc: Maxime Ripard <maxime.ripard@free-electrons.com>
Cc: Chen-Yu Tsai <wens@csie.org>
Cc: netdev@vger.kernel.org
Signed-off-by: Philipp Zabel <p.zabel@pengutronix.de>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c     | 3 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 4 ++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
index fffd6d5fc907b..2771369c105d6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
@@ -942,7 +942,8 @@ static int sun8i_dwmac_probe(struct platform_device *pdev)
 			return -EINVAL;
 		}
 
-		gmac->rst_ephy = of_reset_control_get(plat_dat->phy_node, NULL);
+		gmac->rst_ephy = of_reset_control_get_exclusive(plat_dat->phy_node,
+								NULL);
 		if (IS_ERR(gmac->rst_ephy)) {
 			ret = PTR_ERR(gmac->rst_ephy);
 			if (ret == -EPROBE_DEFER)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index a366b3747eeb5..5f94bbf745546 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -526,8 +526,8 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 		dev_dbg(&pdev->dev, "PTP rate %d\n", plat->clk_ptp_rate);
 	}
 
-	plat->stmmac_rst = devm_reset_control_get(&pdev->dev,
-						  STMMAC_RESOURCE_NAME);
+	plat->stmmac_rst = devm_reset_control_get_exclusive(&pdev->dev,
+							    STMMAC_RESOURCE_NAME);
 	if (IS_ERR(plat->stmmac_rst)) {
 		if (PTR_ERR(plat->stmmac_rst) == -EPROBE_DEFER)
 			goto error_hw_init;
-- 
2.11.0
