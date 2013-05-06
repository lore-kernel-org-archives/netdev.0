From: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v3 1/7] net: mv643xx_eth: add Device Tree bindings
Date: Mon,  6 May 2013 17:33:34 +0200
Message-ID: <1367854420-8006-2-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1365071235-11611-1-git-send-email-florian@openwrt.org>
 <1367854420-8006-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Jamie Lentin <jm-Pj/HzkgeCk7QXOPxS62xeg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Nigel Roberts <nigel-BZPLJ9//LnDby3iVrkZq2A@public.gmane.org>, Arnaud Patard <arnaud.patard-dQbF7i+pzddAfugRpC6u6w@public.gmane.org>,
 Valentin Longchamp <valentin.longchamp-SkAbAL50j+5BDgjK7y7TUQ@public.gmane.org>,
 Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
 Simon Guinot <simon.guinot-jKBdWWKqtFpg9hUCZPvPmw@public.gmane.org>,
 Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
 Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>,
 Eric Hutter <hutter.eric-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>,
 devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Arnaud Ebalard <arno-LkuqDEemtHBg9hUCZPvPmw@public.gmane.org>,
 Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>, Joshua Coombs <josh.coombs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 Jean-Francois Moine <moinejf-GANU6spQydw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Alan M Butler <alanbutty12-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Willy Tarreau <w@1wt.eu>,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1367854420-8006-1-git-send-email-sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

From: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>

This patch adds Device Tree bindings following the already defined
bindings at Documentation/devicetree/bindings/marvell.txt. The binding
documentation is also enhanced with new optionnal properties required
for supporting certain devices (RX/TX queue and SRAM). Since we now have
proper support for the orion MDIO bus driver, there is no need to fiddle
around with device tree phandles. PHY-less (MAC connected to switch)
configurations are supported by not specifying any phy phandle for an
ethernet node.

Signed-off-by: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
Changelog:
v2->v3:
- rebase on top of mv643xx_eth clean-ups
- do not reparse existing platform_data
- use managed devm_kzalloc for parsed platform_data
- use of_property_read_u32 where applicable
- add phy_node to platform_data
- use of_connect_phy if DT phy node was found

v1->v2:
- properly ifdef of_platform_bus_probe with CONFIG_OF
- handle of_platform_bus_probe errors and cleanup accordingly
- use of_property_read_u32 where applicable
- parse "duplex" and "speed" property in PHY-less configuration

Cc: Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Cc: Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>
Cc: Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
Cc: Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Cc: Arnaud Patard <arnaud.patard-dQbF7i+pzddAfugRpC6u6w@public.gmane.org>
Cc: Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Cc: Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Cc: Jean-Francois Moine <moinejf-GANU6spQydw@public.gmane.org>
Cc: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Cc: Simon Guinot <simon.guinot-jKBdWWKqtFpg9hUCZPvPmw@public.gmane.org>
Cc: Jamie Lentin <jm-Pj/HzkgeCk7QXOPxS62xeg@public.gmane.org>
Cc: Michael Walle <michael-QKn5cuLxLXY@public.gmane.org>
Cc: Eric Hutter <hutter.eric-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Joshua Coombs <josh.coombs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Willy Tarreau <w@1wt.eu>
Cc: Simon Baatz <gmbnomis-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Alan M Butler <alanbutty12-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Nigel Roberts <nigel-BZPLJ9//LnDby3iVrkZq2A@public.gmane.org>
Cc: Valentin Longchamp <valentin.longchamp-SkAbAL50j+5BDgjK7y7TUQ@public.gmane.org>
Cc: Stefan Peter <s.peter-R0yVo0h44Ow@public.gmane.org>
Cc: Arnaud Ebalard <arno-LkuqDEemtHBg9hUCZPvPmw@public.gmane.org>
Cc: Nobuhiro Iwamatsu <iwamatsu-+mkmVskJBflAfugRpC6u6w@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Cc: linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 Documentation/devicetree/bindings/marvell.txt |   22 +++++-
 drivers/net/ethernet/marvell/mv643xx_eth.c    |  108 ++++++++++++++++++++++++-
 include/linux/mv643xx_eth.h                   |    3 +
 3 files changed, 128 insertions(+), 5 deletions(-)

diff --git a/Documentation/devicetree/bindings/marvell.txt b/Documentation/devicetree/bindings/marvell.txt
index f7a0da6..73ea12f 100644
--- a/Documentation/devicetree/bindings/marvell.txt
+++ b/Documentation/devicetree/bindings/marvell.txt
@@ -112,11 +112,13 @@ prefixed with the string "marvell,", for Marvell Technology Group Ltd.
    Required properties:
      - #address-cells : <1>
      - #size-cells : <0>
-     - compatible : "marvell,mv64360-eth-block"
+     - compatible : "marvell,mv64360-eth-block", "marvell,mv643xx-eth-block"
      - reg : Offset and length of the register set for this block
 
    Optional properties:
      - clocks : Phandle to the clock control device and gate bit
+     - tx-csum-limit : Hardware limit above which transmit checksumming
+                       is disabled.
 
    Example Discovery Ethernet block node:
      ethernet-block@2000 {
@@ -133,7 +135,7 @@ prefixed with the string "marvell,", for Marvell Technology Group Ltd.
 
    Required properties:
      - device_type : Should be "network".
-     - compatible : Should be "marvell,mv64360-eth".
+     - compatible : Should be "marvell,mv64360-eth", "marvell,mv643xx-eth"
      - reg : Should be <0>, <1>, or <2>, according to which registers
        within the silicon block the device uses.
      - interrupts : <a> where a is the interrupt number for the port.
@@ -143,6 +145,22 @@ prefixed with the string "marvell,", for Marvell Technology Group Ltd.
        controller.
      - local-mac-address : 6 bytes, MAC address
 
+   Optional properties:
+     - clocks : Phandle to the clock control device and gate bit
+     - clock-names : String describing the clock gate bit
+     - speed : Speed to force the link (10, 100, 1000), used when no
+               phy property is defined
+     - duplex : Duplex to force the link (0: half, 1: full), used when no
+               phy property is defined
+     - rx-queue-count : number of RX queues to use
+     - tx-queue-count : number of TX queues to use
+     - rx-queue-size : size of the RX queue (in bytes)
+     - tx-queue-size : size of the TX queue (in bytes)
+     - rx-sram-addr : address of the SRAM for RX path (non 0 means used)
+     - rx-sram-size : size of the SRAM for RX path (non 0 means used)
+     - tx-sram-addr : address of the SRAM for TX path (non 0 means used)
+     - tx-sram-size : size of the SRAM for TX path (non 0 means used)
+
    Example Discovery Ethernet port node:
      ethernet@0 {
 	     device_type = "network";
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index d0afeea..efa5a2f 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -60,6 +60,11 @@
 #include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/clk.h>
+#include <linux/stringify.h>
+#include <linux/of.h>
+#include <linux/of_platform.h>
+#include <linux/of_mdio.h>
+#include <linux/of_net.h>
 
 static char mv643xx_eth_driver_name[] = "mv643xx_eth";
 static char mv643xx_eth_driver_version[] = "1.4";
@@ -2450,13 +2455,22 @@ static void infer_hw_params(struct mv643xx_eth_shared_private *msp)
 	}
 }
 
+static const struct of_device_id mv643xx_eth_match[] = {
+	{ .compatible = "marvell,mv64360-eth" },
+	{ .compatible = "marvell,mv643xx-eth" },
+	{ },
+};
+MODULE_DEVICE_TABLE(of, mv643xx_eth_match);
+
 static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 {
 	static int mv643xx_eth_version_printed;
+	struct device_node *np = pdev->dev.of_node;
 	struct mv643xx_eth_shared_platform_data *pd = pdev->dev.platform_data;
 	struct mv643xx_eth_shared_private *msp;
 	const struct mbus_dram_target_info *dram;
 	struct resource *res;
+	int tx_csum_limit = 0;
 
 	if (!mv643xx_eth_version_printed++)
 		pr_notice("MV-643xx 10/100/1000 ethernet driver version %s\n",
@@ -2485,13 +2499,21 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 	if (dram)
 		mv643xx_eth_conf_mbus_windows(msp, dram);
 
-	msp->tx_csum_limit = (pd != NULL && pd->tx_csum_limit) ?
-					pd->tx_csum_limit : 9 * 1024;
+	if (np)
+		of_property_read_u32(np, "tx-csum-limit", &tx_csum_limit);
+	else
+		tx_csum_limit = pd->tx_csum_limit;
+
+	msp->tx_csum_limit = tx_csum_limit ? tx_csum_limit : 9 * 1024;
 	infer_hw_params(msp);
 
 	platform_set_drvdata(pdev, msp);
 
+#ifdef CONFIG_OF
+	return of_platform_bus_probe(np, mv643xx_eth_match, &pdev->dev);
+#else
 	return 0;
+#endif
 }
 
 static int mv643xx_eth_shared_remove(struct platform_device *pdev)
@@ -2505,12 +2527,20 @@ static int mv643xx_eth_shared_remove(struct platform_device *pdev)
 	return 0;
 }
 
+static const struct of_device_id mv643xx_eth_shared_match[] = {
+	{ .compatible = "marvell,mv64360-eth-block" },
+	{ .compatible = "marvell,mv643xx-eth-block" },
+	{ },
+};
+MODULE_DEVICE_TABLE(of, mv643xx_eth_shared_match);
+
 static struct platform_driver mv643xx_eth_shared_driver = {
 	.probe		= mv643xx_eth_shared_probe,
 	.remove		= mv643xx_eth_shared_remove,
 	.driver = {
 		.name	= MV643XX_ETH_SHARED_NAME,
 		.owner	= THIS_MODULE,
+		.of_match_table = of_match_ptr(mv643xx_eth_shared_match),
 	},
 };
 
@@ -2669,6 +2699,68 @@ static const struct net_device_ops mv643xx_eth_netdev_ops = {
 #endif
 };
 
+#ifdef CONFIG_OF
+static int mv643xx_eth_of_probe(struct platform_device *pdev)
+{
+	struct mv643xx_eth_platform_data *pd;
+	struct device_node *np = pdev->dev.of_node;
+	struct device_node *shared = of_get_parent(np);
+	const int *prop;
+	const char *mac_addr;
+
+	if (pdev->dev.platform_data || !pdev->dev.of_node)
+		return 0;
+
+	pd = devm_kzalloc(&pdev->dev, sizeof(*pd), GFP_KERNEL);
+	if (!pd)
+		return -ENOMEM;
+
+	pdev->dev.platform_data = pd;
+
+	pd->shared = of_find_device_by_node(shared);
+	if (!pd->shared)
+		return -ENODEV;
+
+	if (of_property_read_u32(np, "reg", &pd->port_number))
+		return -EINVAL;
+
+	pd->phy_node = of_parse_phandle(np, "phy", 0);
+	if (!pd->phy_node) {
+		pd->phy_addr = MV643XX_ETH_PHY_NONE;
+
+		of_property_read_u32(np, "speed", &pd->speed);
+		of_property_read_u32(np, "duplex", &pd->duplex);
+	}
+
+	mac_addr = of_get_mac_address(np);
+	if (mac_addr)
+		memcpy(pd->mac_addr, mac_addr, ETH_ALEN);
+
+#define rx_tx_queue_sram_property(_name)				\
+	do {								\
+		prop = of_get_property(np, __stringify(_name), NULL);	\
+		if (prop)						\
+			pd->_name = be32_to_cpup(prop);			\
+	} while (0)
+
+	rx_tx_queue_sram_property(rx_queue_count);
+	rx_tx_queue_sram_property(tx_queue_count);
+	rx_tx_queue_sram_property(rx_queue_size);
+	rx_tx_queue_sram_property(tx_queue_size);
+	rx_tx_queue_sram_property(rx_sram_addr);
+	rx_tx_queue_sram_property(rx_sram_size);
+	rx_tx_queue_sram_property(tx_sram_addr);
+	rx_tx_queue_sram_property(rx_sram_size);
+
+	return 0;
+}
+#else
+static inline int mv643xx_eth_of_probe(struct platform_device *dev)
+{
+	return 0;
+}
+#endif
+
 static int mv643xx_eth_probe(struct platform_device *pdev)
 {
 	struct mv643xx_eth_platform_data *pd;
@@ -2677,6 +2769,10 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	struct resource *res;
 	int err;
 
+	err = mv643xx_eth_of_probe(pdev);
+	if (err)
+		return err;
+
 	pd = pdev->dev.platform_data;
 	if (pd == NULL) {
 		dev_err(&pdev->dev, "no mv643xx_eth_platform_data\n");
@@ -2717,7 +2813,12 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	netif_set_real_num_rx_queues(dev, mp->rxq_count);
 
 	if (pd->phy_addr != MV643XX_ETH_PHY_NONE) {
-		mp->phy = phy_scan(mp, pd->phy_addr);
+		if (pd->phy_node)
+			mp->phy = of_phy_connect(mp->dev, pd->phy_node,
+						mv643xx_eth_adjust_link, 0,
+						PHY_INTERFACE_MODE_GMII);
+		else
+			mp->phy = phy_scan(mp, pd->phy_addr);
 
 		if (IS_ERR(mp->phy)) {
 			err = PTR_ERR(mp->phy);
@@ -2837,6 +2938,7 @@ static struct platform_driver mv643xx_eth_driver = {
 	.driver = {
 		.name	= MV643XX_ETH_NAME,
 		.owner	= THIS_MODULE,
+		.of_match_table = of_match_ptr(mv643xx_eth_match),
 	},
 };
 
diff --git a/include/linux/mv643xx_eth.h b/include/linux/mv643xx_eth.h
index 141d395..c006d3d 100644
--- a/include/linux/mv643xx_eth.h
+++ b/include/linux/mv643xx_eth.h
@@ -30,6 +30,8 @@ struct mv643xx_eth_shared_platform_data {
 #define MV643XX_ETH_PHY_ADDR(x)		(0x80 | (x))
 #define MV643XX_ETH_PHY_NONE		0xff
 
+struct device_node;
+
 struct mv643xx_eth_platform_data {
 	/*
 	 * Pointer back to our parent instance, and our port number.
@@ -41,6 +43,7 @@ struct mv643xx_eth_platform_data {
 	 * Whether a PHY is present, and if yes, at which address.
 	 */
 	int			phy_addr;
+	struct device_node	*phy_node;
 
 	/*
 	 * Use this MAC address if it is valid, overriding the
-- 
1.7.2.5
