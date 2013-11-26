From: <shh.xie@gmail.com>
Subject: [PATCH 1/5][v2] phylib: Add Clause 45 read/write functions
Date: Tue, 26 Nov 2013 17:51:52 +0800
Message-ID: <1385459512-23731-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Emilian.Medve@freescale.com>, <madalin.bucur@freescale.com>
To: <davem@davemloft.net>, <jg1.han@samsung.com>,
	<mugunthanvnm@ti.com>, <f.fainelli@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Fleming <afleming@freescale.com>

Need an extra parameter to read or write Clause 45 PHYs, so
need a different API with the extra parameter.

Signed-off-by: Andy Fleming <afleming@freescale.com>
Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
v2: no change.

 include/linux/phy.h | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index 48a4dc3..2549b42 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -498,6 +498,21 @@ static inline int phy_read(struct phy_device *phydev, u32 regnum)
 }
 
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
+	return mdiobus_read(phydev->bus, phydev->addr,
+		MII_ADDR_C45 | (devad << 16) | (regnum & 0xffff));
+}
+
+/**
  * phy_write - Convenience function for writing a given PHY register
  * @phydev: the phy_device struct
  * @regnum: register number to write
@@ -533,6 +548,24 @@ static inline bool phy_is_internal(struct phy_device *phydev)
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
+		u32 regnum, u16 val)
+{
+	regnum = MII_ADDR_C45 | ((devad & 0x1f) << 16) | (regnum & 0xffff);
+
+	return mdiobus_write(phydev->bus, phydev->addr, regnum, val);
+}
+
 struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
 		bool is_c45, struct phy_c45_device_ids *c45_ids);
 struct phy_device *get_phy_device(struct mii_bus *bus, int addr, bool is_c45);
-- 
1.8.4.1
