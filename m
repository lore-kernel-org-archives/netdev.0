From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] of_mdio: make of_mdiobus_register_{device|phy}() *void*
Date: Sun, 17 Apr 2016 01:05:19 +0300
Message-ID: <1834436.v0N3sgcLOX@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: grant.likely@linaro.org, robh+dt@kernel.org,
	devicetree@vger.kernel.org, f.fainelli@gmail.com,
	netdev@vger.kernel.org, frowand.list@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:35946 "EHLO
	mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751782AbcDPWF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 18:05:28 -0400
Received: by mail-lf0-f41.google.com with SMTP id g184so180469796lfb.3
        for <netdev@vger.kernel.org>; Sat, 16 Apr 2016 15:05:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The results of of_mdiobus_register_{device|phy}() are never checked, so we
can make  both these functions *void*...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against DaveM's 'net-next.git' repo.

 drivers/of/of_mdio.c |   21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

Index: net-next/drivers/of/of_mdio.c
===================================================================
--- net-next.orig/drivers/of/of_mdio.c
+++ net-next/drivers/of/of_mdio.c
@@ -41,8 +41,8 @@ static int of_get_phy_id(struct device_n
 	return -EINVAL;
 }
 
-static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *child,
-				   u32 addr)
+static void of_mdiobus_register_phy(struct mii_bus *mdio,
+				    struct device_node *child, u32 addr)
 {
 	struct phy_device *phy;
 	bool is_c45;
@@ -57,7 +57,7 @@ static int of_mdiobus_register_phy(struc
 	else
 		phy = get_phy_device(mdio, addr, is_c45);
 	if (IS_ERR_OR_NULL(phy))
-		return 1;
+		return;
 
 	rc = irq_of_parse_and_map(child, 0);
 	if (rc > 0) {
@@ -81,25 +81,22 @@ static int of_mdiobus_register_phy(struc
 	if (rc) {
 		phy_device_free(phy);
 		of_node_put(child);
-		return 1;
+		return;
 	}
 
 	dev_dbg(&mdio->dev, "registered phy %s at address %i\n",
 		child->name, addr);
-
-	return 0;
 }
 
-static int of_mdiobus_register_device(struct mii_bus *mdio,
-				      struct device_node *child,
-				      u32 addr)
+static void of_mdiobus_register_device(struct mii_bus *mdio,
+				       struct device_node *child, u32 addr)
 {
 	struct mdio_device *mdiodev;
 	int rc;
 
 	mdiodev = mdio_device_create(mdio, addr);
 	if (IS_ERR(mdiodev))
-		return 1;
+		return;
 
 	/* Associate the OF node with the device structure so it
 	 * can be looked up later.
@@ -112,13 +109,11 @@ static int of_mdiobus_register_device(st
 	if (rc) {
 		mdio_device_free(mdiodev);
 		of_node_put(child);
-		return 1;
+		return;
 	}
 
 	dev_dbg(&mdio->dev, "registered mdio device %s at address %i\n",
 		child->name, addr);
-
-	return 0;
 }
 
 int of_mdio_parse_addr(struct device *dev, const struct device_node *np)
