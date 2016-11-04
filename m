From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 07/11] net: dsa: mv88e6xxx: add port link setter
Date: Fri,  4 Nov 2016 03:23:32 +0100
Message-ID: <20161104022336.14273-8-vivien.didelot@savoirfairelinux.com>
References: <20161104022336.14273-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161104022336.14273-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Most of the chips will have a port register control bits to force the
port's link up, down, or let normal link detection occurs.

Implement such operation to use it later when setting duplex, etc.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 17 +++++++++++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 10 +++++++++
 drivers/net/dsa/mv88e6xxx/port.c      | 41 +++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h      |  2 ++
 4 files changed, 70 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 181d3b9..cc43e6f 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3160,42 +3160,49 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.set_switch_mac = mv88e6xxx_g1_set_switch_mac,
 	.phy_read = mv88e6xxx_phy_ppu_read,
 	.phy_write = mv88e6xxx_phy_ppu_write,
+	.port_set_link = mv88e6xxx_port_set_link,
 };
 
 static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.set_switch_mac = mv88e6xxx_g1_set_switch_mac,
 	.phy_read = mv88e6xxx_phy_ppu_read,
 	.phy_write = mv88e6xxx_phy_ppu_write,
+	.port_set_link = mv88e6xxx_port_set_link,
 };
 
 static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_read,
 	.phy_write = mv88e6xxx_write,
+	.port_set_link = mv88e6xxx_port_set_link,
 };
 
 static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.set_switch_mac = mv88e6xxx_g1_set_switch_mac,
 	.phy_read = mv88e6xxx_phy_ppu_read,
 	.phy_write = mv88e6xxx_phy_ppu_write,
+	.port_set_link = mv88e6xxx_port_set_link,
 };
 
 static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_read,
 	.phy_write = mv88e6xxx_write,
+	.port_set_link = mv88e6xxx_port_set_link,
 };
 
 static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_read,
 	.phy_write = mv88e6xxx_write,
+	.port_set_link = mv88e6xxx_port_set_link,
 };
 
 static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.port_set_link = mv88e6xxx_port_set_link,
 };
 
 static const struct mv88e6xxx_ops mv88e6172_ops = {
@@ -3204,12 +3211,14 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.port_set_link = mv88e6xxx_port_set_link,
 };
 
 static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.port_set_link = mv88e6xxx_port_set_link,
 };
 
 static const struct mv88e6xxx_ops mv88e6176_ops = {
@@ -3218,12 +3227,14 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.port_set_link = mv88e6xxx_port_set_link,
 };
 
 static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.set_switch_mac = mv88e6xxx_g1_set_switch_mac,
 	.phy_read = mv88e6xxx_phy_ppu_read,
 	.phy_write = mv88e6xxx_phy_ppu_write,
+	.port_set_link = mv88e6xxx_port_set_link,
 };
 
 static const struct mv88e6xxx_ops mv88e6240_ops = {
@@ -3232,6 +3243,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.port_set_link = mv88e6xxx_port_set_link,
 };
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
@@ -3240,6 +3252,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.port_set_link = mv88e6xxx_port_set_link,
 };
 
 static const struct mv88e6xxx_ops mv88e6321_ops = {
@@ -3248,18 +3261,21 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.port_set_link = mv88e6xxx_port_set_link,
 };
 
 static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.port_set_link = mv88e6xxx_port_set_link,
 };
 
 static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.port_set_link = mv88e6xxx_port_set_link,
 };
 
 static const struct mv88e6xxx_ops mv88e6352_ops = {
@@ -3268,6 +3284,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.port_set_link = mv88e6xxx_port_set_link,
 };
 
 static const struct mv88e6xxx_info mv88e6xxx_table[] = {
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 6f48e58..474d16d 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -727,6 +727,16 @@ struct mv88e6xxx_ops {
 			u16 *val);
 	int (*phy_write)(struct mv88e6xxx_chip *chip, int addr, int reg,
 			 u16 val);
+
+#define LINK_FORCED_DOWN	0
+#define LINK_FORCED_UP		1
+#define LINK_UNFORCED		-2
+
+	/* Port's MAC link state
+	 * Use LINK_FORCED_UP or LINK_FORCED_DOWN to force link up or down,
+	 * or LINK_UNFORCED for normal link detection.
+	 */
+	int (*port_set_link)(struct mv88e6xxx_chip *chip, int port, int link);
 };
 
 enum stat_type {
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 53d17e6..09e25f9 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -30,6 +30,47 @@ int mv88e6xxx_port_write(struct mv88e6xxx_chip *chip, int port, int reg,
 	return mv88e6xxx_write(chip, addr, reg, val);
 }
 
+/* Offset 0x01: MAC (or PCS or Physical) Control Register
+ *
+ * Link, Duplex and Flow Control have one force bit, one value bit.
+ */
+
+int mv88e6xxx_port_set_link(struct mv88e6xxx_chip *chip, int port, int link)
+{
+	u16 reg;
+	int err;
+
+	err = mv88e6xxx_port_read(chip, port, PORT_PCS_CTRL, &reg);
+	if (err)
+		return err;
+
+	reg &= ~(PORT_PCS_CTRL_FORCE_LINK | PORT_PCS_CTRL_LINK_UP);
+
+	switch (link) {
+	case LINK_FORCED_DOWN:
+		reg |= PORT_PCS_CTRL_FORCE_LINK;
+		break;
+	case LINK_FORCED_UP:
+		reg |= PORT_PCS_CTRL_FORCE_LINK | PORT_PCS_CTRL_LINK_UP;
+		break;
+	case LINK_UNFORCED:
+		/* normal link detection */
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	err = mv88e6xxx_port_write(chip, port, PORT_PCS_CTRL, reg);
+	if (err)
+		return err;
+
+	netdev_dbg(chip->ds->ports[port].netdev, "%s link %s\n",
+		   reg & PORT_PCS_CTRL_FORCE_LINK ? "Force" : "Unforce",
+		   reg & PORT_PCS_CTRL_LINK_UP ? "up" : "down");
+
+	return 0;
+}
+
 /* Offset 0x04: Port Control Register */
 
 static const char * const mv88e6xxx_port_state_names[] = {
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 921eecf..87e7249 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -21,6 +21,8 @@ int mv88e6xxx_port_read(struct mv88e6xxx_chip *chip, int port, int reg,
 int mv88e6xxx_port_write(struct mv88e6xxx_chip *chip, int port, int reg,
 			 u16 val);
 
+int mv88e6xxx_port_set_link(struct mv88e6xxx_chip *chip, int port, int link);
+
 int mv88e6xxx_port_set_state(struct mv88e6xxx_chip *chip, int port, u8 state);
 
 int mv88e6xxx_port_set_vlan_map(struct mv88e6xxx_chip *chip, int port, u16 map);
-- 
2.10.2
