From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] gianfar: Fix sparse warnings
Date: Wed, 28 Jan 2009 23:52:20 +0300
Message-ID: <20090128205220.GA25701@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: David Miller <davem@davemloft.net>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:29458 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1761347AbZA1UwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 15:52:24 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes following sparse warnings:

  CHECK   gianfar_ethtool.c
gianfar_ethtool.c:610:26: warning: symbol 'gfar_ethtool_ops' was not declared. Should it be static?
  CHECK   gianfar_mii.c
gianfar_mii.c:108:35: warning: cast adds address space to expression (<asn:2>)
gianfar_mii.c:119:35: warning: cast adds address space to expression (<asn:2>)
gianfar_mii.c:128:35: warning: cast adds address space to expression (<asn:2>)
gianfar_mii.c:272:5: warning: cast removes address space of expression
gianfar_mii.c:271:15: warning: cast adds address space to expression (<asn:2>)
gianfar_mii.c:340:11: warning: cast adds address space to expression (<asn:2>)
  CHECK   gianfar_sysfs.c
gianfar_sysfs.c:84:1: warning: symbol 'dev_attr_bd_stash' was not declared. Should it be static?
gianfar_sysfs.c:133:1: warning: symbol 'dev_attr_rx_stash_size' was not declared. Should it be static?
gianfar_sysfs.c:175:1: warning: symbol 'dev_attr_rx_stash_index' was not declared. Should it be static?
gianfar_sysfs.c:213:1: warning: symbol 'dev_attr_fifo_threshold' was not declared. Should it be static?
gianfar_sysfs.c:250:1: warning: symbol 'dev_attr_fifo_starve' was not declared. Should it be static?
gianfar_sysfs.c:287:1: warning: symbol 'dev_attr_fifo_starve_off' was not declared. Should it be static?

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/gianfar.c       |    2 --
 drivers/net/gianfar.h       |    2 ++
 drivers/net/gianfar_mii.c   |   12 ++++++------
 drivers/net/gianfar_sysfs.c |   21 +++++++++++----------
 4 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 3a8359e..4fc07b6 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -141,8 +141,6 @@ void gfar_start(struct net_device *dev);
 static void gfar_clear_exact_match(struct net_device *dev);
 static void gfar_set_mac_for_addr(struct net_device *dev, int num, u8 *addr);
 
-extern const struct ethtool_ops gfar_ethtool_ops;
-
 MODULE_AUTHOR("Freescale Semiconductor, Inc");
 MODULE_DESCRIPTION("Gianfar Ethernet Driver");
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index b1a8334..7820720 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -830,4 +830,6 @@ int gfar_local_mdio_write(struct gfar_mii __iomem *regs, int mii_id,
 			  int regnum, u16 value);
 int gfar_local_mdio_read(struct gfar_mii __iomem *regs, int mii_id, int regnum);
 
+extern const struct ethtool_ops gfar_ethtool_ops;
+
 #endif /* __GIANFAR_H */
diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
index f49a426..64e4679 100644
--- a/drivers/net/gianfar_mii.c
+++ b/drivers/net/gianfar_mii.c
@@ -105,7 +105,7 @@ int gfar_local_mdio_read(struct gfar_mii __iomem *regs, int mii_id, int regnum)
  * All PHY configuration is done through the TSEC1 MIIM regs */
 int gfar_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value)
 {
-	struct gfar_mii __iomem *regs = (void __iomem *)bus->priv;
+	struct gfar_mii __iomem *regs = (void __force __iomem *)bus->priv;
 
 	/* Write to the local MII regs */
 	return(gfar_local_mdio_write(regs, mii_id, regnum, value));
@@ -116,7 +116,7 @@ int gfar_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value)
  * configuration has to be done through the TSEC1 MIIM regs */
 int gfar_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 {
-	struct gfar_mii __iomem *regs = (void __iomem *)bus->priv;
+	struct gfar_mii __iomem *regs = (void __force __iomem *)bus->priv;
 
 	/* Read the local MII regs */
 	return(gfar_local_mdio_read(regs, mii_id, regnum));
@@ -125,7 +125,7 @@ int gfar_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 /* Reset the MIIM registers, and wait for the bus to free */
 static int gfar_mdio_reset(struct mii_bus *bus)
 {
-	struct gfar_mii __iomem *regs = (void __iomem *)bus->priv;
+	struct gfar_mii __iomem *regs = (void __force __iomem *)bus->priv;
 	unsigned int timeout = PHY_INIT_TIMEOUT;
 
 	mutex_lock(&bus->mdio_lock);
@@ -268,8 +268,8 @@ static int gfar_mdio_probe(struct of_device *ofdev,
 	 * Also, we have to cast back to struct gfar_mii because of
 	 * definition weirdness done in gianfar.h.
 	 */
-	enet_regs = (struct gfar __iomem *)
-		((char *)regs - offsetof(struct gfar, gfar_mii_regs));
+	enet_regs = (struct gfar __force __iomem *)
+		((char __force *)regs - offsetof(struct gfar, gfar_mii_regs));
 
 	for_each_child_of_node(np, tbi) {
 		if (!strncmp(tbi->type, "tbi-phy", 8))
@@ -337,7 +337,7 @@ static int gfar_mdio_remove(struct of_device *ofdev)
 
 	dev_set_drvdata(&ofdev->dev, NULL);
 
-	iounmap((void __iomem *)bus->priv);
+	iounmap((void __force __iomem *)bus->priv);
 	bus->priv = NULL;
 	kfree(bus->irq);
 	mdiobus_free(bus);
diff --git a/drivers/net/gianfar_sysfs.c b/drivers/net/gianfar_sysfs.c
index 782c201..74e0b4d 100644
--- a/drivers/net/gianfar_sysfs.c
+++ b/drivers/net/gianfar_sysfs.c
@@ -81,7 +81,7 @@ static ssize_t gfar_set_bd_stash(struct device *dev,
 	return count;
 }
 
-DEVICE_ATTR(bd_stash, 0644, gfar_show_bd_stash, gfar_set_bd_stash);
+static DEVICE_ATTR(bd_stash, 0644, gfar_show_bd_stash, gfar_set_bd_stash);
 
 static ssize_t gfar_show_rx_stash_size(struct device *dev,
 				       struct device_attribute *attr, char *buf)
@@ -130,8 +130,8 @@ out:
 	return count;
 }
 
-DEVICE_ATTR(rx_stash_size, 0644, gfar_show_rx_stash_size,
-	    gfar_set_rx_stash_size);
+static DEVICE_ATTR(rx_stash_size, 0644, gfar_show_rx_stash_size,
+		   gfar_set_rx_stash_size);
 
 /* Stashing will only be enabled when rx_stash_size != 0 */
 static ssize_t gfar_show_rx_stash_index(struct device *dev,
@@ -172,8 +172,8 @@ out:
 	return count;
 }
 
-DEVICE_ATTR(rx_stash_index, 0644, gfar_show_rx_stash_index,
-	    gfar_set_rx_stash_index);
+static DEVICE_ATTR(rx_stash_index, 0644, gfar_show_rx_stash_index,
+		   gfar_set_rx_stash_index);
 
 static ssize_t gfar_show_fifo_threshold(struct device *dev,
 					struct device_attribute *attr,
@@ -210,8 +210,8 @@ static ssize_t gfar_set_fifo_threshold(struct device *dev,
 	return count;
 }
 
-DEVICE_ATTR(fifo_threshold, 0644, gfar_show_fifo_threshold,
-	    gfar_set_fifo_threshold);
+static DEVICE_ATTR(fifo_threshold, 0644, gfar_show_fifo_threshold,
+		   gfar_set_fifo_threshold);
 
 static ssize_t gfar_show_fifo_starve(struct device *dev,
 				     struct device_attribute *attr, char *buf)
@@ -247,7 +247,8 @@ static ssize_t gfar_set_fifo_starve(struct device *dev,
 	return count;
 }
 
-DEVICE_ATTR(fifo_starve, 0644, gfar_show_fifo_starve, gfar_set_fifo_starve);
+static DEVICE_ATTR(fifo_starve, 0644, gfar_show_fifo_starve,
+		   gfar_set_fifo_starve);
 
 static ssize_t gfar_show_fifo_starve_off(struct device *dev,
 					 struct device_attribute *attr,
@@ -284,8 +285,8 @@ static ssize_t gfar_set_fifo_starve_off(struct device *dev,
 	return count;
 }
 
-DEVICE_ATTR(fifo_starve_off, 0644, gfar_show_fifo_starve_off,
-	    gfar_set_fifo_starve_off);
+static DEVICE_ATTR(fifo_starve_off, 0644, gfar_show_fifo_starve_off,
+		   gfar_set_fifo_starve_off);
 
 void gfar_init_sysfs(struct net_device *dev)
 {
-- 
1.5.6.5
