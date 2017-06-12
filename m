From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 01/13] net: dsa: mv88e6xxx: prefix Port Status macros
Date: Mon, 12 Jun 2017 12:37:33 -0400
Message-ID: <20170612163745.16868-2-vivien.didelot@savoirfairelinux.com>
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

For implicit namespacing and clarity, prefix the common Port Status
Register macros with MV88E6XXX_PORT_STS and the ones which differ
between implementations with a chosen reference model
(e.g. MV88E6352_PORT_STS_EEE.)

Document the register and prefer ordered hex masks values for all
Marvell 16-bit registers.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c   |  4 ++--
 drivers/net/dsa/mv88e6xxx/port.c   | 20 ++++++++--------
 drivers/net/dsa/mv88e6xxx/port.h   | 48 ++++++++++++++++++++------------------
 drivers/net/dsa/mv88e6xxx/serdes.c | 38 +++++++++++++++---------------
 4 files changed, 56 insertions(+), 54 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index a4cf0366765f..0a2bac1cde44 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -828,11 +828,11 @@ static int mv88e6xxx_get_eee(struct dsa_switch *ds, int port,
 	e->eee_enabled = !!(reg & 0x0200);
 	e->tx_lpi_enabled = !!(reg & 0x0100);
 
-	err = mv88e6xxx_port_read(chip, port, PORT_STATUS, &reg);
+	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_STS, &reg);
 	if (err)
 		goto out;
 
-	e->eee_active = !!(reg & PORT_STATUS_EEE);
+	e->eee_active = !!(reg & MV88E6352_PORT_STS_EEE);
 out:
 	mutex_unlock(&chip->reg_lock);
 
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index efeb8d6b02e6..906b9112e28c 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -322,33 +322,33 @@ int mv88e6390x_port_set_cmode(struct mv88e6xxx_chip *chip, int port,
 
 	switch (mode) {
 	case PHY_INTERFACE_MODE_1000BASEX:
-		cmode = PORT_STATUS_CMODE_1000BASE_X;
+		cmode = MV88E6XXX_PORT_STS_CMODE_1000BASE_X;
 		break;
 	case PHY_INTERFACE_MODE_SGMII:
-		cmode = PORT_STATUS_CMODE_SGMII;
+		cmode = MV88E6XXX_PORT_STS_CMODE_SGMII;
 		break;
 	case PHY_INTERFACE_MODE_2500BASEX:
-		cmode = PORT_STATUS_CMODE_2500BASEX;
+		cmode = MV88E6XXX_PORT_STS_CMODE_2500BASEX;
 		break;
 	case PHY_INTERFACE_MODE_XGMII:
-		cmode = PORT_STATUS_CMODE_XAUI;
+		cmode = MV88E6XXX_PORT_STS_CMODE_XAUI;
 		break;
 	case PHY_INTERFACE_MODE_RXAUI:
-		cmode = PORT_STATUS_CMODE_RXAUI;
+		cmode = MV88E6XXX_PORT_STS_CMODE_RXAUI;
 		break;
 	default:
 		cmode = 0;
 	}
 
 	if (cmode) {
-		err = mv88e6xxx_port_read(chip, port, PORT_STATUS, &reg);
+		err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_STS, &reg);
 		if (err)
 			return err;
 
-		reg &= ~PORT_STATUS_CMODE_MASK;
+		reg &= ~MV88E6XXX_PORT_STS_CMODE_MASK;
 		reg |= cmode;
 
-		err = mv88e6xxx_port_write(chip, port, PORT_STATUS, reg);
+		err = mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_STS, reg);
 		if (err)
 			return err;
 	}
@@ -361,11 +361,11 @@ int mv88e6xxx_port_get_cmode(struct mv88e6xxx_chip *chip, int port, u8 *cmode)
 	int err;
 	u16 reg;
 
-	err = mv88e6xxx_port_read(chip, port, PORT_STATUS, &reg);
+	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_STS, &reg);
 	if (err)
 		return err;
 
-	*cmode = reg & PORT_STATUS_CMODE_MASK;
+	*cmode = reg & MV88E6XXX_PORT_STS_CMODE_MASK;
 
 	return 0;
 }
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 8a59cabc20fa..be7cfd979e49 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -17,29 +17,31 @@
 
 #include "chip.h"
 
-#define PORT_STATUS		0x00
-#define PORT_STATUS_PAUSE_EN	BIT(15)
-#define PORT_STATUS_MY_PAUSE	BIT(14)
-#define PORT_STATUS_HD_FLOW	BIT(13)
-#define PORT_STATUS_PHY_DETECT	BIT(12)
-#define PORT_STATUS_LINK	BIT(11)
-#define PORT_STATUS_DUPLEX	BIT(10)
-#define PORT_STATUS_SPEED_MASK	0x0300
-#define PORT_STATUS_SPEED_10	0x0000
-#define PORT_STATUS_SPEED_100	0x0100
-#define PORT_STATUS_SPEED_1000	0x0200
-#define PORT_STATUS_EEE		BIT(6) /* 6352 */
-#define PORT_STATUS_AM_DIS	BIT(6) /* 6165 */
-#define PORT_STATUS_MGMII	BIT(6) /* 6185 */
-#define PORT_STATUS_TX_PAUSED	BIT(5)
-#define PORT_STATUS_FLOW_CTRL	BIT(4)
-#define PORT_STATUS_CMODE_MASK	0x0f
-#define PORT_STATUS_CMODE_100BASE_X	0x8
-#define PORT_STATUS_CMODE_1000BASE_X	0x9
-#define PORT_STATUS_CMODE_SGMII		0xa
-#define PORT_STATUS_CMODE_2500BASEX	0xb
-#define PORT_STATUS_CMODE_XAUI		0xc
-#define PORT_STATUS_CMODE_RXAUI		0xd
+/* Offset 0x00: Port Status Register */
+#define MV88E6XXX_PORT_STS			0x00
+#define MV88E6XXX_PORT_STS_PAUSE_EN		0x8000
+#define MV88E6XXX_PORT_STS_MY_PAUSE		0x4000
+#define MV88E6XXX_PORT_STS_HD_FLOW		0x2000
+#define MV88E6XXX_PORT_STS_PHY_DETECT		0x1000
+#define MV88E6XXX_PORT_STS_LINK			0x0800
+#define MV88E6XXX_PORT_STS_DUPLEX		0x0400
+#define MV88E6XXX_PORT_STS_SPEED_MASK		0x0300
+#define MV88E6XXX_PORT_STS_SPEED_10		0x0000
+#define MV88E6XXX_PORT_STS_SPEED_100		0x0100
+#define MV88E6XXX_PORT_STS_SPEED_1000		0x0200
+#define MV88E6352_PORT_STS_EEE			0x0040
+#define MV88E6165_PORT_STS_AM_DIS		0x0040
+#define MV88E6185_PORT_STS_MGMII		0x0040
+#define MV88E6XXX_PORT_STS_TX_PAUSED		0x0020
+#define MV88E6XXX_PORT_STS_FLOW_CTL		0x0010
+#define MV88E6XXX_PORT_STS_CMODE_MASK		0x000f
+#define MV88E6XXX_PORT_STS_CMODE_100BASE_X	0x0008
+#define MV88E6XXX_PORT_STS_CMODE_1000BASE_X	0x0009
+#define MV88E6XXX_PORT_STS_CMODE_SGMII		0x000a
+#define MV88E6XXX_PORT_STS_CMODE_2500BASEX	0x000b
+#define MV88E6XXX_PORT_STS_CMODE_XAUI		0x000c
+#define MV88E6XXX_PORT_STS_CMODE_RXAUI		0x000d
+
 #define PORT_PCS_CTRL		0x01
 #define PORT_PCS_CTRL_RGMII_DELAY_RXCLK	BIT(15)
 #define PORT_PCS_CTRL_RGMII_DELAY_TXCLK	BIT(14)
diff --git a/drivers/net/dsa/mv88e6xxx/serdes.c b/drivers/net/dsa/mv88e6xxx/serdes.c
index 78f5b1eb44ea..411b4f522792 100644
--- a/drivers/net/dsa/mv88e6xxx/serdes.c
+++ b/drivers/net/dsa/mv88e6xxx/serdes.c
@@ -64,9 +64,9 @@ int mv88e6352_serdes_power(struct mv88e6xxx_chip *chip, int port, bool on)
 	if (err)
 		return err;
 
-	if ((cmode == PORT_STATUS_CMODE_100BASE_X) ||
-	    (cmode == PORT_STATUS_CMODE_1000BASE_X) ||
-	    (cmode == PORT_STATUS_CMODE_SGMII)) {
+	if ((cmode == MV88E6XXX_PORT_STS_CMODE_100BASE_X) ||
+	    (cmode == MV88E6XXX_PORT_STS_CMODE_1000BASE_X) ||
+	    (cmode == MV88E6XXX_PORT_STS_CMODE_SGMII)) {
 		err = mv88e6352_serdes_power_set(chip, on);
 		if (err < 0)
 			return err;
@@ -139,15 +139,15 @@ static int mv88e6390_serdes_lower(struct mv88e6xxx_chip *chip, u8 cmode,
 		return err;
 
 	switch (cmode_donor) {
-	case PORT_STATUS_CMODE_RXAUI:
+	case MV88E6XXX_PORT_STS_CMODE_RXAUI:
 		if (!rxaui)
 			break;
 		/* Fall through */
-	case PORT_STATUS_CMODE_1000BASE_X:
-	case PORT_STATUS_CMODE_SGMII:
-	case PORT_STATUS_CMODE_2500BASEX:
-		if (cmode == PORT_STATUS_CMODE_1000BASE_X ||
-		    cmode == PORT_STATUS_CMODE_SGMII)
+	case MV88E6XXX_PORT_STS_CMODE_1000BASE_X:
+	case MV88E6XXX_PORT_STS_CMODE_SGMII:
+	case MV88E6XXX_PORT_STS_CMODE_2500BASEX:
+		if (cmode == MV88E6XXX_PORT_STS_CMODE_1000BASE_X ||
+		    cmode == MV88E6XXX_PORT_STS_CMODE_SGMII)
 			return	mv88e6390_serdes_sgmii(chip, lane, on);
 	}
 	return 0;
@@ -157,12 +157,12 @@ static int mv88e6390_serdes_port9(struct mv88e6xxx_chip *chip, u8 cmode,
 				  bool on)
 {
 	switch (cmode) {
-	case PORT_STATUS_CMODE_1000BASE_X:
-	case PORT_STATUS_CMODE_SGMII:
+	case MV88E6XXX_PORT_STS_CMODE_1000BASE_X:
+	case MV88E6XXX_PORT_STS_CMODE_SGMII:
 		return mv88e6390_serdes_sgmii(chip, MV88E6390_PORT9_LANE0, on);
-	case PORT_STATUS_CMODE_XAUI:
-	case PORT_STATUS_CMODE_RXAUI:
-	case PORT_STATUS_CMODE_2500BASEX:
+	case MV88E6XXX_PORT_STS_CMODE_XAUI:
+	case MV88E6XXX_PORT_STS_CMODE_RXAUI:
+	case MV88E6XXX_PORT_STS_CMODE_2500BASEX:
 		return mv88e6390_serdes_10g(chip, MV88E6390_PORT9_LANE0, on);
 	}
 
@@ -173,12 +173,12 @@ static int mv88e6390_serdes_port10(struct mv88e6xxx_chip *chip, u8 cmode,
 				   bool on)
 {
 	switch (cmode) {
-	case PORT_STATUS_CMODE_SGMII:
+	case MV88E6XXX_PORT_STS_CMODE_SGMII:
 		return mv88e6390_serdes_sgmii(chip, MV88E6390_PORT10_LANE0, on);
-	case PORT_STATUS_CMODE_XAUI:
-	case PORT_STATUS_CMODE_RXAUI:
-	case PORT_STATUS_CMODE_1000BASE_X:
-	case PORT_STATUS_CMODE_2500BASEX:
+	case MV88E6XXX_PORT_STS_CMODE_XAUI:
+	case MV88E6XXX_PORT_STS_CMODE_RXAUI:
+	case MV88E6XXX_PORT_STS_CMODE_1000BASE_X:
+	case MV88E6XXX_PORT_STS_CMODE_2500BASEX:
 		return mv88e6390_serdes_10g(chip, MV88E6390_PORT10_LANE0, on);
 	}
 
-- 
2.13.1
