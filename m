From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH 3/3] net: of_mdio: don't store the length of a property if we don't need to
Date: Sat, 10 May 2014 18:37:55 +0200
Message-ID: <1399739875-16434-4-git-send-email-zonque@gmail.com>
References: <1399739875-16434-1-git-send-email-zonque@gmail.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, mugunthanvnm@ti.com,
	ujhelyi.m@gmail.com, Daniel Mack <zonque@gmail.com>
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:33225 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820AbaEJQiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 May 2014 12:38:07 -0400
Received: by mail-ee0-f41.google.com with SMTP id t10so3461992eei.0
        for <netdev@vger.kernel.org>; Sat, 10 May 2014 09:38:06 -0700 (PDT)
In-Reply-To: <1399739875-16434-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_get_property() can be called with NULL as 2nd argument if the caller
is not interested in the length of a property. Use that here so we can
get rid of a variable.

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 drivers/of/of_mdio.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 931a977..f567210 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -151,7 +151,7 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 	const __be32 *paddr;
 	u32 addr;
 	bool scanphys = false;
-	int rc, i, len;
+	int rc, i;
 
 	/* Mask out all PHYs from auto probing.  Instead the PHYs listed in
 	 * the device tree are populated after the bus has been registered */
@@ -188,7 +188,7 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 	/* auto scan for PHYs with empty reg property */
 	for_each_available_child_of_node(np, child) {
 		/* Skip PHYs with reg property set */
-		paddr = of_get_property(child, "reg", &len);
+		paddr = of_get_property(child, "reg", NULL);
 		if (paddr)
 			continue;
 
-- 
1.9.0
