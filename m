From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/3] of: mdio: export of_mdio_parse_addr
Date: Tue, 10 Mar 2015 16:57:11 -0700
Message-ID: <1426031833-5113-2-git-send-email-f.fainelli@gmail.com>
References: <1426031833-5113-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, devicetree@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:39445 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751701AbbCKADF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 20:03:05 -0400
In-Reply-To: <1426031833-5113-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export of_mdio_parse_addr() which allows parsing a given Ethernet PHY
node MDIO address, verify it is within the allowed range, and return
its value. This is going to be useful for the DSA code which needs to
deal with multiple layers of MDIO buses.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/of/of_mdio.c    | 3 ++-
 include/linux/of_mdio.h | 7 +++++++
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 1bd43053b8c7..0c064485d1c2 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -88,7 +88,7 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
 	return 0;
 }
 
-static int of_mdio_parse_addr(struct device *dev, const struct device_node *np)
+int of_mdio_parse_addr(struct device *dev, const struct device_node *np)
 {
 	u32 addr;
 	int ret;
@@ -108,6 +108,7 @@ static int of_mdio_parse_addr(struct device *dev, const struct device_node *np)
 
 	return addr;
 }
+EXPORT_SYMBOL(of_mdio_parse_addr);
 
 /**
  * of_mdiobus_register - Register mii_bus and create PHYs from the device tree
diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
index d449018d0726..8f2237eb3485 100644
--- a/include/linux/of_mdio.h
+++ b/include/linux/of_mdio.h
@@ -24,6 +24,7 @@ struct phy_device *of_phy_attach(struct net_device *dev,
 				 phy_interface_t iface);
 
 extern struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np);
+extern int of_mdio_parse_addr(struct device *dev, const struct device_node *np);
 
 #else /* CONFIG_OF */
 static inline int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
@@ -60,6 +61,12 @@ static inline struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np)
 {
 	return NULL;
 }
+
+static inline int of_mdio_parse_addr(struct device *dev,
+				     const struct device_node *np)
+{
+	return -ENOSYS;
+}
 #endif /* CONFIG_OF */
 
 #if defined(CONFIG_OF) && defined(CONFIG_FIXED_PHY)
-- 
2.1.0
