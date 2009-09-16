From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH] cpmac: fix compilation errors against undeclared BUS_ID_SIZE
Date: Wed, 16 Sep 2009 09:44:22 +0200
Message-ID: <200909160944.24265.florian@openwrt.org>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>,
	linux-mips@linux-mips.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:32191 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251AbZIPHoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 03:44:24 -0400
Received: by ey-out-2122.google.com with SMTP id 25so931798eya.19
        for <netdev@vger.kernel.org>; Wed, 16 Sep 2009 00:44:26 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This is relevant for 2.6.32-rc0, thanks !
--
From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH] cpmac: fix compilation errors against undeclared BUS_ID_SIZE

With the removal of BUS_ID_SIZE, cpmac was not fully
converted to use MII_BUS_ID_SIZE as it ought to. This
patch fixes the following cpmac build failure:
 CC      drivers/net/cpmac.o
drivers/net/cpmac.c: In function 'cpmac_start_xmit':
drivers/net/cpmac.c:563: warning: comparison of distinct pointer types lacks a cast
drivers/net/cpmac.c: In function 'cpmac_probe':
drivers/net/cpmac.c:1112: error: 'BUS_ID_SIZE' undeclared (first use in this function)
drivers/net/cpmac.c:1112: error: (Each undeclared identifier is reported only once
drivers/net/cpmac.c:1112: error: for each function it appears in.)

Reported-by: Ralf Baechle <ralf@linux-mips.org>
Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 3e3fab8..61f9da2 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -1109,7 +1109,7 @@ static int external_switch;
 static int __devinit cpmac_probe(struct platform_device *pdev)
 {
 	int rc, phy_id;
-	char mdio_bus_id[BUS_ID_SIZE];
+	char mdio_bus_id[MII_BUS_ID_SIZE];
 	struct resource *mem;
 	struct cpmac_priv *priv;
 	struct net_device *dev;
@@ -1118,7 +1118,7 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 	pdata = pdev->dev.platform_data;
 
 	if (external_switch || dumb_switch) {
-		strncpy(mdio_bus_id, "0", BUS_ID_SIZE); /* fixed phys bus */
+		strncpy(mdio_bus_id, "0", MII_BUS_ID_SIZE); /* fixed phys bus */
 		phy_id = pdev->id;
 	} else {
 		for (phy_id = 0; phy_id < PHY_MAX_ADDR; phy_id++) {
@@ -1126,7 +1126,7 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 				continue;
 			if (!cpmac_mii->phy_map[phy_id])
 				continue;
-			strncpy(mdio_bus_id, cpmac_mii->id, BUS_ID_SIZE);
+			strncpy(mdio_bus_id, cpmac_mii->id, MII_BUS_ID_SIZE);
 			break;
 		}
 	}
@@ -1167,7 +1167,7 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 	priv->msg_enable = netif_msg_init(debug_level, 0xff);
 	memcpy(dev->dev_addr, pdata->dev_addr, sizeof(dev->dev_addr));
 
-	snprintf(priv->phy_name, BUS_ID_SIZE, PHY_ID_FMT, mdio_bus_id, phy_id);
+	snprintf(priv->phy_name, MII_BUS_ID_SIZE, PHY_ID_FMT, mdio_bus_id, phy_id);
 
 	priv->phy = phy_connect(dev, priv->phy_name, &cpmac_adjust_link, 0,
 						PHY_INTERFACE_MODE_MII);


