From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 09/13] net: dsa: mv88e6xxx: prefix Port Control 2 macros
Date: Mon, 12 Jun 2017 12:37:41 -0400
Message-ID: <20170612163745.16868-10-vivien.didelot@savoirfairelinux.com>
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

For implicit namespacing and clarity, prefix the common Port Control 2
Register macros with MV88E6XXX_PORT_CTL2 and the ones which differ
between implementations with a chosen reference model
(e.g. MV88E6095_PORT_CTL2_CPU_PORT_MASK.)

Document the register and prefer ordered hex masks values for all
Marvell 16-bit registers.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c |  6 ++---
 drivers/net/dsa/mv88e6xxx/port.c | 48 ++++++++++++++++++++--------------------
 drivers/net/dsa/mv88e6xxx/port.h | 44 ++++++++++++++++++------------------
 3 files changed, 50 insertions(+), 48 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 937a43d37f37..efc57003b9ee 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1213,8 +1213,8 @@ static int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
 					 bool vlan_filtering)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
-	u16 mode = vlan_filtering ? PORT_CONTROL_2_8021Q_SECURE :
-		PORT_CONTROL_2_8021Q_DISABLED;
+	u16 mode = vlan_filtering ? MV88E6XXX_PORT_CTL2_8021Q_MODE_SECURE :
+		MV88E6XXX_PORT_CTL2_8021Q_MODE_DISABLED;
 	int err;
 
 	if (!chip->info->max_vid)
@@ -1872,7 +1872,7 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	}
 
 	err = mv88e6xxx_port_set_8021q_mode(chip, port,
-					    PORT_CONTROL_2_8021Q_DISABLED);
+				MV88E6XXX_PORT_CTL2_8021Q_MODE_DISABLED);
 	if (err)
 		return err;
 
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 77e4048962d1..ad86b2e30ac5 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -742,10 +742,10 @@ int mv88e6xxx_port_set_pvid(struct mv88e6xxx_chip *chip, int port, u16 pvid)
 /* Offset 0x08: Port Control 2 Register */
 
 static const char * const mv88e6xxx_port_8021q_mode_names[] = {
-	[PORT_CONTROL_2_8021Q_DISABLED] = "Disabled",
-	[PORT_CONTROL_2_8021Q_FALLBACK] = "Fallback",
-	[PORT_CONTROL_2_8021Q_CHECK] = "Check",
-	[PORT_CONTROL_2_8021Q_SECURE] = "Secure",
+	[MV88E6XXX_PORT_CTL2_8021Q_MODE_DISABLED] = "Disabled",
+	[MV88E6XXX_PORT_CTL2_8021Q_MODE_FALLBACK] = "Fallback",
+	[MV88E6XXX_PORT_CTL2_8021Q_MODE_CHECK] = "Check",
+	[MV88E6XXX_PORT_CTL2_8021Q_MODE_SECURE] = "Secure",
 };
 
 static int mv88e6185_port_set_default_forward(struct mv88e6xxx_chip *chip,
@@ -754,16 +754,16 @@ static int mv88e6185_port_set_default_forward(struct mv88e6xxx_chip *chip,
 	int err;
 	u16 reg;
 
-	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL_2, &reg);
+	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_CTL2, &reg);
 	if (err)
 		return err;
 
 	if (multicast)
-		reg |= PORT_CONTROL_2_DEFAULT_FORWARD;
+		reg |= MV88E6XXX_PORT_CTL2_DEFAULT_FORWARD;
 	else
-		reg &= ~PORT_CONTROL_2_DEFAULT_FORWARD;
+		reg &= ~MV88E6XXX_PORT_CTL2_DEFAULT_FORWARD;
 
-	return mv88e6xxx_port_write(chip, port, PORT_CONTROL_2, reg);
+	return mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_CTL2, reg);
 }
 
 int mv88e6185_port_set_egress_floods(struct mv88e6xxx_chip *chip, int port,
@@ -784,14 +784,14 @@ int mv88e6095_port_set_upstream_port(struct mv88e6xxx_chip *chip, int port,
 	int err;
 	u16 reg;
 
-	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL_2, &reg);
+	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_CTL2, &reg);
 	if (err)
 		return err;
 
-	reg &= ~PORT_CONTROL_2_UPSTREAM_MASK;
+	reg &= ~MV88E6095_PORT_CTL2_CPU_PORT_MASK;
 	reg |= upstream_port;
 
-	return mv88e6xxx_port_write(chip, port, PORT_CONTROL_2, reg);
+	return mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_CTL2, reg);
 }
 
 int mv88e6xxx_port_set_8021q_mode(struct mv88e6xxx_chip *chip, int port,
@@ -800,14 +800,14 @@ int mv88e6xxx_port_set_8021q_mode(struct mv88e6xxx_chip *chip, int port,
 	u16 reg;
 	int err;
 
-	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL_2, &reg);
+	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_CTL2, &reg);
 	if (err)
 		return err;
 
-	reg &= ~PORT_CONTROL_2_8021Q_MASK;
-	reg |= mode & PORT_CONTROL_2_8021Q_MASK;
+	reg &= ~MV88E6XXX_PORT_CTL2_8021Q_MODE_MASK;
+	reg |= mode & MV88E6XXX_PORT_CTL2_8021Q_MODE_MASK;
 
-	err = mv88e6xxx_port_write(chip, port, PORT_CONTROL_2, reg);
+	err = mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_CTL2, reg);
 	if (err)
 		return err;
 
@@ -822,13 +822,13 @@ int mv88e6xxx_port_set_map_da(struct mv88e6xxx_chip *chip, int port)
 	u16 reg;
 	int err;
 
-	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL_2, &reg);
+	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_CTL2, &reg);
 	if (err)
 		return err;
 
-	reg |= PORT_CONTROL_2_MAP_DA;
+	reg |= MV88E6XXX_PORT_CTL2_MAP_DA;
 
-	return mv88e6xxx_port_write(chip, port, PORT_CONTROL_2, reg);
+	return mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_CTL2, reg);
 }
 
 int mv88e6165_port_set_jumbo_size(struct mv88e6xxx_chip *chip, int port,
@@ -837,22 +837,22 @@ int mv88e6165_port_set_jumbo_size(struct mv88e6xxx_chip *chip, int port,
 	u16 reg;
 	int err;
 
-	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL_2, &reg);
+	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_CTL2, &reg);
 	if (err)
 		return err;
 
-	reg &= ~PORT_CONTROL_2_JUMBO_MASK;
+	reg &= ~MV88E6XXX_PORT_CTL2_JUMBO_MODE_MASK;
 
 	if (size <= 1522)
-		reg |= PORT_CONTROL_2_JUMBO_1522;
+		reg |= MV88E6XXX_PORT_CTL2_JUMBO_MODE_1522;
 	else if (size <= 2048)
-		reg |= PORT_CONTROL_2_JUMBO_2048;
+		reg |= MV88E6XXX_PORT_CTL2_JUMBO_MODE_2048;
 	else if (size <= 10240)
-		reg |= PORT_CONTROL_2_JUMBO_10240;
+		reg |= MV88E6XXX_PORT_CTL2_JUMBO_MODE_10240;
 	else
 		return -ERANGE;
 
-	return mv88e6xxx_port_write(chip, port, PORT_CONTROL_2, reg);
+	return mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_CTL2, reg);
 }
 
 /* Offset 0x09: Port Rate Control */
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 44ac1327e9a2..ce236f06db6d 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -154,27 +154,29 @@
 #define MV88E6XXX_PORT_DEFAULT_VLAN		0x07
 #define MV88E6XXX_PORT_DEFAULT_VLAN_MASK	0x0fff
 
-#define PORT_CONTROL_2		0x08
-#define PORT_CONTROL_2_IGNORE_FCS	BIT(15)
-#define PORT_CONTROL_2_VTU_PRI_OVERRIDE	BIT(14)
-#define PORT_CONTROL_2_SA_PRIO_OVERRIDE	BIT(13)
-#define PORT_CONTROL_2_DA_PRIO_OVERRIDE	BIT(12)
-#define PORT_CONTROL_2_JUMBO_MASK	(0x03 << 12)
-#define PORT_CONTROL_2_JUMBO_1522	(0x00 << 12)
-#define PORT_CONTROL_2_JUMBO_2048	(0x01 << 12)
-#define PORT_CONTROL_2_JUMBO_10240	(0x02 << 12)
-#define PORT_CONTROL_2_8021Q_MASK	(0x03 << 10)
-#define PORT_CONTROL_2_8021Q_DISABLED	(0x00 << 10)
-#define PORT_CONTROL_2_8021Q_FALLBACK	(0x01 << 10)
-#define PORT_CONTROL_2_8021Q_CHECK	(0x02 << 10)
-#define PORT_CONTROL_2_8021Q_SECURE	(0x03 << 10)
-#define PORT_CONTROL_2_DISCARD_TAGGED	BIT(9)
-#define PORT_CONTROL_2_DISCARD_UNTAGGED	BIT(8)
-#define PORT_CONTROL_2_MAP_DA		BIT(7)
-#define PORT_CONTROL_2_DEFAULT_FORWARD	BIT(6)
-#define PORT_CONTROL_2_EGRESS_MONITOR	BIT(5)
-#define PORT_CONTROL_2_INGRESS_MONITOR	BIT(4)
-#define PORT_CONTROL_2_UPSTREAM_MASK	0x0f
+/* Offset 0x08: Port Control 2 Register */
+#define MV88E6XXX_PORT_CTL2				0x08
+#define MV88E6XXX_PORT_CTL2_IGNORE_FCS			0x8000
+#define MV88E6XXX_PORT_CTL2_VTU_PRI_OVERRIDE		0x4000
+#define MV88E6XXX_PORT_CTL2_SA_PRIO_OVERRIDE		0x2000
+#define MV88E6XXX_PORT_CTL2_DA_PRIO_OVERRIDE		0x1000
+#define MV88E6XXX_PORT_CTL2_JUMBO_MODE_MASK		0x3000
+#define MV88E6XXX_PORT_CTL2_JUMBO_MODE_1522		0x0000
+#define MV88E6XXX_PORT_CTL2_JUMBO_MODE_2048		0x1000
+#define MV88E6XXX_PORT_CTL2_JUMBO_MODE_10240		0x2000
+#define MV88E6XXX_PORT_CTL2_8021Q_MODE_MASK		0x0c00
+#define MV88E6XXX_PORT_CTL2_8021Q_MODE_DISABLED		0x0000
+#define MV88E6XXX_PORT_CTL2_8021Q_MODE_FALLBACK		0x0400
+#define MV88E6XXX_PORT_CTL2_8021Q_MODE_CHECK		0x0800
+#define MV88E6XXX_PORT_CTL2_8021Q_MODE_SECURE		0x0c00
+#define MV88E6XXX_PORT_CTL2_DISCARD_TAGGED		0x0200
+#define MV88E6XXX_PORT_CTL2_DISCARD_UNTAGGED		0x0100
+#define MV88E6XXX_PORT_CTL2_MAP_DA			0x0080
+#define MV88E6XXX_PORT_CTL2_DEFAULT_FORWARD		0x0040
+#define MV88E6XXX_PORT_CTL2_EGRESS_MONITOR		0x0020
+#define MV88E6XXX_PORT_CTL2_INGRESS_MONITOR		0x0010
+#define MV88E6095_PORT_CTL2_CPU_PORT_MASK		0x000f
+
 #define PORT_RATE_CONTROL	0x09
 #define PORT_RATE_CONTROL_2	0x0a
 #define PORT_ASSOC_VECTOR	0x0b
-- 
2.13.1
