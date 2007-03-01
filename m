From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: [PATCH 2/2] mv643xx_eth: Place explicit port number in mv643xx_eth_platform_data
Date: Thu, 1 Mar 2007 16:33:24 -0700
Message-ID: <20070301233324.GA20193@xyzzy.farnsworth.org>
References: <20070301233148.GA19550@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-mips@linux-mips.org, Ralf Baechle <ralf@linux-mips.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161213AbXCAXd1@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070301233148.GA19550@xyzzy.farnsworth.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We were using the platform_device.id field to identify which ethernet
port is used for mv643xx_eth device.  This is not generally correct.
It will be incorrect, for example, if a hardware platform uses a single
port but not the first port.  Here, we add an explicit port_number field
to struct mv643xx_eth_platform_data.

This makes the mv643xx_eth_platform_data structure required, but that
isn't an issue since all users currently provide it already.

Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

---

 arch/mips/momentum/jaguar_atx/platform.c  |    8 ++
 arch/mips/momentum/ocelot_3/platform.c    |    8 ++
 arch/mips/momentum/ocelot_c/platform.c    |    4 +
 arch/powerpc/platforms/chrp/pegasos_eth.c |    2 
 arch/ppc/syslib/mv64x60.c                 |   12 +++-
 drivers/net/mv643xx_eth.c                 |   59 ++++++++++----------
 include/linux/mv643xx.h                   |    1 
 7 files changed, 62 insertions(+), 32 deletions(-)

diff --git a/arch/mips/momentum/jaguar_atx/platform.c b/arch/mips/momentum/jaguar_atx/platform.c
index 035ea51..003d3ee 100644
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
@@ -1319,6 +1319,12 @@ static int mv643xx_eth_probe(struct plat
 	int duplex = DUPLEX_HALF;
 	int speed = 0;			/* default to auto-negotiation */
 
+	pd = pdev->dev.platform_data;
+	if (pd == NULL) {
+		printk(KERN_ERR "No mv643xx_eth_platform_data\n");
+		return -ENODEV;
+	}
+
 	dev = alloc_etherdev(sizeof(struct mv643xx_private));
 	if (!dev)
 		return -ENOMEM;
@@ -1331,8 +1337,6 @@ static int mv643xx_eth_probe(struct plat
 	BUG_ON(!res);
 	dev->irq = res->start;
 
-	mp->port_num = port_num;
-
 	dev->open = mv643xx_eth_open;
 	dev->stop = mv643xx_eth_stop;
 	dev->hard_start_xmit = mv643xx_eth_start_xmit;
@@ -1373,39 +1377,40 @@ static int mv643xx_eth_probe(struct plat
 
 	spin_lock_init(&mp->lock);
 
+	port_num = pd->port_number;
+
 	/* set default config values */
 	eth_port_uc_addr_get(dev, dev->dev_addr);
 	mp->rx_ring_size = MV643XX_ETH_PORT_DEFAULT_RECEIVE_QUEUE_SIZE;
 	mp->tx_ring_size = MV643XX_ETH_PORT_DEFAULT_TRANSMIT_QUEUE_SIZE;
 
-	pd = pdev->dev.platform_data;
-	if (pd) {
-		if (is_valid_ether_addr(pd->mac_addr))
-			memcpy(dev->dev_addr, pd->mac_addr, 6);
-
-		if (pd->phy_addr || pd->force_phy_addr)
-			ethernet_phy_set(port_num, pd->phy_addr);
-
-		if (pd->rx_queue_size)
-			mp->rx_ring_size = pd->rx_queue_size;
-
-		if (pd->tx_queue_size)
-			mp->tx_ring_size = pd->tx_queue_size;
-
-		if (pd->tx_sram_size) {
-			mp->tx_sram_size = pd->tx_sram_size;
-			mp->tx_sram_addr = pd->tx_sram_addr;
-		}
+	if (is_valid_ether_addr(pd->mac_addr))
+		memcpy(dev->dev_addr, pd->mac_addr, 6);
 
-		if (pd->rx_sram_size) {
-			mp->rx_sram_size = pd->rx_sram_size;
-			mp->rx_sram_addr = pd->rx_sram_addr;
-		}
+	if (pd->phy_addr || pd->force_phy_addr)
+		ethernet_phy_set(port_num, pd->phy_addr);
+
+	if (pd->rx_queue_size)
+		mp->rx_ring_size = pd->rx_queue_size;
+
+	if (pd->tx_queue_size)
+		mp->tx_ring_size = pd->tx_queue_size;
+
+	if (pd->tx_sram_size) {
+		mp->tx_sram_size = pd->tx_sram_size;
+		mp->tx_sram_addr = pd->tx_sram_addr;
+	}
 
-		duplex = pd->duplex;
-		speed = pd->speed;
+	if (pd->rx_sram_size) {
+		mp->rx_sram_size = pd->rx_sram_size;
+		mp->rx_sram_addr = pd->rx_sram_addr;
 	}
 
+	duplex = pd->duplex;
+	speed = pd->speed;
+
+	mp->port_num = port_num;
+
 	/* Hook up MII support for ethtool */
 	mp->mii.dev = dev;
 	mp->mii.mdio_read = mv643xx_mdio_read;
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
 
