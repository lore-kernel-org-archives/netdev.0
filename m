From: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/2] net: mv643xx_eth: add shared clk and cleanup existing clk
 handling
Date: Thu, 11 Apr 2013 11:29:33 +0200
Message-ID: <1365672574-31123-2-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1365672574-31123-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>,
 Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
 linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>,
 Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
 Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>
To: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1365672574-31123-1-git-send-email-sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

This patch adds an optional shared block clock to avoid lockups on
clock gated controllers. Besides the new clock, clock handling for
existing clocks is cleaned up and moved to devm_clk_get. Device
tree binding documentation is updated for the new clocks property.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Cc: Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>
Cc: Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
Cc: Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>
Cc: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Cc: Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>
Cc: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Cc: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Cc: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
Cc: linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Cc: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Cc: linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 Documentation/devicetree/bindings/marvell.txt |    3 +++
 drivers/net/ethernet/marvell/mv643xx_eth.c    |   27 ++++++++++---------------
 2 files changed, 14 insertions(+), 16 deletions(-)

diff --git a/Documentation/devicetree/bindings/marvell.txt b/Documentation/devicetree/bindings/marvell.txt
index f1533d9..f7a0da6 100644
--- a/Documentation/devicetree/bindings/marvell.txt
+++ b/Documentation/devicetree/bindings/marvell.txt
@@ -115,6 +115,9 @@ prefixed with the string "marvell,", for Marvell Technology Group Ltd.
      - compatible : "marvell,mv64360-eth-block"
      - reg : Offset and length of the register set for this block
 
+   Optional properties:
+     - clocks : Phandle to the clock control device and gate bit
+
    Example Discovery Ethernet block node:
      ethernet-block@2000 {
 	     #address-cells = <1>;
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index aedbd82..bbe6104 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -268,7 +268,7 @@ struct mv643xx_eth_shared_private {
 	int extended_rx_coal_limit;
 	int tx_bw_control;
 	int tx_csum_limit;
-
+	struct clk *clk;
 };
 
 #define TX_BW_CONTROL_ABSENT		0
@@ -410,9 +410,7 @@ struct mv643xx_eth_private {
 	/*
 	 * Hardware-specific parameters.
 	 */
-#if defined(CONFIG_HAVE_CLK)
 	struct clk *clk;
-#endif
 	unsigned int t_clk;
 };
 
@@ -2569,6 +2567,10 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 	if (msp->base == NULL)
 		goto out_free;
 
+	msp->clk = devm_clk_get(&pdev->dev, NULL);
+	if (!IS_ERR(msp->clk))
+		clk_prepare_enable(msp->clk);
+
 	/*
 	 * (Re-)program MBUS remapping windows if we are asked to.
 	 */
@@ -2595,6 +2597,8 @@ static int mv643xx_eth_shared_remove(struct platform_device *pdev)
 	struct mv643xx_eth_shared_private *msp = platform_get_drvdata(pdev);
 
 	iounmap(msp->base);
+	if (!IS_ERR(msp->clk))
+		clk_disable_unprepare(msp->clk);
 	kfree(msp);
 
 	return 0;
@@ -2801,13 +2805,12 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	 * it to override the default.
 	 */
 	mp->t_clk = 133000000;
-#if defined(CONFIG_HAVE_CLK)
-	mp->clk = clk_get(&pdev->dev, (pdev->id ? "1" : "0"));
+	mp->clk = devm_clk_get(&pdev->dev, NULL);
 	if (!IS_ERR(mp->clk)) {
 		clk_prepare_enable(mp->clk);
 		mp->t_clk = clk_get_rate(mp->clk);
 	}
-#endif
+
 	set_params(mp, pd);
 	netif_set_real_num_tx_queues(dev, mp->txq_count);
 	netif_set_real_num_rx_queues(dev, mp->rxq_count);
@@ -2889,12 +2892,8 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	return 0;
 
 out:
-#if defined(CONFIG_HAVE_CLK)
-	if (!IS_ERR(mp->clk)) {
+	if (!IS_ERR(mp->clk))
 		clk_disable_unprepare(mp->clk);
-		clk_put(mp->clk);
-	}
-#endif
 	free_netdev(dev);
 
 	return err;
@@ -2909,12 +2908,8 @@ static int mv643xx_eth_remove(struct platform_device *pdev)
 		phy_detach(mp->phy);
 	cancel_work_sync(&mp->tx_timeout_task);
 
-#if defined(CONFIG_HAVE_CLK)
-	if (!IS_ERR(mp->clk)) {
+	if (!IS_ERR(mp->clk))
 		clk_disable_unprepare(mp->clk);
-		clk_put(mp->clk);
-	}
-#endif
 
 	free_netdev(mp->dev);
 
-- 
1.7.10.4
