From: Alvaro Gamez Machado <alvaro.gamez@hazent.com>
Subject: [PATCH] net: axienet: add of_phy_connect call for XAE_PHY_TYPE_MII case
Date: Fri, 30 Jun 2017 11:25:41 +0200
Message-ID: <20170630092541.27234-1-alvaro.gamez@hazent.com>
Cc: Alvaro Gamez Machado <alvaro.gamez@hazent.com>
To: Anirudha Sarangi <anirudh@xilinx.com>,
        John Linn <John.Linn@xilinx.com>,
        Michal Simek <michal.simek@xilinx.com>,
        =?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This IP core has support for mii connectivity to the phy, so be ready to
connect to it when this is the case.

Signed-off-by: Alvaro Gamez Machado <alvaro.gamez@hazent.com>
---
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 33c595f4691d..9b3f55449b5e 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -935,7 +935,11 @@ static int axienet_open(struct net_device *ndev)
 		return ret;
 
 	if (lp->phy_node) {
-		if (lp->phy_type == XAE_PHY_TYPE_GMII) {
+		if (lp->phy_type == XAE_PHY_TYPE_MII) {
+			phydev = of_phy_connect(lp->ndev, lp->phy_node,
+						axienet_adjust_link, 0,
+						PHY_INTERFACE_MODE_MII);
+		} else if (lp->phy_type == XAE_PHY_TYPE_GMII) {
 			phydev = of_phy_connect(lp->ndev, lp->phy_node,
 						axienet_adjust_link, 0,
 						PHY_INTERFACE_MODE_GMII);
-- 
2.11.0
