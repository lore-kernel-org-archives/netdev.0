From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 06/12] net: axienet: Removed coding style errors and warnings
Date: Tue,  5 May 2015 11:25:59 +0200
Message-ID: <09779bc3c9caced5840763159e797322ac36d48e.1430817941.git.michal.simek@xilinx.com>
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

Removed checkpatch.pl errors and warnings.

Signed-off-by: Srikanth Thokala <sthokal@xilinx.com>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 20 ++++++++++----------
 drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c | 21 +++++++++++----------
 2 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index c6f2ba056c26..39bb2e93cc65 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -444,8 +444,8 @@ static void __axienet_device_reset(struct axienet_local *lp,
 	while (axienet_dma_in32(lp, offset) & XAXIDMA_CR_RESET_MASK) {
 		udelay(1);
 		if (--timeout == 0) {
-			dev_err(dev, "axienet_device_reset DMA "
-				"reset timeout!\n");
+			netdev_err(lp->ndev, "%s: DMA reset timeout!\n",
+				   __func__);
 			break;
 		}
 	}
@@ -484,8 +484,8 @@ static void axienet_device_reset(struct net_device *ndev)
 	}
 
 	if (axienet_dma_bd_init(ndev)) {
-		dev_err(&ndev->dev, "axienet_device_reset descriptor "
-			"allocation failed\n");
+		netdev_err(ndev, "%s: descriptor allocation failed\n",
+			   __func__);
 	}
 
 	axienet_status = axienet_ior(lp, XAE_RCW1_OFFSET);
@@ -560,8 +560,8 @@ static void axienet_adjust_link(struct net_device *ndev)
 			lp->last_link = link_state;
 			phy_print_status(phy);
 		} else {
-			dev_err(&ndev->dev, "Error setting Axi Ethernet "
-				"mac speed\n");
+			netdev_err(ndev,
+				   "Error setting Axi Ethernet mac speed\n");
 		}
 	}
 }
@@ -1238,8 +1238,8 @@ axienet_ethtools_set_pauseparam(struct net_device *ndev,
 	struct axienet_local *lp = netdev_priv(ndev);
 
 	if (netif_running(ndev)) {
-		printk(KERN_ERR	"%s: Please stop netif before applying "
-		       "configruation\n", ndev->name);
+		netdev_err(ndev,
+			   "Please stop netif before applying configuration\n");
 		return -EFAULT;
 	}
 
@@ -1295,8 +1295,8 @@ static int axienet_ethtools_set_coalesce(struct net_device *ndev,
 	struct axienet_local *lp = netdev_priv(ndev);
 
 	if (netif_running(ndev)) {
-		printk(KERN_ERR	"%s: Please stop netif before applying "
-		       "configruation\n", ndev->name);
+		netdev_err(ndev,
+			   "Please stop netif before applying configuration\n");
 		return -EFAULT;
 	}
 
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c b/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c
index 3b67d60d4378..fce557518b7d 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c
@@ -161,19 +161,19 @@ int axienet_mdio_setup(struct axienet_local *lp, struct device_node *np)
 
 	np1 = of_find_node_by_name(NULL, "cpu");
 	if (!np1) {
-		printk(KERN_WARNING "%s(): Could not find CPU device node.",
-		       __func__);
-		printk(KERN_WARNING "Setting MDIO clock divisor to "
-		       "default %d\n", DEFAULT_CLOCK_DIVISOR);
+		netdev_warn(lp->ndev, "Could not find CPU device node.\n");
+		netdev_warn(lp->ndev,
+			    "Setting MDIO clock divisor to default %d\n",
+			    DEFAULT_CLOCK_DIVISOR);
 		clk_div = DEFAULT_CLOCK_DIVISOR;
 		goto issue;
 	}
 	property_p = (u32 *) of_get_property(np1, "clock-frequency", NULL);
 	if (!property_p) {
-		printk(KERN_WARNING "%s(): Could not find CPU property: "
-		       "clock-frequency.", __func__);
-		printk(KERN_WARNING "Setting MDIO clock divisor to "
-		       "default %d\n", DEFAULT_CLOCK_DIVISOR);
+		netdev_warn(lp->ndev, "clock-frequency property not found.\n");
+		netdev_warn(lp->ndev,
+			    "Setting MDIO clock divisor to default %d\n",
+			    DEFAULT_CLOCK_DIVISOR);
 		clk_div = DEFAULT_CLOCK_DIVISOR;
 		of_node_put(np1);
 		goto issue;
@@ -187,8 +187,9 @@ int axienet_mdio_setup(struct axienet_local *lp, struct device_node *np)
 	if (host_clock % (MAX_MDIO_FREQ * 2))
 		clk_div++;
 
-	printk(KERN_DEBUG "%s(): Setting MDIO clock divisor to %u based "
-	       "on %u Hz host clock.\n", __func__, clk_div, host_clock);
+	netdev_dbg(lp->ndev,
+		   "Setting MDIO clock divisor to %u/%u Hz host clock.\n",
+		   clk_div, host_clock);
 
 	of_node_put(np1);
 issue:
-- 
2.3.5
