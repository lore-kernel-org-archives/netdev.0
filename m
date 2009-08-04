From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/5] cpmac: fix wrong MDIO bus identifier
Date: Tue, 4 Aug 2009 22:52:41 +0200
Message-ID: <200908042252.42254.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:50430 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753255AbZHDUwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 16:52:44 -0400
Received: by ewy10 with SMTP id 10so654827ewy.37
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2009 13:52:44 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the wrong MDIO bus identifier which was
set to 0 unconditionaly, suitable for external switches while
it is actually 1 for PHYs different than external switches
which are autodetected.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index fd5e32c..c951dd4 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -1109,7 +1109,7 @@ static int external_switch;
 static int __devinit cpmac_probe(struct platform_device *pdev)
 {
 	int rc, phy_id;
-	char *mdio_bus_id = "0";
+	char mdio_bus_id[BUS_ID_SIZE];
 	struct resource *mem;
 	struct cpmac_priv *priv;
 	struct net_device *dev;
@@ -1127,7 +1127,7 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 
 	if (phy_id == PHY_MAX_ADDR) {
 		if (external_switch || dumb_switch) {
-			mdio_bus_id = 0; /* fixed phys bus */
+			strncpy(mdio_bus_id, "0", BUS_ID_SIZE); /* fixed phys bus */
 			phy_id = pdev->id;
 		} else {
 			dev_err(&pdev->dev, "no PHY present\n");
@@ -1254,7 +1254,7 @@ int __devinit cpmac_init(void)
 	}
 
 	cpmac_mii->phy_mask = ~(mask | 0x80000000);
-	snprintf(cpmac_mii->id, MII_BUS_ID_SIZE, "0");
+	snprintf(cpmac_mii->id, MII_BUS_ID_SIZE, "1");
 
 	res = mdiobus_register(cpmac_mii);
 	if (res)
