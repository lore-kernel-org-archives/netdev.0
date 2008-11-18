From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 1/6] mv643xx_eth: checkpatch fixes
Date: Tue, 18 Nov 2008 23:28:42 +0100
Message-ID: <20081118222842.GS5006@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:53424 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753053AbYKRW2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 17:28:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix up a couple of coding style issues caught by checkpatch.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   38 ++++++++++++++++++++++----------------
 1 files changed, 22 insertions(+), 16 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index b13fbc4..1d54ba3 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -51,8 +51,8 @@
 #include <linux/workqueue.h>
 #include <linux/phy.h>
 #include <linux/mv643xx_eth.h>
-#include <asm/io.h>
-#include <asm/types.h>
+#include <linux/io.h>
+#include <linux/types.h>
 #include <asm/system.h>
 
 static char mv643xx_eth_driver_name[] = "mv643xx_eth";
@@ -138,14 +138,14 @@ static char mv643xx_eth_driver_version[] = "1.4";
 
 #if defined(__BIG_ENDIAN)
 #define PORT_SDMA_CONFIG_DEFAULT_VALUE		\
-		RX_BURST_SIZE_16_64BIT	|	\
-		TX_BURST_SIZE_16_64BIT
+		(RX_BURST_SIZE_16_64BIT	|	\
+		TX_BURST_SIZE_16_64BIT)
 #elif defined(__LITTLE_ENDIAN)
 #define PORT_SDMA_CONFIG_DEFAULT_VALUE		\
-		RX_BURST_SIZE_16_64BIT	|	\
+		(RX_BURST_SIZE_16_64BIT	|	\
 		BLM_RX_NO_SWAP		|	\
 		BLM_TX_NO_SWAP		|	\
-		TX_BURST_SIZE_16_64BIT
+		TX_BURST_SIZE_16_64BIT)
 #else
 #error One of __BIG_ENDIAN or __LITTLE_ENDIAN must be defined
 #endif
@@ -1081,20 +1081,20 @@ static int smi_bus_read(struct mii_bus *bus, int addr, int reg)
 	int ret;
 
 	if (smi_wait_ready(msp)) {
-		printk("mv643xx_eth: SMI bus busy timeout\n");
+		printk(KERN_WARNING "mv643xx_eth: SMI bus busy timeout\n");
 		return -ETIMEDOUT;
 	}
 
 	writel(SMI_OPCODE_READ | (reg << 21) | (addr << 16), smi_reg);
 
 	if (smi_wait_ready(msp)) {
-		printk("mv643xx_eth: SMI bus busy timeout\n");
+		printk(KERN_WARNING "mv643xx_eth: SMI bus busy timeout\n");
 		return -ETIMEDOUT;
 	}
 
 	ret = readl(smi_reg);
 	if (!(ret & SMI_READ_VALID)) {
-		printk("mv643xx_eth: SMI bus read not valid\n");
+		printk(KERN_WARNING "mv643xx_eth: SMI bus read not valid\n");
 		return -ENODEV;
 	}
 
@@ -1107,7 +1107,7 @@ static int smi_bus_write(struct mii_bus *bus, int addr, int reg, u16 val)
 	void __iomem *smi_reg = msp->base + SMI_REG;
 
 	if (smi_wait_ready(msp)) {
-		printk("mv643xx_eth: SMI bus busy timeout\n");
+		printk(KERN_WARNING "mv643xx_eth: SMI bus busy timeout\n");
 		return -ETIMEDOUT;
 	}
 
@@ -1115,7 +1115,7 @@ static int smi_bus_write(struct mii_bus *bus, int addr, int reg, u16 val)
 		(addr << 16) | (val & 0xffff), smi_reg);
 
 	if (smi_wait_ready(msp)) {
-		printk("mv643xx_eth: SMI bus busy timeout\n");
+		printk(KERN_WARNING "mv643xx_eth: SMI bus busy timeout\n");
 		return -ETIMEDOUT;
 	}
 
@@ -1268,7 +1268,8 @@ static const struct mv643xx_eth_stats mv643xx_eth_stats[] = {
 	MIBSTAT(late_collision),
 };
 
-static int mv643xx_eth_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int
+mv643xx_eth_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	int err;
@@ -1286,7 +1287,9 @@ static int mv643xx_eth_get_settings(struct net_device *dev, struct ethtool_cmd *
 	return err;
 }
 
-static int mv643xx_eth_get_settings_phyless(struct net_device *dev, struct ethtool_cmd *cmd)
+static int
+mv643xx_eth_get_settings_phyless(struct net_device *dev,
+				 struct ethtool_cmd *cmd)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	u32 port_status;
@@ -1320,7 +1323,8 @@ static int mv643xx_eth_get_settings_phyless(struct net_device *dev, struct ethto
 	return 0;
 }
 
-static int mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int
+mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 
@@ -1332,7 +1336,9 @@ static int mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *
 	return phy_ethtool_sset(mp->phy, cmd);
 }
 
-static int mv643xx_eth_set_settings_phyless(struct net_device *dev, struct ethtool_cmd *cmd)
+static int
+mv643xx_eth_set_settings_phyless(struct net_device *dev,
+				 struct ethtool_cmd *cmd)
 {
 	return -EINVAL;
 }
@@ -2336,7 +2342,7 @@ static void infer_hw_params(struct mv643xx_eth_shared_private *msp)
 
 static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 {
-	static int mv643xx_eth_version_printed = 0;
+	static int mv643xx_eth_version_printed;
 	struct mv643xx_eth_shared_platform_data *pd = pdev->dev.platform_data;
 	struct mv643xx_eth_shared_private *msp;
 	struct resource *res;
-- 
1.5.6.4
