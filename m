From: <shh.xie@gmail.com>
Subject: [PATCH 6/6] [v6] phylib: Add of_phy_attach
Date: Fri, 10 Jan 2014 14:28:11 +0800
Message-ID: <1389335291-384-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Shaohui.Xie@freescale.com>, Andy Fleming <afleming@gmail.com>
To: <davem@davemloft.net>, <jg1.han@samsung.com>,
	<mugunthanvnm@ti.com>, <f.fainelli@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Fleming <afleming@gmail.com>

10G PHYs don't currently support running the state machine, which
is implicitly setup via of_phy_connect(). Therefore, it is necessary
to implement an OF version of phy_attach(), which does everything
except start the state machine.

Signed-off-by: Andy Fleming <afleming@gmail.com>
Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
Acked-by: Florian Fainelli <f.fainelli@gmail.com>
---
changes for v6:
rebased on top of 'net-next' tree. commit id 11b57f90257c1.

 drivers/of/of_mdio.c    | 20 ++++++++++++++++++++
 include/linux/of_mdio.h | 10 ++++++++++
 2 files changed, 30 insertions(+)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index a43b852..875b7b6 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -254,3 +254,23 @@ struct phy_device *of_phy_connect_fixed_link(struct net_device *dev,
 	return IS_ERR(phy) ? NULL : phy;
 }
 EXPORT_SYMBOL(of_phy_connect_fixed_link);
+
+/**
+ * of_phy_attach - Attach to a PHY without starting the state machine
+ * @dev: pointer to net_device claiming the phy
+ * @phy_np: Node pointer for the PHY
+ * @flags: flags to pass to the PHY
+ * @iface: PHY data interface type
+ */
+struct phy_device *of_phy_attach(struct net_device *dev,
+				 struct device_node *phy_np, u32 flags,
+				 phy_interface_t iface)
+{
+	struct phy_device *phy = of_phy_find_device(phy_np);
+
+	if (!phy)
+		return NULL;
+
+	return phy_attach_direct(dev, phy, flags, iface) ? NULL : phy;
+}
+EXPORT_SYMBOL(of_phy_attach);
diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
index 8163107..6fe8464 100644
--- a/include/linux/of_mdio.h
+++ b/include/linux/of_mdio.h
@@ -19,6 +19,9 @@ extern struct phy_device *of_phy_connect(struct net_device *dev,
 					 struct device_node *phy_np,
 					 void (*hndlr)(struct net_device *),
 					 u32 flags, phy_interface_t iface);
+struct phy_device *of_phy_attach(struct net_device *dev,
+				 struct device_node *phy_np, u32 flags,
+				 phy_interface_t iface);
 extern struct phy_device *of_phy_connect_fixed_link(struct net_device *dev,
 					 void (*hndlr)(struct net_device *),
 					 phy_interface_t iface);
@@ -44,6 +47,13 @@ static inline struct phy_device *of_phy_connect(struct net_device *dev,
 	return NULL;
 }
 
+static inline struct phy_device *of_phy_attach(struct net_device *dev,
+					       struct device_node *phy_np,
+					       u32 flags, phy_interface_t iface)
+{
+	return NULL;
+}
+
 static inline struct phy_device *of_phy_connect_fixed_link(struct net_device *dev,
 							   void (*hndlr)(struct net_device *),
 							   phy_interface_t iface)
-- 
1.8.4.1
