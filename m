From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 06/13] net: dsa: mv88e6xxx: prefix Port Control 1 macros
Date: Mon, 12 Jun 2017 12:37:38 -0400
Message-ID: <20170612163745.16868-7-vivien.didelot@savoirfairelinux.com>
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

For implicit namespacing and clarity, prefix the common Port Control 1
Register macros with MV88E6XXX_PORT_CTL1.

Document the register and prefer ordered hex masks values for all
Marvell 16-bit registers.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/port.c | 17 ++++++++++-------
 drivers/net/dsa/mv88e6xxx/port.h |  8 +++++---
 2 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index a51d766b3c76..6b972626f326 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -595,16 +595,16 @@ int mv88e6xxx_port_set_message_port(struct mv88e6xxx_chip *chip, int port,
 	u16 val;
 	int err;
 
-	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL_1, &val);
+	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_CTL1, &val);
 	if (err)
 		return err;
 
 	if (message_port)
-		val |= PORT_CONTROL_1_MESSAGE_PORT;
+		val |= MV88E6XXX_PORT_CTL1_MESSAGE_PORT;
 	else
-		val &= ~PORT_CONTROL_1_MESSAGE_PORT;
+		val &= ~MV88E6XXX_PORT_CTL1_MESSAGE_PORT;
 
-	return mv88e6xxx_port_write(chip, port, PORT_CONTROL_1, val);
+	return mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_CTL1, val);
 }
 
 /* Offset 0x06: Port Based VLAN Map */
@@ -646,7 +646,8 @@ int mv88e6xxx_port_get_fid(struct mv88e6xxx_chip *chip, int port, u16 *fid)
 
 	/* Port's default FID upper bits are located in reg 0x05, offset 0 */
 	if (upper_mask) {
-		err = mv88e6xxx_port_read(chip, port, PORT_CONTROL_1, &reg);
+		err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_CTL1,
+					  &reg);
 		if (err)
 			return err;
 
@@ -679,14 +680,16 @@ int mv88e6xxx_port_set_fid(struct mv88e6xxx_chip *chip, int port, u16 fid)
 
 	/* Port's default FID upper bits are located in reg 0x05, offset 0 */
 	if (upper_mask) {
-		err = mv88e6xxx_port_read(chip, port, PORT_CONTROL_1, &reg);
+		err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_CTL1,
+					  &reg);
 		if (err)
 			return err;
 
 		reg &= ~upper_mask;
 		reg |= (fid >> 4) & upper_mask;
 
-		err = mv88e6xxx_port_write(chip, port, PORT_CONTROL_1, reg);
+		err = mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_CTL1,
+					   reg);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 880f1b117248..451f99fd81cf 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -141,9 +141,11 @@
 #define MV88E6XXX_PORT_CTL0_STATE_LEARNING			0x0002
 #define MV88E6XXX_PORT_CTL0_STATE_FORWARDING			0x0003
 
-#define PORT_CONTROL_1		0x05
-#define PORT_CONTROL_1_MESSAGE_PORT	BIT(15)
-#define PORT_CONTROL_1_FID_11_4_MASK	(0xff << 0)
+/* Offset 0x05: Port Control 1 */
+#define MV88E6XXX_PORT_CTL1			0x05
+#define MV88E6XXX_PORT_CTL1_MESSAGE_PORT	0x8000
+#define MV88E6XXX_PORT_CTL1_FID_11_4_MASK	0x00ff
+
 #define PORT_BASE_VLAN		0x06
 #define PORT_BASE_VLAN_FID_3_0_MASK	(0xf << 12)
 #define PORT_DEFAULT_VLAN	0x07
-- 
2.13.1
