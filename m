From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 05/12] net: axienet: Support phy-less mode of operation
Date: Tue,  5 May 2015 11:25:58 +0200
Message-ID: <9f96915ea98cb99b9c437930e08c27d5a00e465e.1430817941.git.michal.simek@xilinx.com>
References: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Srikanth Thokala <srikanth.thokala@xilinx.com>,
 linux-kernel@vger.kernel.org, monstr@monstr.eu,
 linux-arm-kernel@lists.infradead.org, Anirudha Sarangi <anirudh@xilinx.com>,
 John Linn <John.Linn@xilinx.com>,
 =?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
In-Reply-To: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
References: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Srikanth Thokala <srikanth.thokala@xilinx.com>

This patch adds proper checks to handle the PHY-less case.

Signed-off-by: Srikanth Thokala <sthokal@xilinx.com>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index b1081e1893b0..c6f2ba056c26 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -940,11 +940,10 @@ static int axienet_open(struct net_device *ndev)
 					     PHY_INTERFACE_MODE_RGMII_ID);
 		}
 
-		if (!lp->phy_dev) {
+		if (!lp->phy_dev)
 			dev_err(lp->dev, "of_phy_connect() failed\n");
-			return -ENODEV;
-		}
-		phy_start(lp->phy_dev);
+		else
+			phy_start(lp->phy_dev);
 	}
 
 	/* Enable tasklets for Axi DMA error handling */
@@ -1606,7 +1605,8 @@ static int axienet_of_probe(struct platform_device *op)
 	lp->coalesce_count_tx = XAXIDMA_DFT_TX_THRESHOLD;
 
 	lp->phy_node = of_parse_phandle(op->dev.of_node, "phy-handle", 0);
-	ret = axienet_mdio_setup(lp, op->dev.of_node);
+	if (lp->phy_node)
+		ret = axienet_mdio_setup(lp, op->dev.of_node);
 	if (ret)
 		dev_warn(&op->dev, "error registering MDIO bus\n");
 
-- 
2.3.5
