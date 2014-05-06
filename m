From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH] net: mdio: of_mdiobus_register(): fall back to mdiobus_register() for !CONFIG_OF
Date: Tue,  6 May 2014 18:52:16 +0200
Message-ID: <1399395136-12139-1-git-send-email-zonque@gmail.com>
Cc: mugunthanvnm@ti.com, davem@davemloft.net, netdev@vger.kernel.org,
	Daniel Mack <zonque@gmail.com>
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:39884 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159AbaEFQwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 12:52:24 -0400
Received: by mail-ee0-f51.google.com with SMTP id e51so1952715eek.24
        for <netdev@vger.kernel.org>; Tue, 06 May 2014 09:52:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If CONFIG_OF is not set, make of_mdiobus_register() call
mdiobus_register() instead of returning -ENOSYS.

This way, we can just call of_mdiobus_register() from all DT-enabled
drivers to handle the compat cases.

Signed-off-by: Daniel Mack <zonque@gmail.com>
Suggested-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/of_mdio.h | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
index 6fe8464..881a7c3 100644
--- a/include/linux/of_mdio.h
+++ b/include/linux/of_mdio.h
@@ -31,7 +31,12 @@ extern struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np);
 #else /* CONFIG_OF */
 static inline int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 {
-	return -ENOSYS;
+	/*
+	 * Fall back to the non-DT function to register a bus.
+	 * This way, we don't have to keep compat bits around in drivers.
+	 */
+
+	return mdiobus_register(mdio);
 }
 
 static inline struct phy_device *of_phy_find_device(struct device_node *phy_np)
-- 
1.9.0
