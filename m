From: <shh.xie@gmail.com>
Subject: [PATCH 1/6] [v6] phylib: Add Clause 45 read/write functions
Date: Fri, 10 Jan 2014 14:25:09 +0800
Message-ID: <1389335109-28179-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Shaohui.Xie@freescale.com>, Andy Fleming <afleming@gmail.com>
To: <davem@davemloft.net>, <jg1.han@samsung.com>,
	<mugunthanvnm@ti.com>, <f.fainelli@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe004.messaging.microsoft.com ([216.32.180.14]:1127 "EHLO
	va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750877AbaAJHxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 02:53:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@gmail.com>

Need an extra parameter to read or write Clause 45 PHYs, so
need a different API with the extra parameter.

Signed-off-by: Andy Fleming <afleming@gmail.com>
Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
changes for v6:
rebased on top of 'net-next' tree. commit id 11b57f90257c1.

 include/linux/phy.h | 39 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index 7c81dd8..3eda43c 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -488,6 +488,24 @@ struct phy_fixup {
 };
 
 /**
+ * phy_read_mmd - Convenience function for reading a register
+ * from an MMD on a given PHY.
+ * @phydev: The phy_device struct
+ * @devad: The MMD to read from
+ * @regnum: The register on the MMD to read
+ *
+ * Same rules as for phy_read();
+ */
+static inline int phy_read_mmd(struct phy_device *phydev, int devad, u32 regnum)
+{
+	if (!phydev->is_c45)
+		return -EOPNOTSUPP;
+
+	return mdiobus_read(phydev->bus, phydev->addr,
+			    MII_ADDR_C45 | (devad << 16) | (regnum & 0xffff));
+}
+
+/**
  * phy_read - Convenience function for reading a given PHY register
  * @phydev: the phy_device struct
  * @regnum: register number to read
@@ -537,6 +555,27 @@ static inline bool phy_is_internal(struct phy_device *phydev)
 	return phydev->is_internal;
 }
 
+/**
+ * phy_write_mmd - Convenience function for writing a register
+ * on an MMD on a given PHY.
+ * @phydev: The phy_device struct
+ * @devad: The MMD to read from
+ * @regnum: The register on the MMD to read
+ * @val: value to write to @regnum
+ *
+ * Same rules as for phy_write();
+ */
+static inline int phy_write_mmd(struct phy_device *phydev, int devad,
+				u32 regnum, u16 val)
+{
+	if (!phydev->is_c45)
+		return -EOPNOTSUPP;
+
+	regnum = MII_ADDR_C45 | ((devad & 0x1f) << 16) | (regnum & 0xffff);
+
+	return mdiobus_write(phydev->bus, phydev->addr, regnum, val);
+}
+
 struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
 				     bool is_c45,
 				     struct phy_c45_device_ids *c45_ids);
-- 
1.8.4.1
