From: Philipp Zabel <p.zabel@pengutronix.de>
Subject: [PATCH 048/102] net: stmmac: dwc-qos: explicitly request exclusive reset control
Date: Wed, 19 Jul 2017 17:25:52 +0200
Message-ID: <20170719152646.25903-49-p.zabel@pengutronix.de>
References: <20170719152646.25903-1-p.zabel@pengutronix.de>
Cc: Philipp Zabel <p.zabel@pengutronix.de>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:46137 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932941AbdGSP3J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 11:29:09 -0400
In-Reply-To: <20170719152646.25903-1-p.zabel@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit a53e35db70d1 ("reset: Ensure drivers are explicit when requesting
reset lines") started to transition the reset control request API calls
to explicitly state whether the driver needs exclusive or shared reset
control behavior. Convert all drivers requesting exclusive resets to the
explicit API call so the temporary transition helpers can be removed.

No functional changes.

Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Alexandre Torgue <alexandre.torgue@st.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Philipp Zabel <p.zabel@pengutronix.de>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
index dd6a2f9791cc1..cf4e0f09c0361 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
@@ -339,7 +339,7 @@ static void *tegra_eqos_probe(struct platform_device *pdev,
 	usleep_range(2000, 4000);
 	gpiod_set_value(eqos->reset, 0);
 
-	eqos->rst = devm_reset_control_get(&pdev->dev, "eqos");
+	eqos->rst = devm_reset_control_get_exclusive(&pdev->dev, "eqos");
 	if (IS_ERR(eqos->rst)) {
 		err = PTR_ERR(eqos->rst);
 		goto reset_phy;
-- 
2.11.0
