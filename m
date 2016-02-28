From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC v2 19/32] dsa: mv88e6xxx: Add macro for registering the drivers
Date: Sun, 28 Feb 2016 17:41:27 +0100
Message-ID: <1456677700-23027-20-git-send-email-andrew@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44968 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759643AbcB1Qmw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 11:42:52 -0500
In-Reply-To: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macro cuts down on boilerplate. The switch driver needs to both
register itself as an MDIO driver and register itself as a switch
driver. This second registration is needed to retain backwards
compatibility with the old binding.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.h | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index a4ae99b7cfd0..ce05964da85f 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -546,3 +546,26 @@ extern struct dsa_switch_driver mv88e6171_switch_driver;
 
 
 #endif
+
+/**
+ * mv88e6xxx_module_driver() - Helper macro for registering mv88e6xxx drivers
+ *
+ * Helper macro for mv88e6xxx drivers which do not do anything special
+ * in module init/exit. Each module may only use this macro once, and
+ * calling it replaces module_init() and module_exit().
+ */
+#define mv88e6xxx_module_driver(_mdio_driver, _switch_driver)		\
+static int __init mv88e6xxx_module_init(void)				\
+{									\
+	register_switch_driver(&_switch_driver);			\
+	return mdio_driver_register(&_mdio_driver);			\
+}									\
+module_init(mv88e6xxx_module_init);					\
+									\
+static void __exit mv88e6xxx_module_exit(void)				\
+{									\
+	mdio_driver_unregister(&_mdio_driver);				\
+	unregister_switch_driver(&_switch_driver);			\
+}									\
+module_exit(mv88e6xxx_module_exit)
+
-- 
2.7.0
