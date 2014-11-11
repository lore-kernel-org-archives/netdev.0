From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 02/22] net: phy: add module_phy_driver macro
Date: Tue, 11 Nov 2014 18:37:20 +0100
Message-ID: <1415727460-20417-3-git-send-email-johan@kernel.org>
References: <1415727460-20417-1-git-send-email-johan@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415727460-20417-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add helper macro for PHY drivers which do not do anything special in
module init/exit. This will allow us to eliminate a lot of boilerplate
code.

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 include/linux/phy.h | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index ed39956b5613..c50e1f1f46e0 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -745,4 +745,28 @@ int __init mdio_bus_init(void);
 void mdio_bus_exit(void);
 
 extern struct bus_type mdio_bus_type;
+
+/**
+ * module_phy_driver() - Helper macro for registering PHY drivers
+ * @__phy_drivers: array of PHY drivers to register
+ *
+ * Helper macro for PHY drivers which do not do anything special in module
+ * init/exit. Each module may only use this macro once, and calling it
+ * replaces module_init() and module_exit().
+ */
+#define phy_module_driver(__phy_drivers, __count)			\
+static int __init phy_module_init(void)					\
+{									\
+	return phy_drivers_register(__phy_drivers, __count);		\
+}									\
+module_init(phy_module_init);						\
+static void __exit phy_module_exit(void)				\
+{									\
+	phy_drivers_unregister(__phy_drivers, __count);			\
+}									\
+module_exit(phy_module_exit)
+
+#define module_phy_driver(__phy_drivers)				\
+	phy_module_driver(__phy_drivers, ARRAY_SIZE(__phy_drivers))
+
 #endif /* __PHY_H */
-- 
2.0.4
