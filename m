From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 5/5] net: dsa: mv88e6xxx: Implement the 6390 external MDIO bus
Date: Tue, 24 Jan 2017 14:53:51 +0100
Message-ID: <1485266031-4980-6-git-send-email-andrew@lunn.ch>
References: <1485266031-4980-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43703 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750792AbdAXN4v (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 08:56:51 -0500
In-Reply-To: <1485266031-4980-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With all the infrastructure in place, implement access to the external
MDIO bus on the 6390 family.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/global2.c   | 8 ++++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 1 +
 2 files changed, 9 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index 1f9a12a1fad9..353e26bea3c3 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -506,8 +506,12 @@ int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip,
 			      int addr, int reg, u16 *val)
 {
 	u16 cmd = GLOBAL2_SMI_PHY_CMD_OP_22_READ_DATA | (addr << 5) | reg;
+	struct mv88e6xxx_mdio_bus *mdio_bus = bus->priv;
 	int err;
 
+	if (mdio_bus->external)
+		cmd |= GLOBAL2_SMI_PHY_CMD_EXTERNAL;
+
 	err = mv88e6xxx_g2_smi_phy_wait(chip);
 	if (err)
 		return err;
@@ -524,8 +528,12 @@ int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip,
 			       int addr, int reg, u16 val)
 {
 	u16 cmd = GLOBAL2_SMI_PHY_CMD_OP_22_WRITE_DATA | (addr << 5) | reg;
+	struct mv88e6xxx_mdio_bus *mdio_bus = bus->priv;
 	int err;
 
+	if (mdio_bus->external)
+		cmd |= GLOBAL2_SMI_PHY_CMD_EXTERNAL;
+
 	err = mv88e6xxx_g2_smi_phy_wait(chip);
 	if (err)
 		return err;
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 7d24add45e74..572d585dc1e2 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -387,6 +387,7 @@
 #define GLOBAL2_PTP_AVB_DATA	0x17
 #define GLOBAL2_SMI_PHY_CMD			0x18
 #define GLOBAL2_SMI_PHY_CMD_BUSY		BIT(15)
+#define GLOBAL2_SMI_PHY_CMD_EXTERNAL		BIT(13)
 #define GLOBAL2_SMI_PHY_CMD_MODE_22		BIT(12)
 #define GLOBAL2_SMI_PHY_CMD_OP_22_WRITE_DATA	((0x1 << 10) | \
 						 GLOBAL2_SMI_PHY_CMD_MODE_22 | \
-- 
2.11.0
