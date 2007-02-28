From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Re: [PATCH 2/2] mv643xx_eth: Place explicit port number in mv643xx_eth_platform_data
Date: Wed, 28 Feb 2007 15:47:10 -0700
Message-ID: <20070228224710.GA9229@xyzzy.farnsworth.org>
References: <20070228224031.GA8233@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-mips@linux-mips.org, Ralf Baechle <ralf@linux-mips.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:3701 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932159AbXB1WrL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 17:47:11 -0500
Content-Disposition: inline
In-Reply-To: <20070228224031.GA8233@xyzzy.farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We had been using the platform_device.id field to identify which ethernet
port is used for mv643xx_eth device.  This is not correct in general.
It will be incorrect, for example, if a hardware platform uses a single
port but not the first port.  Here, we add an explicit port_number field
to struct mv643xx_eth_platform_data.

This makes the mv643xx_eth_platform_data structure required, but that
isn't an issue since all users currently provide it already.

Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

diff --git a/arch/mips/momentum/jaguar_atx/platform.c b/arch/mips/momentum/jaguar_atx/platform.c
Index: b/arch/mips/momentum/jaguar_atx/platform.c
===================================================================
--- a/arch/mips/momentum/jaguar_atx/platform.c
+++ b/arch/mips/momentum/jaguar_atx/platform.c
@@ -48,6 +48,8 @@ static struct resource mv64x60_eth0_reso
 };
 
 static struct mv643xx_eth_platform_data eth0_pd = {
+	.port_number	= 0,
+
 	.tx_sram_addr	= MV_SRAM_BASE_ETH0,
 	.tx_sram_size	= MV_SRAM_TXRING_SIZE,
 	.tx_queue_size	= MV_SRAM_TXRING_SIZE / 16,
@@ -77,6 +79,8 @@ static struct resource mv64x60_eth1_reso
 };
 
 static struct mv643xx_eth_platform_data eth1_pd = {
+	.port_number	= 1,
+
 	.tx_sram_addr	= MV_SRAM_BASE_ETH1,
 	.tx_sram_size	= MV_SRAM_TXRING_SIZE,
 	.tx_queue_size	= MV_SRAM_TXRING_SIZE / 16,
@@ -105,7 +109,9 @@ static struct resource mv64x60_eth2_reso
 	},
 };
 
-static struct mv643xx_eth_platform_data eth2_pd;
+static struct mv643xx_eth_platform_data eth2_pd = {
+	.port_number	= 2,
+};
 
 static struct platform_device eth2_device = {
 	.name		= MV643XX_ETH_NAME,
Index: b/arch/mips/momentum/ocelot_3/platform.c
===================================================================
--- a/arch/mips/momentum/ocelot_3/platform.c
+++ b/arch/mips/momentum/ocelot_3/platform.c
@@ -48,6 +48,8 @@ static struct resource mv64x60_eth0_reso
 };
 
 static struct mv643xx_eth_platform_data eth0_pd = {
+	.port_number	= 0,
+
 	.tx_sram_addr	= MV_SRAM_BASE_ETH0,
 	.tx_sram_size	= MV_SRAM_TXRING_SIZE,
 	.tx_queue_size	= MV_SRAM_TXRING_SIZE / 16,
@@ -77,6 +79,8 @@ static struct resource mv64x60_eth1_reso
 };
 
 static struct mv643xx_eth_platform_data eth1_pd = {
+	.port_number	= 1,
+
 	.tx_sram_addr	= MV_SRAM_BASE_ETH1,
 	.tx_sram_size	= MV_SRAM_TXRING_SIZE,
 	.tx_queue_size	= MV_SRAM_TXRING_SIZE / 16,
@@ -105,7 +109,9 @@ static struct resource mv64x60_eth2_reso
 	},
 };
 
-static struct mv643xx_eth_platform_data eth2_pd;
+static struct mv643xx_eth_platform_data eth2_pd = {
+	.port_number	= 2,
+};
 
 static struct platform_device eth2_device = {
 	.name		= MV643XX_ETH_NAME,
Index: b/arch/mips/momentum/ocelot_c/platform.c
===================================================================
--- a/arch/mips/momentum/ocelot_c/platform.c
+++ b/arch/mips/momentum/ocelot_c/platform.c
@@ -47,6 +47,8 @@ static struct resource mv64x60_eth0_reso
 };
 
 static struct mv643xx_eth_platform_data eth0_pd = {
+	.port_number	= 0,
+
 	.tx_sram_addr	= MV_SRAM_BASE_ETH0,
 	.tx_sram_size	= MV_SRAM_TXRING_SIZE,
 	.tx_queue_size	= MV_SRAM_TXRING_SIZE / 16,
@@ -76,6 +78,8 @@ static struct resource mv64x60_eth1_reso
 };
 
 static struct mv643xx_eth_platform_data eth1_pd = {
+	.port_number	= 1,
+
 	.tx_sram_addr	= MV_SRAM_BASE_ETH1,
 	.tx_sram_size	= MV_SRAM_TXRING_SIZE,
 	.tx_queue_size	= MV_SRAM_TXRING_SIZE / 16,
Index: b/arch/powerpc/platforms/chrp/pegasos_eth.c
===================================================================
--- a/arch/powerpc/platforms/chrp/pegasos_eth.c
+++ b/arch/powerpc/platforms/chrp/pegasos_eth.c
@@ -58,6 +58,7 @@ static struct resource mv643xx_eth0_reso
 
 
 static struct mv643xx_eth_platform_data eth0_pd = {
+	.port_number	= 0,
 	.tx_sram_addr = PEGASOS2_SRAM_BASE_ETH0,
 	.tx_sram_size = PEGASOS2_SRAM_TXRING_SIZE,
 	.tx_queue_size = PEGASOS2_SRAM_TXRING_SIZE/16,
@@ -87,6 +88,7 @@ static struct resource mv643xx_eth1_reso
 };
 
 static struct mv643xx_eth_platform_data eth1_pd = {
+	.port_number	= 1,
 	.tx_sram_addr = PEGASOS2_SRAM_BASE_ETH1,
 	.tx_sram_size = PEGASOS2_SRAM_TXRING_SIZE,
 	.tx_queue_size = PEGASOS2_SRAM_TXRING_SIZE/16,
Index: b/arch/ppc/syslib/mv64x60.c
===================================================================
--- a/arch/ppc/syslib/mv64x60.c
+++ b/arch/ppc/syslib/mv64x60.c
@@ -339,7 +339,9 @@ static struct resource mv64x60_eth0_reso
 	},
 };
 
-static struct mv643xx_eth_platform_data eth0_pd;
+static struct mv643xx_eth_platform_data eth0_pd = {
+	.port_number	= 0,
+};
 
 static struct platform_device eth0_device = {
 	.name		= MV643XX_ETH_NAME,
@@ -362,7 +364,9 @@ static struct resource mv64x60_eth1_reso
 	},
 };
 
-static struct mv643xx_eth_platform_data eth1_pd;
+static struct mv643xx_eth_platform_data eth1_pd = {
+	.port_number	= 1,
+};
 
 static struct platform_device eth1_device = {
 	.name		= MV643XX_ETH_NAME,
@@ -385,7 +389,9 @@ static struct resource mv64x60_eth2_reso
 	},
 };
 
-static struct mv643xx_eth_platform_data eth2_pd;
+static struct mv643xx_eth_platform_data eth2_pd = {
+	.port_number	= 2,
+};
 
 static struct platform_device eth2_device = {
 	.name		= MV643XX_ETH_NAME,
Index: b/drivers/net/mv643xx_eth.c
===================================================================
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1309,7 +1309,7 @@ static void mv643xx_init_ethtool_cmd(str
 static int mv643xx_eth_probe(struct platform_device *pdev)
 {
 	struct mv643xx_eth_platform_data *pd;
-	int port_num = pdev->id;
+	int port_num;
 	struct mv643xx_private *mp;
 	struct net_device *dev;
 	u8 *p;
@@ -1318,6 +1318,13 @@ static int mv643xx_eth_probe(struct plat
 	struct ethtool_cmd cmd;
 	int duplex = DUPLEX_HALF;
 	int speed = 0;			/* default to auto-negotiation */
+	static u8 zero_mac_addr[6] = { 0 };
+
+	pd = pdev->dev.platform_data;
+	if (pd == NULL) {
+		printk(KERN_ERR "No mv643xx_eth_platform_data\n");
+		return -ENODEV;
+	}
 
 	dev = alloc_etherdev(sizeof(struct mv643xx_private));
 	if (!dev)
@@ -1331,8 +1338,6 @@ static int mv643xx_eth_probe(struct plat
 	BUG_ON(!res);
 	dev->irq = res->start;
 
-	mp->port_num = port_num;
-
 	dev->open = mv643xx_eth_open;
 	dev->stop = mv643xx_eth_stop;
 	dev->hard_start_xmit = mv643xx_eth_start_xmit;
@@ -1373,40 +1378,39 @@ static int mv643xx_eth_probe(struct plat
 
 	spin_lock_init(&mp->lock);
 
+	port_num = pd->port_number;
+
 	/* set default config values */
 	eth_port_uc_addr_get(dev, dev->dev_addr);
 	mp->rx_ring_size = MV643XX_ETH_PORT_DEFAULT_RECEIVE_QUEUE_SIZE;
 	mp->tx_ring_size = MV643XX_ETH_PORT_DEFAULT_TRANSMIT_QUEUE_SIZE;
 
-	pd = pdev->dev.platform_data;
-	if (pd) {
-		static u8 zero_mac_addr[6] = { 0 };
+	if (memcmp(pd->mac_addr, zero_mac_addr, 6) != 0)
+		memcpy(dev->dev_addr, pd->mac_addr, 6);
 
-		if (memcmp(pd->mac_addr, zero_mac_addr, 6) != 0)
-			memcpy(dev->dev_addr, pd->mac_addr, 6);
+	if (pd->phy_addr || pd->force_phy_addr)
+		ethernet_phy_set(port_num, pd->phy_addr);
 
-		if (pd->phy_addr || pd->force_phy_addr)
-			ethernet_phy_set(port_num, pd->phy_addr);
+	if (pd->rx_queue_size)
+		mp->rx_ring_size = pd->rx_queue_size;
 
-		if (pd->rx_queue_size)
-			mp->rx_ring_size = pd->rx_queue_size;
+	if (pd->tx_queue_size)
+		mp->tx_ring_size = pd->tx_queue_size;
 
-		if (pd->tx_queue_size)
-			mp->tx_ring_size = pd->tx_queue_size;
+	if (pd->tx_sram_size) {
+		mp->tx_sram_size = pd->tx_sram_size;
+		mp->tx_sram_addr = pd->tx_sram_addr;
+	}
 
-		if (pd->tx_sram_size) {
-			mp->tx_sram_size = pd->tx_sram_size;
-			mp->tx_sram_addr = pd->tx_sram_addr;
-		}
+	if (pd->rx_sram_size) {
+		mp->rx_sram_size = pd->rx_sram_size;
+		mp->rx_sram_addr = pd->rx_sram_addr;
+	}
 
-		if (pd->rx_sram_size) {
-			mp->rx_sram_size = pd->rx_sram_size;
-			mp->rx_sram_addr = pd->rx_sram_addr;
-		}
+	duplex = pd->duplex;
+	speed = pd->speed;
 
-		duplex = pd->duplex;
-		speed = pd->speed;
-	}
+	mp->port_num = port_num;
 
 	/* Hook up MII support for ethtool */
 	mp->mii.dev = dev;
Index: b/include/linux/mv643xx.h
===================================================================
--- a/include/linux/mv643xx.h
+++ b/include/linux/mv643xx.h
@@ -1289,6 +1289,7 @@ struct mv64xxx_i2c_pdata {
 #define MV643XX_ETH_NAME	"mv643xx_eth"
 
 struct mv643xx_eth_platform_data {
+	int		port_number;
 	u16		force_phy_addr;	/* force override if phy_addr == 0 */
 	u16		phy_addr;
 
