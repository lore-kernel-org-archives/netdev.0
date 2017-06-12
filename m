From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 07/13] net: dsa: mv88e6xxx: prefix Port Based VLAN macros
Date: Mon, 12 Jun 2017 12:37:39 -0400
Message-ID: <20170612163745.16868-8-vivien.didelot@savoirfairelinux.com>
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

For implicit namespacing and clarity, prefix the common Port Based VLAN
Register macros with MV88E6XXX_PORT_BASE_VLAN.

Document the register and prefer ordered hex masks values for all
Marvell 16-bit registers.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/port.c | 10 +++++-----
 drivers/net/dsa/mv88e6xxx/port.h |  6 ++++--
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 6b972626f326..3cd3b4b7c944 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -615,14 +615,14 @@ int mv88e6xxx_port_set_vlan_map(struct mv88e6xxx_chip *chip, int port, u16 map)
 	u16 reg;
 	int err;
 
-	err = mv88e6xxx_port_read(chip, port, PORT_BASE_VLAN, &reg);
+	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_BASE_VLAN, &reg);
 	if (err)
 		return err;
 
 	reg &= ~mask;
 	reg |= map & mask;
 
-	err = mv88e6xxx_port_write(chip, port, PORT_BASE_VLAN, reg);
+	err = mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_BASE_VLAN, reg);
 	if (err)
 		return err;
 
@@ -638,7 +638,7 @@ int mv88e6xxx_port_get_fid(struct mv88e6xxx_chip *chip, int port, u16 *fid)
 	int err;
 
 	/* Port's default FID lower 4 bits are located in reg 0x06, offset 12 */
-	err = mv88e6xxx_port_read(chip, port, PORT_BASE_VLAN, &reg);
+	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_BASE_VLAN, &reg);
 	if (err)
 		return err;
 
@@ -667,14 +667,14 @@ int mv88e6xxx_port_set_fid(struct mv88e6xxx_chip *chip, int port, u16 fid)
 		return -EINVAL;
 
 	/* Port's default FID lower 4 bits are located in reg 0x06, offset 12 */
-	err = mv88e6xxx_port_read(chip, port, PORT_BASE_VLAN, &reg);
+	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_BASE_VLAN, &reg);
 	if (err)
 		return err;
 
 	reg &= 0x0fff;
 	reg |= (fid & 0x000f) << 12;
 
-	err = mv88e6xxx_port_write(chip, port, PORT_BASE_VLAN, reg);
+	err = mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_BASE_VLAN, reg);
 	if (err)
 		return err;
 
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 451f99fd81cf..23d94f61cac7 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -146,8 +146,10 @@
 #define MV88E6XXX_PORT_CTL1_MESSAGE_PORT	0x8000
 #define MV88E6XXX_PORT_CTL1_FID_11_4_MASK	0x00ff
 
-#define PORT_BASE_VLAN		0x06
-#define PORT_BASE_VLAN_FID_3_0_MASK	(0xf << 12)
+/* Offset 0x06: Port Based VLAN Map */
+#define MV88E6XXX_PORT_BASE_VLAN		0x06
+#define MV88E6XXX_PORT_BASE_VLAN_FID_3_0_MASK	0xf000
+
 #define PORT_DEFAULT_VLAN	0x07
 #define PORT_DEFAULT_VLAN_MASK	0xfff
 #define PORT_CONTROL_2		0x08
-- 
2.13.1
