From: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Subject: [RFC PATCH 16/17] phy_device: Add phy_setmask helper function
Date: Thu, 20 Oct 2011 17:00:23 -0400
Message-ID: <1319144425-15547-17-git-send-email-Kyle.D.Moffett@boeing.com>
References: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
Cc: Kyle Moffett <Kyle.D.Moffett@boeing.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Frysinger <vapier@gentoo.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the PHY layer there are frequently occasions when code needs to
modify only some subset of the bits in a particular 16-bit register.

To clean up the flow control and improve readability a phy_setmask()
helper function is added.

Signed-off-by: Kyle Moffett <Kyle.D.Moffett@boeing.com>
---
 include/linux/phy.h |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index 0cb300d..3713c8d 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -474,6 +474,26 @@ static inline int phy_write(struct phy_device *phydev, u32 regnum, u16 val)
 	return mdiobus_write(phydev->bus, phydev->addr, regnum, val);
 }
 
+/**
+ * phy_setmask - Convenience function for changing PHY register bits
+ * @phydev: the phy_device struct
+ * @regnum: register number to write
+ * @val: value to write to the @mask bits of @regnum
+ * @mask: the mask of bits to change
+ *
+ * NOTE: MUST NOT be called from interrupt context,
+ * because the bus read/write functions may wait for an interrupt
+ * to conclude the operation.
+ */
+static inline int phy_setmask(struct phy_device *phydev, u16 regnum,
+		u16 val, u16 mask)
+{
+	int ret = phy_read(phydev, regnum);
+	if (ret < 0)
+		return ret;
+	return phy_write(phydev, regnum, (ret & ~mask) | (val & mask));
+}
+
 int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id);
 struct phy_device* get_phy_device(struct mii_bus *bus, int addr);
 int phy_device_register(struct phy_device *phy);
-- 
1.7.2.5
