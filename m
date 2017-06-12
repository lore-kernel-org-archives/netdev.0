From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 08/13] net: dsa: mv88e6xxx: prefix Port Default VLAN macros
Date: Mon, 12 Jun 2017 12:37:40 -0400
Message-ID: <20170612163745.16868-9-vivien.didelot@savoirfairelinux.com>
References: <20170612163745.16868-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170612163745.16868-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For implicit namespacing and clarity, prefix the common Port Default
VLAN Register macros with MV88E6XXX_PORT_DEFAULT_VLAN.

Document the register and prefer ordered hex masks values for all
Marvell 16-bit registers.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c |  2 +-
 drivers/net/dsa/mv88e6xxx/port.c | 15 +++++++++------
 drivers/net/dsa/mv88e6xxx/port.h |  6 ++++--
 3 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index b1a8cbe1c215..937a43d37f37 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1950,7 +1950,7 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	/* Default VLAN ID and priority: don't set a default VLAN
 	 * ID, and set the default packet priority to zero.
 	 */
-	return mv88e6xxx_port_write(chip, port, PORT_DEFAULT_VLAN, 0x0000);
+	return mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_DEFAULT_VLAN, 0);
 }
 
 static int mv88e6xxx_port_enable(struct dsa_switch *ds, int port,
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 3cd3b4b7c944..77e4048962d1 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -706,11 +706,12 @@ int mv88e6xxx_port_get_pvid(struct mv88e6xxx_chip *chip, int port, u16 *pvid)
 	u16 reg;
 	int err;
 
-	err = mv88e6xxx_port_read(chip, port, PORT_DEFAULT_VLAN, &reg);
+	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_DEFAULT_VLAN,
+				  &reg);
 	if (err)
 		return err;
 
-	*pvid = reg & PORT_DEFAULT_VLAN_MASK;
+	*pvid = reg & MV88E6XXX_PORT_DEFAULT_VLAN_MASK;
 
 	return 0;
 }
@@ -720,14 +721,16 @@ int mv88e6xxx_port_set_pvid(struct mv88e6xxx_chip *chip, int port, u16 pvid)
 	u16 reg;
 	int err;
 
-	err = mv88e6xxx_port_read(chip, port, PORT_DEFAULT_VLAN, &reg);
+	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_DEFAULT_VLAN,
+				  &reg);
 	if (err)
 		return err;
 
-	reg &= ~PORT_DEFAULT_VLAN_MASK;
-	reg |= pvid & PORT_DEFAULT_VLAN_MASK;
+	reg &= ~MV88E6XXX_PORT_DEFAULT_VLAN_MASK;
+	reg |= pvid & MV88E6XXX_PORT_DEFAULT_VLAN_MASK;
 
-	err = mv88e6xxx_port_write(chip, port, PORT_DEFAULT_VLAN, reg);
+	err = mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_DEFAULT_VLAN,
+				   reg);
 	if (err)
 		return err;
 
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 23d94f61cac7..44ac1327e9a2 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -150,8 +150,10 @@
 #define MV88E6XXX_PORT_BASE_VLAN		0x06
 #define MV88E6XXX_PORT_BASE_VLAN_FID_3_0_MASK	0xf000
 
-#define PORT_DEFAULT_VLAN	0x07
-#define PORT_DEFAULT_VLAN_MASK	0xfff
+/* Offset 0x07: Default Port VLAN ID & Priority */
+#define MV88E6XXX_PORT_DEFAULT_VLAN		0x07
+#define MV88E6XXX_PORT_DEFAULT_VLAN_MASK	0x0fff
+
 #define PORT_CONTROL_2		0x08
 #define PORT_CONTROL_2_IGNORE_FCS	BIT(15)
 #define PORT_CONTROL_2_VTU_PRI_OVERRIDE	BIT(14)
-- 
2.13.1
