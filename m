From: Philipp Zabel <p.zabel@pengutronix.de>
Subject: [PATCH 046/102] net: ethernet: hix5hd2_gmac: explicitly request exclusive reset control
Date: Wed, 19 Jul 2017 17:25:50 +0200
Message-ID: <20170719152646.25903-47-p.zabel@pengutronix.de>
References: <20170719152646.25903-1-p.zabel@pengutronix.de>
Cc: Philipp Zabel <p.zabel@pengutronix.de>,
        Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>, netdev@vger.kernel.org
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

Cc: Yisen Zhuang <yisen.zhuang@huawei.com>
Cc: Salil Mehta <salil.mehta@huawei.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Philipp Zabel <p.zabel@pengutronix.de>
---
 drivers/net/ethernet/hisilicon/hix5hd2_gmac.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
index 25a6c8722ecac..02b7e2f490099 100644
--- a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
@@ -1161,16 +1161,16 @@ static int hix5hd2_dev_probe(struct platform_device *pdev)
 		goto out_disable_mac_core_clk;
 	}
 
-	priv->mac_core_rst = devm_reset_control_get(dev, "mac_core");
+	priv->mac_core_rst = devm_reset_control_get_exclusive(dev, "mac_core");
 	if (IS_ERR(priv->mac_core_rst))
 		priv->mac_core_rst = NULL;
 	hix5hd2_mac_core_reset(priv);
 
-	priv->mac_ifc_rst = devm_reset_control_get(dev, "mac_ifc");
+	priv->mac_ifc_rst = devm_reset_control_get_exclusive(dev, "mac_ifc");
 	if (IS_ERR(priv->mac_ifc_rst))
 		priv->mac_ifc_rst = NULL;
 
-	priv->phy_rst = devm_reset_control_get(dev, "phy");
+	priv->phy_rst = devm_reset_control_get_exclusive(dev, "phy");
 	if (IS_ERR(priv->phy_rst)) {
 		priv->phy_rst = NULL;
 	} else {
-- 
2.11.0
