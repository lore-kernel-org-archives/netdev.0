From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 02/13] net: dsa: mv88e6xxx: prefix Port MAC Control macros
Date: Mon, 12 Jun 2017 12:37:34 -0400
Message-ID: <20170612163745.16868-3-vivien.didelot@savoirfairelinux.com>
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

For implicit namespacing and clarity, prefix the common MAC Control
Register macros with MV88E6XXX_PORT_MAC_CTL and the ones which differ
between implementations with a chosen reference model
(e.g. MV88E6065_PORT_MAC_CTL_SPEED_200.)

Document the register and prefer ordered hex masks values for all
Marvell 16-bit registers.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/port.c | 80 +++++++++++++++++++++-------------------
 drivers/net/dsa/mv88e6xxx/port.h | 40 ++++++++++----------
 2 files changed, 64 insertions(+), 56 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 906b9112e28c..60c31b6c2f47 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -49,23 +49,23 @@ static int mv88e6xxx_port_set_rgmii_delay(struct mv88e6xxx_chip *chip, int port,
 	u16 reg;
 	int err;
 
-	err = mv88e6xxx_port_read(chip, port, PORT_PCS_CTRL, &reg);
+	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_MAC_CTL, &reg);
 	if (err)
 		return err;
 
-	reg &= ~(PORT_PCS_CTRL_RGMII_DELAY_RXCLK |
-		 PORT_PCS_CTRL_RGMII_DELAY_TXCLK);
+	reg &= ~(MV88E6XXX_PORT_MAC_CTL_RGMII_DELAY_RXCLK |
+		 MV88E6XXX_PORT_MAC_CTL_RGMII_DELAY_TXCLK);
 
 	switch (mode) {
 	case PHY_INTERFACE_MODE_RGMII_RXID:
-		reg |= PORT_PCS_CTRL_RGMII_DELAY_RXCLK;
+		reg |= MV88E6XXX_PORT_MAC_CTL_RGMII_DELAY_RXCLK;
 		break;
 	case PHY_INTERFACE_MODE_RGMII_TXID:
-		reg |= PORT_PCS_CTRL_RGMII_DELAY_TXCLK;
+		reg |= MV88E6XXX_PORT_MAC_CTL_RGMII_DELAY_TXCLK;
 		break;
 	case PHY_INTERFACE_MODE_RGMII_ID:
-		reg |= PORT_PCS_CTRL_RGMII_DELAY_RXCLK |
-			PORT_PCS_CTRL_RGMII_DELAY_TXCLK;
+		reg |= MV88E6XXX_PORT_MAC_CTL_RGMII_DELAY_RXCLK |
+			MV88E6XXX_PORT_MAC_CTL_RGMII_DELAY_TXCLK;
 		break;
 	case PHY_INTERFACE_MODE_RGMII:
 		break;
@@ -73,13 +73,13 @@ static int mv88e6xxx_port_set_rgmii_delay(struct mv88e6xxx_chip *chip, int port,
 		return 0;
 	}
 
-	err = mv88e6xxx_port_write(chip, port, PORT_PCS_CTRL, reg);
+	err = mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_MAC_CTL, reg);
 	if (err)
 		return err;
 
 	dev_dbg(chip->dev, "p%d: delay RXCLK %s, TXCLK %s\n", port,
-		reg & PORT_PCS_CTRL_RGMII_DELAY_RXCLK ? "yes" : "no",
-		reg & PORT_PCS_CTRL_RGMII_DELAY_TXCLK ? "yes" : "no");
+		reg & MV88E6XXX_PORT_MAC_CTL_RGMII_DELAY_RXCLK ? "yes" : "no",
+		reg & MV88E6XXX_PORT_MAC_CTL_RGMII_DELAY_TXCLK ? "yes" : "no");
 
 	return 0;
 }
@@ -107,18 +107,20 @@ int mv88e6xxx_port_set_link(struct mv88e6xxx_chip *chip, int port, int link)
 	u16 reg;
 	int err;
 
-	err = mv88e6xxx_port_read(chip, port, PORT_PCS_CTRL, &reg);
+	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_MAC_CTL, &reg);
 	if (err)
 		return err;
 
-	reg &= ~(PORT_PCS_CTRL_FORCE_LINK | PORT_PCS_CTRL_LINK_UP);
+	reg &= ~(MV88E6XXX_PORT_MAC_CTL_FORCE_LINK |
+		 MV88E6XXX_PORT_MAC_CTL_LINK_UP);
 
 	switch (link) {
 	case LINK_FORCED_DOWN:
-		reg |= PORT_PCS_CTRL_FORCE_LINK;
+		reg |= MV88E6XXX_PORT_MAC_CTL_FORCE_LINK;
 		break;
 	case LINK_FORCED_UP:
-		reg |= PORT_PCS_CTRL_FORCE_LINK | PORT_PCS_CTRL_LINK_UP;
+		reg |= MV88E6XXX_PORT_MAC_CTL_FORCE_LINK |
+			MV88E6XXX_PORT_MAC_CTL_LINK_UP;
 		break;
 	case LINK_UNFORCED:
 		/* normal link detection */
@@ -127,13 +129,13 @@ int mv88e6xxx_port_set_link(struct mv88e6xxx_chip *chip, int port, int link)
 		return -EINVAL;
 	}
 
-	err = mv88e6xxx_port_write(chip, port, PORT_PCS_CTRL, reg);
+	err = mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_MAC_CTL, reg);
 	if (err)
 		return err;
 
 	dev_dbg(chip->dev, "p%d: %s link %s\n", port,
-		reg & PORT_PCS_CTRL_FORCE_LINK ? "Force" : "Unforce",
-		reg & PORT_PCS_CTRL_LINK_UP ? "up" : "down");
+		reg & MV88E6XXX_PORT_MAC_CTL_FORCE_LINK ? "Force" : "Unforce",
+		reg & MV88E6XXX_PORT_MAC_CTL_LINK_UP ? "up" : "down");
 
 	return 0;
 }
@@ -143,18 +145,20 @@ int mv88e6xxx_port_set_duplex(struct mv88e6xxx_chip *chip, int port, int dup)
 	u16 reg;
 	int err;
 
-	err = mv88e6xxx_port_read(chip, port, PORT_PCS_CTRL, &reg);
+	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_MAC_CTL, &reg);
 	if (err)
 		return err;
 
-	reg &= ~(PORT_PCS_CTRL_FORCE_DUPLEX | PORT_PCS_CTRL_DUPLEX_FULL);
+	reg &= ~(MV88E6XXX_PORT_MAC_CTL_FORCE_DUPLEX |
+		 MV88E6XXX_PORT_MAC_CTL_DUPLEX_FULL);
 
 	switch (dup) {
 	case DUPLEX_HALF:
-		reg |= PORT_PCS_CTRL_FORCE_DUPLEX;
+		reg |= MV88E6XXX_PORT_MAC_CTL_FORCE_DUPLEX;
 		break;
 	case DUPLEX_FULL:
-		reg |= PORT_PCS_CTRL_FORCE_DUPLEX | PORT_PCS_CTRL_DUPLEX_FULL;
+		reg |= MV88E6XXX_PORT_MAC_CTL_FORCE_DUPLEX |
+			MV88E6XXX_PORT_MAC_CTL_DUPLEX_FULL;
 		break;
 	case DUPLEX_UNFORCED:
 		/* normal duplex detection */
@@ -163,13 +167,13 @@ int mv88e6xxx_port_set_duplex(struct mv88e6xxx_chip *chip, int port, int dup)
 		return -EINVAL;
 	}
 
-	err = mv88e6xxx_port_write(chip, port, PORT_PCS_CTRL, reg);
+	err = mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_MAC_CTL, reg);
 	if (err)
 		return err;
 
 	dev_dbg(chip->dev, "p%d: %s %s duplex\n", port,
-		reg & PORT_PCS_CTRL_FORCE_DUPLEX ? "Force" : "Unforce",
-		reg & PORT_PCS_CTRL_DUPLEX_FULL ? "full" : "half");
+		reg & MV88E6XXX_PORT_MAC_CTL_FORCE_DUPLEX ? "Force" : "Unforce",
+		reg & MV88E6XXX_PORT_MAC_CTL_DUPLEX_FULL ? "full" : "half");
 
 	return 0;
 }
@@ -182,47 +186,49 @@ static int mv88e6xxx_port_set_speed(struct mv88e6xxx_chip *chip, int port,
 
 	switch (speed) {
 	case 10:
-		ctrl = PORT_PCS_CTRL_SPEED_10;
+		ctrl = MV88E6XXX_PORT_MAC_CTL_SPEED_10;
 		break;
 	case 100:
-		ctrl = PORT_PCS_CTRL_SPEED_100;
+		ctrl = MV88E6XXX_PORT_MAC_CTL_SPEED_100;
 		break;
 	case 200:
 		if (alt_bit)
-			ctrl = PORT_PCS_CTRL_SPEED_100 | PORT_PCS_CTRL_ALTSPEED;
+			ctrl = MV88E6XXX_PORT_MAC_CTL_SPEED_100 |
+				MV88E6390_PORT_MAC_CTL_ALTSPEED;
 		else
-			ctrl = PORT_PCS_CTRL_SPEED_200;
+			ctrl = MV88E6065_PORT_MAC_CTL_SPEED_200;
 		break;
 	case 1000:
-		ctrl = PORT_PCS_CTRL_SPEED_1000;
+		ctrl = MV88E6XXX_PORT_MAC_CTL_SPEED_1000;
 		break;
 	case 2500:
-		ctrl = PORT_PCS_CTRL_SPEED_10000 | PORT_PCS_CTRL_ALTSPEED;
+		ctrl = MV88E6390_PORT_MAC_CTL_SPEED_10000 |
+			MV88E6390_PORT_MAC_CTL_ALTSPEED;
 		break;
 	case 10000:
 		/* all bits set, fall through... */
 	case SPEED_UNFORCED:
-		ctrl = PORT_PCS_CTRL_SPEED_UNFORCED;
+		ctrl = MV88E6XXX_PORT_MAC_CTL_SPEED_UNFORCED;
 		break;
 	default:
 		return -EOPNOTSUPP;
 	}
 
-	err = mv88e6xxx_port_read(chip, port, PORT_PCS_CTRL, &reg);
+	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_MAC_CTL, &reg);
 	if (err)
 		return err;
 
-	reg &= ~PORT_PCS_CTRL_SPEED_MASK;
+	reg &= ~MV88E6XXX_PORT_MAC_CTL_SPEED_MASK;
 	if (alt_bit)
-		reg &= ~PORT_PCS_CTRL_ALTSPEED;
+		reg &= ~MV88E6390_PORT_MAC_CTL_ALTSPEED;
 	if (force_bit) {
-		reg &= ~PORT_PCS_CTRL_FORCE_SPEED;
+		reg &= ~MV88E6390_PORT_MAC_CTL_FORCE_SPEED;
 		if (speed != SPEED_UNFORCED)
-			ctrl |= PORT_PCS_CTRL_FORCE_SPEED;
+			ctrl |= MV88E6390_PORT_MAC_CTL_FORCE_SPEED;
 	}
 	reg |= ctrl;
 
-	err = mv88e6xxx_port_write(chip, port, PORT_PCS_CTRL, reg);
+	err = mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_MAC_CTL, reg);
 	if (err)
 		return err;
 
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index be7cfd979e49..260096b34d2b 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -42,25 +42,27 @@
 #define MV88E6XXX_PORT_STS_CMODE_XAUI		0x000c
 #define MV88E6XXX_PORT_STS_CMODE_RXAUI		0x000d
 
-#define PORT_PCS_CTRL		0x01
-#define PORT_PCS_CTRL_RGMII_DELAY_RXCLK	BIT(15)
-#define PORT_PCS_CTRL_RGMII_DELAY_TXCLK	BIT(14)
-#define PORT_PCS_CTRL_FORCE_SPEED	BIT(13) /* 6390 */
-#define PORT_PCS_CTRL_ALTSPEED		BIT(12) /* 6390 */
-#define PORT_PCS_CTRL_200BASE		BIT(12) /* 6352 */
-#define PORT_PCS_CTRL_FC		BIT(7)
-#define PORT_PCS_CTRL_FORCE_FC		BIT(6)
-#define PORT_PCS_CTRL_LINK_UP		BIT(5)
-#define PORT_PCS_CTRL_FORCE_LINK	BIT(4)
-#define PORT_PCS_CTRL_DUPLEX_FULL	BIT(3)
-#define PORT_PCS_CTRL_FORCE_DUPLEX	BIT(2)
-#define PORT_PCS_CTRL_SPEED_MASK	(0x03)
-#define PORT_PCS_CTRL_SPEED_10		(0x00)
-#define PORT_PCS_CTRL_SPEED_100		(0x01)
-#define PORT_PCS_CTRL_SPEED_200		(0x02) /* 6065 and non Gb chips */
-#define PORT_PCS_CTRL_SPEED_1000	(0x02)
-#define PORT_PCS_CTRL_SPEED_10000	(0x03) /* 6390X */
-#define PORT_PCS_CTRL_SPEED_UNFORCED	(0x03)
+/* Offset 0x01: MAC (or PCS or Physical) Control Register */
+#define MV88E6XXX_PORT_MAC_CTL				0x01
+#define MV88E6XXX_PORT_MAC_CTL_RGMII_DELAY_RXCLK	0x8000
+#define MV88E6XXX_PORT_MAC_CTL_RGMII_DELAY_TXCLK	0x4000
+#define MV88E6390_PORT_MAC_CTL_FORCE_SPEED		0x2000
+#define MV88E6390_PORT_MAC_CTL_ALTSPEED			0x1000
+#define MV88E6352_PORT_MAC_CTL_200BASE			0x1000
+#define MV88E6XXX_PORT_MAC_CTL_FC			0x0080
+#define MV88E6XXX_PORT_MAC_CTL_FORCE_FC			0x0040
+#define MV88E6XXX_PORT_MAC_CTL_LINK_UP			0x0020
+#define MV88E6XXX_PORT_MAC_CTL_FORCE_LINK		0x0010
+#define MV88E6XXX_PORT_MAC_CTL_DUPLEX_FULL		0x0008
+#define MV88E6XXX_PORT_MAC_CTL_FORCE_DUPLEX		0x0004
+#define MV88E6XXX_PORT_MAC_CTL_SPEED_MASK		0x0003
+#define MV88E6XXX_PORT_MAC_CTL_SPEED_10			0x0000
+#define MV88E6XXX_PORT_MAC_CTL_SPEED_100		0x0001
+#define MV88E6065_PORT_MAC_CTL_SPEED_200		0x0002
+#define MV88E6XXX_PORT_MAC_CTL_SPEED_1000		0x0002
+#define MV88E6390_PORT_MAC_CTL_SPEED_10000		0x0003
+#define MV88E6XXX_PORT_MAC_CTL_SPEED_UNFORCED		0x0003
+
 #define PORT_PAUSE_CTRL		0x02
 #define PORT_FLOW_CTRL_LIMIT_IN		((0x00 << 8) | BIT(15))
 #define PORT_FLOW_CTRL_LIMIT_OUT	((0x01 << 8) | BIT(15))
-- 
2.13.1
