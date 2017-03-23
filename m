From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 1/3] of_mdio: Correct check against CONFIG_OF
Date: Thu, 23 Mar 2017 10:01:17 -0700
Message-ID: <20170323170119.4004-2-f.fainelli@gmail.com>
References: <20170323170119.4004-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, rmk+kernel@armlinux.org.uk,
        arnd@arndb.de, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:36219 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755855AbdCWRB1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 13:01:27 -0400
Received: by mail-oi0-f68.google.com with SMTP id l203so4571979oia.3
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 10:01:26 -0700 (PDT)
In-Reply-To: <20170323170119.4004-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_OF_MDIO is actually what triggers the build of drivers/of/of_mdio.c, so
providing inline stubs when CONFIG_OF_MDIO=y should be based on that symbol as
well.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/of_mdio.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
index a58cca8bcb29..ba35ba520487 100644
--- a/include/linux/of_mdio.h
+++ b/include/linux/of_mdio.h
@@ -12,7 +12,7 @@
 #include <linux/phy.h>
 #include <linux/of.h>
 
-#ifdef CONFIG_OF
+#if IS_ENABLED(CONFIG_OF_MDIO)
 extern int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np);
 extern struct phy_device *of_phy_find_device(struct device_node *phy_np);
 extern struct phy_device *of_phy_connect(struct net_device *dev,
@@ -32,7 +32,7 @@ extern int of_phy_register_fixed_link(struct device_node *np);
 extern void of_phy_deregister_fixed_link(struct device_node *np);
 extern bool of_phy_is_fixed_link(struct device_node *np);
 
-#else /* CONFIG_OF */
+#else /* CONFIG_OF_MDIO */
 static inline int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 {
 	/*
-- 
2.9.3
