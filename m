From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: [PATCH] of/mdio: Staticise !CONFIG_OF stubs
Date: Wed, 10 Oct 2012 13:33:38 +0900
Message-ID: <1349843618-11209-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, netdev@vger.kernel.org,
	Mark Brown <broonie@opensource.wolfsonmicro.com>
To: Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:58000 "EHLO
	opensource.wolfsonmicro.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751003Ab2JJEdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 00:33:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The !CONFIG_OF stubs aren't static so if multiple files include the
header with this configuration then the linker will see multiple
definitions of the stubs.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Mark Brown <broonie@opensource.wolfsonmicro.com>
---
 include/linux/of_mdio.h |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
index 6ef49b8..00f336f 100644
--- a/include/linux/of_mdio.h
+++ b/include/linux/of_mdio.h
@@ -26,17 +26,17 @@ extern struct phy_device *of_phy_connect_fixed_link(struct net_device *dev,
 extern struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np);
 
 #else /* CONFIG_OF */
-int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
+static int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 {
 	return -ENOSYS;
 }
 
-struct phy_device *of_phy_find_device(struct device_node *phy_np)
+static struct phy_device *of_phy_find_device(struct device_node *phy_np)
 {
 	return NULL;
 }
 
-struct phy_device *of_phy_connect(struct net_device *dev,
+static struct phy_device *of_phy_connect(struct net_device *dev,
 					 struct device_node *phy_np,
 					 void (*hndlr)(struct net_device *),
 					 u32 flags, phy_interface_t iface)
@@ -44,14 +44,14 @@ struct phy_device *of_phy_connect(struct net_device *dev,
 	return NULL;
 }
 
-struct phy_device *of_phy_connect_fixed_link(struct net_device *dev,
+static struct phy_device *of_phy_connect_fixed_link(struct net_device *dev,
 					 void (*hndlr)(struct net_device *),
 					 phy_interface_t iface)
 {
 	return NULL;
 }
 
-struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np)
+static struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np)
 {
 	return NULL;
 }
-- 
1.7.10.4
