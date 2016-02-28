From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] of_mdio: kill useless variable in of_mdiobus_register()
Date: Sun, 28 Feb 2016 21:56:34 +0300
Message-ID: <76681790.JernGlLJsj@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: grant.likely@linaro.org, robh+dt@kernel.org,
	devicetree@vger.kernel.org, f.fainelli@gmail.com,
	netdev@vger.kernel.org, frowand.list@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:33815 "EHLO
	mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754400AbcB1S4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2016 13:56:39 -0500
Received: by mail-lf0-f52.google.com with SMTP id j78so79181219lfb.1
        for <netdev@vger.kernel.org>; Sun, 28 Feb 2016 10:56:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_mdiobus_register()  declares the 'paddr' variable to hold the result of
the of_get_property()  but only uses it once after that while the function
can be called directly from the *if* statement. Remove that variable and
switch to calling of_find_property() instead since  we don't care about
the "reg" property's value anyway...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against DaveM's 'net-next.git' repo.

drivers/of/of_mdio.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

Index: net-next/drivers/of/of_mdio.c
===================================================================
--- net-next.orig/drivers/of/of_mdio.c
+++ net-next/drivers/of/of_mdio.c
@@ -211,7 +211,6 @@ static bool of_mdiobus_child_is_phy(stru
 int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 {
 	struct device_node *child;
-	const __be32 *paddr;
 	bool scanphys = false;
 	int addr, rc;
 
@@ -246,8 +245,7 @@ int of_mdiobus_register(struct mii_bus *
 	/* auto scan for PHYs with empty reg property */
 	for_each_available_child_of_node(np, child) {
 		/* Skip PHYs with reg property set */
-		paddr = of_get_property(child, "reg", NULL);
-		if (paddr)
+		if (of_find_property(child, "reg", NULL))
 			continue;
 
 		for (addr = 0; addr < PHY_MAX_ADDR; addr++) {
