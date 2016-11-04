From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 08/11] net: dsa: mv88e6xxx: add port duplex setter
Date: Fri,  4 Nov 2016 03:23:33 +0100
Message-ID: <20161104022336.14273-9-vivien.didelot@savoirfairelinux.com>
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

Similarly to port's link, add setter to force port's half duplex, full
duplex or let normal duplex detection occurs.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 17 +++++++++++++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  9 +++++++++
 drivers/net/dsa/mv88e6xxx/port.c      | 36 +++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h      |  2 ++
 4 files changed, 64 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index cc43e6f..49a6935 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3161,6 +3161,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.phy_read = mv88e6xxx_phy_ppu_read,
 	.phy_write = mv88e6xxx_phy_ppu_write,
 	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
 };
 
 static const struct mv88e6xxx_ops mv88e6095_ops = {
@@ -3168,6 +3169,7 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.phy_read = mv88e6xxx_phy_ppu_read,
 	.phy_write = mv88e6xxx_phy_ppu_write,
 	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
 };
 
 static const struct mv88e6xxx_ops mv88e6123_ops = {
@@ -3175,6 +3177,7 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.phy_read = mv88e6xxx_read,
 	.phy_write = mv88e6xxx_write,
 	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
 };
 
 static const struct mv88e6xxx_ops mv88e6131_ops = {
@@ -3182,6 +3185,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.phy_read = mv88e6xxx_phy_ppu_read,
 	.phy_write = mv88e6xxx_phy_ppu_write,
 	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
 };
 
 static const struct mv88e6xxx_ops mv88e6161_ops = {
@@ -3189,6 +3193,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.phy_read = mv88e6xxx_read,
 	.phy_write = mv88e6xxx_write,
 	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
 };
 
 static const struct mv88e6xxx_ops mv88e6165_ops = {
@@ -3196,6 +3201,7 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.phy_read = mv88e6xxx_read,
 	.phy_write = mv88e6xxx_write,
 	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
 };
 
 static const struct mv88e6xxx_ops mv88e6171_ops = {
@@ -3203,6 +3209,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
 };
 
 static const struct mv88e6xxx_ops mv88e6172_ops = {
@@ -3212,6 +3219,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
 };
 
 static const struct mv88e6xxx_ops mv88e6175_ops = {
@@ -3219,6 +3227,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
 };
 
 static const struct mv88e6xxx_ops mv88e6176_ops = {
@@ -3228,6 +3237,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
 };
 
 static const struct mv88e6xxx_ops mv88e6185_ops = {
@@ -3235,6 +3245,7 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.phy_read = mv88e6xxx_phy_ppu_read,
 	.phy_write = mv88e6xxx_phy_ppu_write,
 	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
 };
 
 static const struct mv88e6xxx_ops mv88e6240_ops = {
@@ -3244,6 +3255,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
 };
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
@@ -3253,6 +3265,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
 };
 
 static const struct mv88e6xxx_ops mv88e6321_ops = {
@@ -3262,6 +3275,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
 };
 
 static const struct mv88e6xxx_ops mv88e6350_ops = {
@@ -3269,6 +3283,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
 };
 
 static const struct mv88e6xxx_ops mv88e6351_ops = {
@@ -3276,6 +3291,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
 };
 
 static const struct mv88e6xxx_ops mv88e6352_ops = {
@@ -3285,6 +3301,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
 };
 
 static const struct mv88e6xxx_info mv88e6xxx_table[] = {
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 474d16d..ab48eb9 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -737,6 +737,15 @@ struct mv88e6xxx_ops {
 	 * or LINK_UNFORCED for normal link detection.
 	 */
 	int (*port_set_link)(struct mv88e6xxx_chip *chip, int port, int link);
+
+#define DUPLEX_UNFORCED		-2
+
+	/* Port's MAC duplex mode
+	 *
+	 * Use DUPLEX_HALF or DUPLEX_FULL to force half or full duplex,
+	 * or DUPLEX_UNFORCED for normal duplex detection.
+	 */
+	int (*port_set_duplex)(struct mv88e6xxx_chip *chip, int port, int dup);
 };
 
 enum stat_type {
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 09e25f9..17b5444 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -71,6 +71,42 @@ int mv88e6xxx_port_set_link(struct mv88e6xxx_chip *chip, int port, int link)
 	return 0;
 }
 
+int mv88e6xxx_port_set_duplex(struct mv88e6xxx_chip *chip, int port, int dup)
+{
+	u16 reg;
+	int err;
+
+	err = mv88e6xxx_port_read(chip, port, PORT_PCS_CTRL, &reg);
+	if (err)
+		return err;
+
+	reg &= ~(PORT_PCS_CTRL_FORCE_DUPLEX | PORT_PCS_CTRL_DUPLEX_FULL);
+
+	switch (dup) {
+	case DUPLEX_HALF:
+		reg |= PORT_PCS_CTRL_FORCE_DUPLEX;
+		break;
+	case DUPLEX_FULL:
+		reg |= PORT_PCS_CTRL_FORCE_DUPLEX | PORT_PCS_CTRL_DUPLEX_FULL;
+		break;
+	case DUPLEX_UNFORCED:
+		/* normal duplex detection */
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	err = mv88e6xxx_port_write(chip, port, PORT_PCS_CTRL, reg);
+	if (err)
+		return err;
+
+	netdev_dbg(chip->ds->ports[port].netdev, "%s %s duplex\n",
+		   reg & PORT_PCS_CTRL_FORCE_DUPLEX ? "Force" : "Unforce",
+		   reg & PORT_PCS_CTRL_DUPLEX_FULL ? "full" : "half");
+
+	return 0;
+}
+
 /* Offset 0x04: Port Control Register */
 
 static const char * const mv88e6xxx_port_state_names[] = {
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 87e7249..f73e90e 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -23,6 +23,8 @@ int mv88e6xxx_port_write(struct mv88e6xxx_chip *chip, int port, int reg,
 
 int mv88e6xxx_port_set_link(struct mv88e6xxx_chip *chip, int port, int link);
 
+int mv88e6xxx_port_set_duplex(struct mv88e6xxx_chip *chip, int port, int dup);
+
 int mv88e6xxx_port_set_state(struct mv88e6xxx_chip *chip, int port, u8 state);
 
 int mv88e6xxx_port_set_vlan_map(struct mv88e6xxx_chip *chip, int port, u16 map);
-- 
2.10.2
