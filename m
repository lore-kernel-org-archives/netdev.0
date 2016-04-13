From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 2/8] dsa: mv88e6xxx: Add macro for registering the drivers
Date: Thu, 14 Apr 2016 01:59:52 +0200
Message-ID: <1460591998-20598-3-git-send-email-andrew@lunn.ch>
References: <1460591998-20598-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55198 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932080AbcDNABy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 20:01:54 -0400
In-Reply-To: <1460591998-20598-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macro cuts down on boilerplate. The switch driver needs to both
register itself as an MDIO driver and register itself as a switch
driver. This second registration is needed to retain backwards
compatibility with the old binding.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.h | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 5d27decc85cb..afb9ebdfc595 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -561,6 +561,26 @@ extern struct dsa_switch_driver mv88e6171_switch_driver;
 			return __ret;					\
 	})
 
-
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
 
 #endif
-- 
2.7.0
