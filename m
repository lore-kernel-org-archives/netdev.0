From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 05/13] net: dsa: mv88e6xxx: prefix Port Control macros
Date: Mon, 12 Jun 2017 12:37:37 -0400
Message-ID: <20170612163745.16868-6-vivien.didelot@savoirfairelinux.com>
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

For implicit namespacing and clarity, prefix the common Port Control
Register macros with MV88E6XXX_PORT_CTL0 and the ones which differ
between implementations with a chosen reference model
(e.g. MV88E6185_PORT_CTL0_USE_TAG.)

The reason for CTL0 is to make it clear between the badly named
"Port Control", "Port Control 1" and "Port Control 2" registers.

Document the register and prefer ordered hex masks values for all
Marvell 16-bit registers.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c |  8 ++--
 drivers/net/dsa/mv88e6xxx/port.c | 82 ++++++++++++++++++++--------------------
 drivers/net/dsa/mv88e6xxx/port.h | 66 ++++++++++++++++----------------
 3 files changed, 79 insertions(+), 77 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 7d0868a45cdc..b1a8cbe1c215 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1828,10 +1828,10 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	 * If this is the upstream port for this switch, enable
 	 * forwarding of unknown unicasts and multicasts.
 	 */
-	reg = PORT_CONTROL_IGMP_MLD_SNOOP |
-		PORT_CONTROL_USE_TAG | PORT_CONTROL_USE_IP |
-		PORT_CONTROL_STATE_FORWARDING;
-	err = mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
+	reg = MV88E6XXX_PORT_CTL0_IGMP_MLD_SNOOP |
+		MV88E6185_PORT_CTL0_USE_TAG | MV88E6185_PORT_CTL0_USE_IP |
+		MV88E6XXX_PORT_CTL0_STATE_FORWARDING;
+	err = mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_CTL0, reg);
 	if (err)
 		return err;
 
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 615b8843ad8e..a51d766b3c76 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -408,10 +408,10 @@ int mv88e6390_port_pause_limit(struct mv88e6xxx_chip *chip, int port, u8 in,
 /* Offset 0x04: Port Control Register */
 
 static const char * const mv88e6xxx_port_state_names[] = {
-	[PORT_CONTROL_STATE_DISABLED] = "Disabled",
-	[PORT_CONTROL_STATE_BLOCKING] = "Blocking/Listening",
-	[PORT_CONTROL_STATE_LEARNING] = "Learning",
-	[PORT_CONTROL_STATE_FORWARDING] = "Forwarding",
+	[MV88E6XXX_PORT_CTL0_STATE_DISABLED] = "Disabled",
+	[MV88E6XXX_PORT_CTL0_STATE_BLOCKING] = "Blocking/Listening",
+	[MV88E6XXX_PORT_CTL0_STATE_LEARNING] = "Learning",
+	[MV88E6XXX_PORT_CTL0_STATE_FORWARDING] = "Forwarding",
 };
 
 int mv88e6xxx_port_set_state(struct mv88e6xxx_chip *chip, int port, u8 state)
@@ -419,25 +419,25 @@ int mv88e6xxx_port_set_state(struct mv88e6xxx_chip *chip, int port, u8 state)
 	u16 reg;
 	int err;
 
-	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL, &reg);
+	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_CTL0, &reg);
 	if (err)
 		return err;
 
-	reg &= ~PORT_CONTROL_STATE_MASK;
+	reg &= ~MV88E6XXX_PORT_CTL0_STATE_MASK;
 
 	switch (state) {
 	case BR_STATE_DISABLED:
-		state = PORT_CONTROL_STATE_DISABLED;
+		state = MV88E6XXX_PORT_CTL0_STATE_DISABLED;
 		break;
 	case BR_STATE_BLOCKING:
 	case BR_STATE_LISTENING:
-		state = PORT_CONTROL_STATE_BLOCKING;
+		state = MV88E6XXX_PORT_CTL0_STATE_BLOCKING;
 		break;
 	case BR_STATE_LEARNING:
-		state = PORT_CONTROL_STATE_LEARNING;
+		state = MV88E6XXX_PORT_CTL0_STATE_LEARNING;
 		break;
 	case BR_STATE_FORWARDING:
-		state = PORT_CONTROL_STATE_FORWARDING;
+		state = MV88E6XXX_PORT_CTL0_STATE_FORWARDING;
 		break;
 	default:
 		return -EINVAL;
@@ -445,7 +445,7 @@ int mv88e6xxx_port_set_state(struct mv88e6xxx_chip *chip, int port, u8 state)
 
 	reg |= state;
 
-	err = mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
+	err = mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_CTL0, reg);
 	if (err)
 		return err;
 
@@ -461,30 +461,30 @@ int mv88e6xxx_port_set_egress_mode(struct mv88e6xxx_chip *chip, int port,
 	int err;
 	u16 reg;
 
-	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL, &reg);
+	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_CTL0, &reg);
 	if (err)
 		return err;
 
-	reg &= ~PORT_CONTROL_EGRESS_MASK;
+	reg &= ~MV88E6XXX_PORT_CTL0_EGRESS_MODE_MASK;
 
 	switch (mode) {
 	case MV88E6XXX_EGRESS_MODE_UNMODIFIED:
-		reg |= PORT_CONTROL_EGRESS_UNMODIFIED;
+		reg |= MV88E6XXX_PORT_CTL0_EGRESS_MODE_UNMODIFIED;
 		break;
 	case MV88E6XXX_EGRESS_MODE_UNTAGGED:
-		reg |= PORT_CONTROL_EGRESS_UNTAGGED;
+		reg |= MV88E6XXX_PORT_CTL0_EGRESS_MODE_UNTAGGED;
 		break;
 	case MV88E6XXX_EGRESS_MODE_TAGGED:
-		reg |= PORT_CONTROL_EGRESS_TAGGED;
+		reg |= MV88E6XXX_PORT_CTL0_EGRESS_MODE_TAGGED;
 		break;
 	case MV88E6XXX_EGRESS_MODE_ETHERTYPE:
-		reg |= PORT_CONTROL_EGRESS_ADD_TAG;
+		reg |= MV88E6XXX_PORT_CTL0_EGRESS_MODE_ETHER_TYPE_DSA;
 		break;
 	default:
 		return -EINVAL;
 	}
 
-	return mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
+	return mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_CTL0, reg);
 }
 
 int mv88e6085_port_set_frame_mode(struct mv88e6xxx_chip *chip, int port,
@@ -493,24 +493,24 @@ int mv88e6085_port_set_frame_mode(struct mv88e6xxx_chip *chip, int port,
 	int err;
 	u16 reg;
 
-	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL, &reg);
+	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_CTL0, &reg);
 	if (err)
 		return err;
 
-	reg &= ~PORT_CONTROL_FRAME_MASK;
+	reg &= ~MV88E6XXX_PORT_CTL0_FRAME_MODE_MASK;
 
 	switch (mode) {
 	case MV88E6XXX_FRAME_MODE_NORMAL:
-		reg |= PORT_CONTROL_FRAME_MODE_NORMAL;
+		reg |= MV88E6XXX_PORT_CTL0_FRAME_MODE_NORMAL;
 		break;
 	case MV88E6XXX_FRAME_MODE_DSA:
-		reg |= PORT_CONTROL_FRAME_MODE_DSA;
+		reg |= MV88E6XXX_PORT_CTL0_FRAME_MODE_DSA;
 		break;
 	default:
 		return -EINVAL;
 	}
 
-	return mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
+	return mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_CTL0, reg);
 }
 
 int mv88e6351_port_set_frame_mode(struct mv88e6xxx_chip *chip, int port,
@@ -519,30 +519,30 @@ int mv88e6351_port_set_frame_mode(struct mv88e6xxx_chip *chip, int port,
 	int err;
 	u16 reg;
 
-	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL, &reg);
+	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_CTL0, &reg);
 	if (err)
 		return err;
 
-	reg &= ~PORT_CONTROL_FRAME_MASK;
+	reg &= ~MV88E6XXX_PORT_CTL0_FRAME_MODE_MASK;
 
 	switch (mode) {
 	case MV88E6XXX_FRAME_MODE_NORMAL:
-		reg |= PORT_CONTROL_FRAME_MODE_NORMAL;
+		reg |= MV88E6XXX_PORT_CTL0_FRAME_MODE_NORMAL;
 		break;
 	case MV88E6XXX_FRAME_MODE_DSA:
-		reg |= PORT_CONTROL_FRAME_MODE_DSA;
+		reg |= MV88E6XXX_PORT_CTL0_FRAME_MODE_DSA;
 		break;
 	case MV88E6XXX_FRAME_MODE_PROVIDER:
-		reg |= PORT_CONTROL_FRAME_MODE_PROVIDER;
+		reg |= MV88E6XXX_PORT_CTL0_FRAME_MODE_PROVIDER;
 		break;
 	case MV88E6XXX_FRAME_MODE_ETHERTYPE:
-		reg |= PORT_CONTROL_FRAME_ETHER_TYPE_DSA;
+		reg |= MV88E6XXX_PORT_CTL0_FRAME_MODE_ETHER_TYPE_DSA;
 		break;
 	default:
 		return -EINVAL;
 	}
 
-	return mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
+	return mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_CTL0, reg);
 }
 
 static int mv88e6185_port_set_forward_unknown(struct mv88e6xxx_chip *chip,
@@ -551,16 +551,16 @@ static int mv88e6185_port_set_forward_unknown(struct mv88e6xxx_chip *chip,
 	int err;
 	u16 reg;
 
-	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL, &reg);
+	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_CTL0, &reg);
 	if (err)
 		return err;
 
 	if (unicast)
-		reg |= PORT_CONTROL_FORWARD_UNKNOWN;
+		reg |= MV88E6185_PORT_CTL0_FORWARD_UNKNOWN;
 	else
-		reg &= ~PORT_CONTROL_FORWARD_UNKNOWN;
+		reg &= ~MV88E6185_PORT_CTL0_FORWARD_UNKNOWN;
 
-	return mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
+	return mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_CTL0, reg);
 }
 
 int mv88e6352_port_set_egress_floods(struct mv88e6xxx_chip *chip, int port,
@@ -569,22 +569,22 @@ int mv88e6352_port_set_egress_floods(struct mv88e6xxx_chip *chip, int port,
 	int err;
 	u16 reg;
 
-	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL, &reg);
+	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_CTL0, &reg);
 	if (err)
 		return err;
 
-	reg &= ~PORT_CONTROL_EGRESS_FLOODS_MASK;
+	reg &= ~MV88E6352_PORT_CTL0_EGRESS_FLOODS_MASK;
 
 	if (unicast && multicast)
-		reg |= PORT_CONTROL_EGRESS_FLOODS_ALL_UNKNOWN_DA;
+		reg |= MV88E6352_PORT_CTL0_EGRESS_FLOODS_ALL_UNKNOWN_DA;
 	else if (unicast)
-		reg |= PORT_CONTROL_EGRESS_FLOODS_NO_UNKNOWN_MC_DA;
+		reg |= MV88E6352_PORT_CTL0_EGRESS_FLOODS_NO_UNKNOWN_MC_DA;
 	else if (multicast)
-		reg |= PORT_CONTROL_EGRESS_FLOODS_NO_UNKNOWN_UC_DA;
+		reg |= MV88E6352_PORT_CTL0_EGRESS_FLOODS_NO_UNKNOWN_UC_DA;
 	else
-		reg |= PORT_CONTROL_EGRESS_FLOODS_NO_UNKNOWN_DA;
+		reg |= MV88E6352_PORT_CTL0_EGRESS_FLOODS_NO_UNKNOWN_DA;
 
-	return mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
+	return mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_CTL0, reg);
 }
 
 /* Offset 0x05: Port Control 1 */
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index dc99c3159038..880f1b117248 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -107,38 +107,40 @@
 #define MV88E6XXX_PORT_SWITCH_ID_PROD_6390	0x3900
 #define MV88E6XXX_PORT_SWITCH_ID_REV_MASK	0x000f
 
-#define PORT_CONTROL		0x04
-#define PORT_CONTROL_USE_CORE_TAG	BIT(15)
-#define PORT_CONTROL_DROP_ON_LOCK	BIT(14)
-#define PORT_CONTROL_EGRESS_UNMODIFIED	(0x0 << 12)
-#define PORT_CONTROL_EGRESS_UNTAGGED	(0x1 << 12)
-#define PORT_CONTROL_EGRESS_TAGGED	(0x2 << 12)
-#define PORT_CONTROL_EGRESS_ADD_TAG	(0x3 << 12)
-#define PORT_CONTROL_EGRESS_MASK	(0x3 << 12)
-#define PORT_CONTROL_HEADER		BIT(11)
-#define PORT_CONTROL_IGMP_MLD_SNOOP	BIT(10)
-#define PORT_CONTROL_DOUBLE_TAG		BIT(9)
-#define PORT_CONTROL_FRAME_MODE_NORMAL		(0x0 << 8)
-#define PORT_CONTROL_FRAME_MODE_DSA		(0x1 << 8)
-#define PORT_CONTROL_FRAME_MODE_PROVIDER	(0x2 << 8)
-#define PORT_CONTROL_FRAME_ETHER_TYPE_DSA	(0x3 << 8)
-#define PORT_CONTROL_FRAME_MASK			(0x3 << 8)
-#define PORT_CONTROL_DSA_TAG		BIT(8)
-#define PORT_CONTROL_VLAN_TUNNEL	BIT(7)
-#define PORT_CONTROL_TAG_IF_BOTH	BIT(6)
-#define PORT_CONTROL_USE_IP		BIT(5)
-#define PORT_CONTROL_USE_TAG		BIT(4)
-#define PORT_CONTROL_FORWARD_UNKNOWN	BIT(2)
-#define PORT_CONTROL_EGRESS_FLOODS_MASK			(0x3 << 2)
-#define PORT_CONTROL_EGRESS_FLOODS_NO_UNKNOWN_DA	(0x0 << 2)
-#define PORT_CONTROL_EGRESS_FLOODS_NO_UNKNOWN_MC_DA	(0x1 << 2)
-#define PORT_CONTROL_EGRESS_FLOODS_NO_UNKNOWN_UC_DA	(0x2 << 2)
-#define PORT_CONTROL_EGRESS_FLOODS_ALL_UNKNOWN_DA	(0x3 << 2)
-#define PORT_CONTROL_STATE_MASK		0x03
-#define PORT_CONTROL_STATE_DISABLED	0x00
-#define PORT_CONTROL_STATE_BLOCKING	0x01
-#define PORT_CONTROL_STATE_LEARNING	0x02
-#define PORT_CONTROL_STATE_FORWARDING	0x03
+/* Offset 0x04: Port Control Register */
+#define MV88E6XXX_PORT_CTL0					0x04
+#define MV88E6XXX_PORT_CTL0_USE_CORE_TAG			0x8000
+#define MV88E6XXX_PORT_CTL0_DROP_ON_LOCK			0x4000
+#define MV88E6XXX_PORT_CTL0_EGRESS_MODE_MASK			0x3000
+#define MV88E6XXX_PORT_CTL0_EGRESS_MODE_UNMODIFIED		0x0000
+#define MV88E6XXX_PORT_CTL0_EGRESS_MODE_UNTAGGED		0x1000
+#define MV88E6XXX_PORT_CTL0_EGRESS_MODE_TAGGED			0x2000
+#define MV88E6XXX_PORT_CTL0_EGRESS_MODE_ETHER_TYPE_DSA		0x3000
+#define MV88E6XXX_PORT_CTL0_HEADER				0x0800
+#define MV88E6XXX_PORT_CTL0_IGMP_MLD_SNOOP			0x0400
+#define MV88E6XXX_PORT_CTL0_DOUBLE_TAG				0x0200
+#define MV88E6XXX_PORT_CTL0_FRAME_MODE_MASK			0x0300
+#define MV88E6XXX_PORT_CTL0_FRAME_MODE_NORMAL			0x0000
+#define MV88E6XXX_PORT_CTL0_FRAME_MODE_DSA			0x0100
+#define MV88E6XXX_PORT_CTL0_FRAME_MODE_PROVIDER			0x0200
+#define MV88E6XXX_PORT_CTL0_FRAME_MODE_ETHER_TYPE_DSA		0x0300
+#define MV88E6XXX_PORT_CTL0_DSA_TAG				0x0100
+#define MV88E6XXX_PORT_CTL0_VLAN_TUNNEL				0x0080
+#define MV88E6XXX_PORT_CTL0_TAG_IF_BOTH				0x0040
+#define MV88E6185_PORT_CTL0_USE_IP				0x0020
+#define MV88E6185_PORT_CTL0_USE_TAG				0x0010
+#define MV88E6185_PORT_CTL0_FORWARD_UNKNOWN			0x0004
+#define MV88E6352_PORT_CTL0_EGRESS_FLOODS_MASK			0x000c
+#define MV88E6352_PORT_CTL0_EGRESS_FLOODS_NO_UNKNOWN_DA		0x0000
+#define MV88E6352_PORT_CTL0_EGRESS_FLOODS_NO_UNKNOWN_MC_DA	0x0004
+#define MV88E6352_PORT_CTL0_EGRESS_FLOODS_NO_UNKNOWN_UC_DA	0x0008
+#define MV88E6352_PORT_CTL0_EGRESS_FLOODS_ALL_UNKNOWN_DA	0x000c
+#define MV88E6XXX_PORT_CTL0_STATE_MASK				0x0003
+#define MV88E6XXX_PORT_CTL0_STATE_DISABLED			0x0000
+#define MV88E6XXX_PORT_CTL0_STATE_BLOCKING			0x0001
+#define MV88E6XXX_PORT_CTL0_STATE_LEARNING			0x0002
+#define MV88E6XXX_PORT_CTL0_STATE_FORWARDING			0x0003
+
 #define PORT_CONTROL_1		0x05
 #define PORT_CONTROL_1_MESSAGE_PORT	BIT(15)
 #define PORT_CONTROL_1_FID_11_4_MASK	(0xff << 0)
-- 
2.13.1
