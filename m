From: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Subject: [PATCH net] xgene: Always get clk source, but ignore if it's missing for SGMII ports
Date: Thu, 3 Aug 2017 15:43:14 +0200
Message-ID: <20170803140311.34C7E50870B@solo.franken.de>
To: isubramanian@apm.com, kchudgar@apm.com, qnguyen@apm.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Laura Abbott <labbott@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Bogendoerfer <tbogendoerfer@suse.de>

Even the driver doesn't do anything with the clk source for SGMII
ports it needs to be enabled by doing a devm_clk_get(), if there is
a clk source in DT.

Fixes: 0db01097cabd ('xgene: Don't fail probe, if there is no clk resource for SGMII interfaces')
Signed-off-by: Thomas Bogendoerfer <tbogendoerfer@suse.de>
Tested-by: Laura Abbott <labbott@redhat.com>
Acked-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 86058a9f3417..1d307f2def2d 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1785,9 +1785,9 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 
 	xgene_enet_gpiod_get(pdata);
 
-	if (pdata->phy_mode != PHY_INTERFACE_MODE_SGMII) {
-		pdata->clk = devm_clk_get(&pdev->dev, NULL);
-		if (IS_ERR(pdata->clk)) {
+	pdata->clk = devm_clk_get(&pdev->dev, NULL);
+	if (IS_ERR(pdata->clk)) {
+		if (pdata->phy_mode != PHY_INTERFACE_MODE_SGMII) {
 			/* Abort if the clock is defined but couldn't be
 			 * retrived. Always abort if the clock is missing on
 			 * DT system as the driver can't cope with this case.
-- 
2.12.3
