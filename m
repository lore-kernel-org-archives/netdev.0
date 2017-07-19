From: Philipp Zabel <p.zabel@pengutronix.de>
Subject: [PATCH 045/102] net: ethernet: hisi_femac: explicitly request exclusive reset control
Date: Wed, 19 Jul 2017 17:25:49 +0200
Message-ID: <20170719152646.25903-46-p.zabel@pengutronix.de>
References: <20170719152646.25903-1-p.zabel@pengutronix.de>
Cc: Philipp Zabel <p.zabel@pengutronix.de>,
        Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:41547 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932970AbdGSP3L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 11:29:11 -0400
In-Reply-To: <20170719152646.25903-1-p.zabel@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
 drivers/net/ethernet/hisilicon/hisi_femac.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hisi_femac.c b/drivers/net/ethernet/hisilicon/hisi_femac.c
index 2c2808830e957..10aa7590afd54 100644
--- a/drivers/net/ethernet/hisilicon/hisi_femac.c
+++ b/drivers/net/ethernet/hisilicon/hisi_femac.c
@@ -838,14 +838,14 @@ static int hisi_femac_drv_probe(struct platform_device *pdev)
 		goto out_free_netdev;
 	}
 
-	priv->mac_rst = devm_reset_control_get(dev, "mac");
+	priv->mac_rst = devm_reset_control_get_exclusive(dev, "mac");
 	if (IS_ERR(priv->mac_rst)) {
 		ret = PTR_ERR(priv->mac_rst);
 		goto out_disable_clk;
 	}
 	hisi_femac_core_reset(priv);
 
-	priv->phy_rst = devm_reset_control_get(dev, "phy");
+	priv->phy_rst = devm_reset_control_get_exclusive(dev, "phy");
 	if (IS_ERR(priv->phy_rst)) {
 		priv->phy_rst = NULL;
 	} else {
-- 
2.11.0
