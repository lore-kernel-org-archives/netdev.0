From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 01/12] net: axienet: Support for RGMII
Date: Tue,  5 May 2015 11:25:54 +0200
Message-ID: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
Cc: Srikanth Thokala <srikanth.thokala@xilinx.com>,
	=?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
	monstr@monstr.eu, John Linn <John.Linn@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Srikanth Thokala <srikanth.thokala@xilinx.com>

This patch adds support for the RGMII. The h/w configuration
parameter C_PHY_TYPE, which represents the interface configured in
the design, is used to differentiate various interfaces supported
by AXI Ethernet.

Signed-off-by: Srikanth Thokala <sthokal@xilinx.com>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 28b7e7d9c272..0ab607732bb4 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -925,9 +925,16 @@ static int axienet_open(struct net_device *ndev)
 		return ret;
 
 	if (lp->phy_node) {
-		lp->phy_dev = of_phy_connect(lp->ndev, lp->phy_node,
+		if (lp->phy_type == XAE_PHY_TYPE_GMII) {
+			lp->phy_dev = of_phy_connect(lp->ndev, lp->phy_node,
 					     axienet_adjust_link, 0,
 					     PHY_INTERFACE_MODE_GMII);
+		} else if (lp->phy_type == XAE_PHY_TYPE_RGMII_2_0) {
+			lp->phy_dev = of_phy_connect(lp->ndev, lp->phy_node,
+					     axienet_adjust_link, 0,
+					     PHY_INTERFACE_MODE_RGMII_ID);
+		}
+
 		if (!lp->phy_dev) {
 			dev_err(lp->dev, "of_phy_connect() failed\n");
 			return -ENODEV;
-- 
2.3.5
