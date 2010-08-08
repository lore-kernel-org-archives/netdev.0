From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH] cpmac: fix all checkpatch errors and warnings
Date: Sun, 8 Aug 2010 22:09:39 +0200
Message-ID: <201008082209.40403.florian@openwrt.org>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53740 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751709Ab0HHUIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Aug 2010 16:08:52 -0400
Received: by wyb39 with SMTP id 39so9299108wyb.19
        for <netdev@vger.kernel.org>; Sun, 08 Aug 2010 13:08:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patches fixes a couple of checkpatch warnings and errors:
- lines over 80 columns
- printk() instead of pr_cont()
- assignments in tests (if ((foo == bar())))

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index e1f6156..fe017eb 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -38,7 +38,7 @@
 #include <linux/platform_device.h>
 #include <linux/dma-mapping.h>
 #include <linux/clk.h>
-#include <asm/gpio.h>
+#include <linux/gpio.h>
 #include <asm/atomic.h>
 
 MODULE_AUTHOR("Eugene Konev <ejka@imfi.kspu.ru>");
@@ -108,7 +108,7 @@ MODULE_PARM_DESC(dumb_switch, "Assume switch is not connected to MDIO bus");
 #define CPMAC_RX_INT_CLEAR		0x019c
 #define CPMAC_MAC_INT_ENABLE		0x01a8
 #define CPMAC_MAC_INT_CLEAR		0x01ac
-#define CPMAC_MAC_ADDR_LO(channel) 	(0x01b0 + (channel) * 4)
+#define CPMAC_MAC_ADDR_LO(channel)	(0x01b0 + (channel) * 4)
 #define CPMAC_MAC_ADDR_MID		0x01d0
 #define CPMAC_MAC_ADDR_HI		0x01d4
 #define CPMAC_MAC_HASH_LO		0x01d8
@@ -227,7 +227,7 @@ static void cpmac_dump_regs(struct net_device *dev)
 	for (i = 0; i < CPMAC_REG_END; i += 4) {
 		if (i % 16 == 0) {
 			if (i)
-				printk("\n");
+				pr_cont("\n");
 			printk(KERN_DEBUG "%s: reg[%p]:", dev->name,
 			       priv->regs + i);
 		}
@@ -262,7 +262,7 @@ static void cpmac_dump_skb(struct net_device *dev, struct sk_buff *skb)
 	for (i = 0; i < skb->len; i++) {
 		if (i % 16 == 0) {
 			if (i)
-				printk("\n");
+				pr_cont("\n");
 			printk(KERN_DEBUG "%s: data[%p]:", dev->name,
 			       skb->data + i);
 		}
@@ -873,7 +873,8 @@ static int cpmac_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	return -EINVAL;
 }
 
-static void cpmac_get_ringparam(struct net_device *dev, struct ethtool_ringparam* ring)
+static void cpmac_get_ringparam(struct net_device *dev,
+						struct ethtool_ringparam *ring)
 {
 	struct cpmac_priv *priv = netdev_priv(dev);
 
@@ -888,7 +889,8 @@ static void cpmac_get_ringparam(struct net_device *dev, struct ethtool_ringparam
 	ring->tx_pending = 1;
 }
 
-static int cpmac_set_ringparam(struct net_device *dev, struct ethtool_ringparam* ring)
+static int cpmac_set_ringparam(struct net_device *dev,
+						struct ethtool_ringparam *ring)
 {
 	struct cpmac_priv *priv = netdev_priv(dev);
 
@@ -1012,8 +1014,8 @@ static int cpmac_open(struct net_device *dev)
 
 	priv->rx_head->prev->hw_next = (u32)0;
 
-	if ((res = request_irq(dev->irq, cpmac_irq, IRQF_SHARED,
-			       dev->name, dev))) {
+	res = request_irq(dev->irq, cpmac_irq, IRQF_SHARED, dev->name, dev);
+	if (res) {
 		if (netif_msg_drv(priv))
 			printk(KERN_ERR "%s: failed to obtain irq\n",
 			       dev->name);
@@ -1133,7 +1135,8 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 	}
 
 	if (phy_id == PHY_MAX_ADDR) {
-		dev_err(&pdev->dev, "no PHY present, falling back to switch on MDIO bus 0\n");
+		dev_err(&pdev->dev, "no PHY present, falling back "
+					"to switch on MDIO bus 0\n");
 		strncpy(mdio_bus_id, "0", MII_BUS_ID_SIZE); /* fixed phys bus */
 		phy_id = pdev->id;
 	}
@@ -1169,7 +1172,8 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 	priv->msg_enable = netif_msg_init(debug_level, 0xff);
 	memcpy(dev->dev_addr, pdata->dev_addr, sizeof(pdata->dev_addr));
 
-	snprintf(priv->phy_name, MII_BUS_ID_SIZE, PHY_ID_FMT, mdio_bus_id, phy_id);
+	snprintf(priv->phy_name, MII_BUS_ID_SIZE, PHY_ID_FMT,
+						mdio_bus_id, phy_id);
 
 	priv->phy = phy_connect(dev, priv->phy_name, &cpmac_adjust_link, 0,
 						PHY_INTERFACE_MODE_MII);
@@ -1182,7 +1186,8 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 		goto fail;
 	}
 
-	if ((rc = register_netdev(dev))) {
+	rc = register_netdev(dev);
+	if (rc) {
 		printk(KERN_ERR "cpmac: error %i registering device %s\n", rc,
 		       dev->name);
 		goto fail;
@@ -1248,11 +1253,13 @@ int __devinit cpmac_init(void)
 
 	cpmac_mii->reset(cpmac_mii);
 
-	for (i = 0; i < 300; i++)
-		if ((mask = cpmac_read(cpmac_mii->priv, CPMAC_MDIO_ALIVE)))
+	for (i = 0; i < 300; i++) {
+		mask = cpmac_read(cpmac_mii->priv, CPMAC_MDIO_ALIVE);
+		if (mask)
 			break;
 		else
 			msleep(10);
+	}
 
 	mask &= 0x7fffffff;
 	if (mask & (mask - 1)) {
