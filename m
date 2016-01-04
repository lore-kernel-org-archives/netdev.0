From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH net-next 02/24] mdio: Move mdiobus_read/write operatings into mdio.h
Date: Mon,  4 Jan 2016 18:36:40 +0100
Message-ID: <1451929022-5580-3-git-send-email-andrew@lunn.ch>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34976 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752962AbcADRi0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 12:38:26 -0500
In-Reply-To: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are logically MDIO operations, not phy operations, so move them
into the mdio header.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 include/linux/mdio.h | 6 ++++++
 include/linux/phy.h  | 6 +-----
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/linux/mdio.h b/include/linux/mdio.h
index b42963bc81dd..0d073c23c10d 100644
--- a/include/linux/mdio.h
+++ b/include/linux/mdio.h
@@ -11,6 +11,7 @@
 
 #include <uapi/linux/mdio.h>
 
+struct mii_bus;
 
 static inline bool mdio_phy_id_is_c45(int phy_id)
 {
@@ -173,4 +174,9 @@ static inline u16 ethtool_adv_to_mmd_eee_adv_t(u32 adv)
 	return reg;
 }
 
+int mdiobus_read(struct mii_bus *bus, int addr, u32 regnum);
+int mdiobus_read_nested(struct mii_bus *bus, int addr, u32 regnum);
+int mdiobus_write(struct mii_bus *bus, int addr, u32 regnum, u16 val);
+int mdiobus_write_nested(struct mii_bus *bus, int addr, u32 regnum, u16 val);
+
 #endif /* __LINUX_MDIO_H__ */
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 77b5e56e2a92..8ca161a37e8a 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -18,6 +18,7 @@
 
 #include <linux/spinlock.h>
 #include <linux/ethtool.h>
+#include <linux/mdio.h>
 #include <linux/mii.h>
 #include <linux/module.h>
 #include <linux/timer.h>
@@ -212,11 +213,6 @@ static inline struct mii_bus *devm_mdiobus_alloc(struct device *dev)
 
 void devm_mdiobus_free(struct device *dev, struct mii_bus *bus);
 struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr);
-int mdiobus_read(struct mii_bus *bus, int addr, u32 regnum);
-int mdiobus_read_nested(struct mii_bus *bus, int addr, u32 regnum);
-int mdiobus_write(struct mii_bus *bus, int addr, u32 regnum, u16 val);
-int mdiobus_write_nested(struct mii_bus *bus, int addr, u32 regnum, u16 val);
-
 
 #define PHY_INTERRUPT_DISABLED	0x0
 #define PHY_INTERRUPT_ENABLED	0x80000000
-- 
2.6.4
