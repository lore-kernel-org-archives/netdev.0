From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: mv88e6xxx: add EEPROM support to 6390
Date: Thu, 12 Jan 2017 18:07:16 -0500
Message-ID: <20170112230716.2083-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, cphealy@gmail.com,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Marvell 6352 chip has a 8-bit address/16-bit data EEPROM access.
The Marvell 6390 chip has a 16-bit address/8-bit data EEPROM access.

This patch implements the 8-bit data EEPROM access in the mv88e6xxx
driver and adds its support to chips of the 6390 family.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 14 ++++++
 drivers/net/dsa/mv88e6xxx/global2.c   | 93 ++++++++++++++++++++++++++++++++++-
 drivers/net/dsa/mv88e6xxx/global2.h   | 21 ++++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  1 +
 4 files changed, 128 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index eea8e0176e33..987b2dbbd35a 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3453,6 +3453,8 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 
 static const struct mv88e6xxx_ops mv88e6190_ops = {
 	/* MV88E6XXX_FAMILY_6390 */
+	.get_eeprom = mv88e6xxx_g2_get_eeprom8,
+	.set_eeprom = mv88e6xxx_g2_set_eeprom8,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3478,6 +3480,8 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 
 static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	/* MV88E6XXX_FAMILY_6390 */
+	.get_eeprom = mv88e6xxx_g2_get_eeprom8,
+	.set_eeprom = mv88e6xxx_g2_set_eeprom8,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3503,6 +3507,8 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 
 static const struct mv88e6xxx_ops mv88e6191_ops = {
 	/* MV88E6XXX_FAMILY_6390 */
+	.get_eeprom = mv88e6xxx_g2_get_eeprom8,
+	.set_eeprom = mv88e6xxx_g2_set_eeprom8,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3556,6 +3562,8 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 
 static const struct mv88e6xxx_ops mv88e6290_ops = {
 	/* MV88E6XXX_FAMILY_6390 */
+	.get_eeprom = mv88e6xxx_g2_get_eeprom8,
+	.set_eeprom = mv88e6xxx_g2_set_eeprom8,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3714,6 +3722,8 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 
 static const struct mv88e6xxx_ops mv88e6390_ops = {
 	/* MV88E6XXX_FAMILY_6390 */
+	.get_eeprom = mv88e6xxx_g2_get_eeprom8,
+	.set_eeprom = mv88e6xxx_g2_set_eeprom8,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3741,6 +3751,8 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 
 static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	/* MV88E6XXX_FAMILY_6390 */
+	.get_eeprom = mv88e6xxx_g2_get_eeprom8,
+	.set_eeprom = mv88e6xxx_g2_set_eeprom8,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3768,6 +3780,8 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 
 static const struct mv88e6xxx_ops mv88e6391_ops = {
 	/* MV88E6XXX_FAMILY_6390 */
+	.get_eeprom = mv88e6xxx_g2_get_eeprom8,
+	.set_eeprom = mv88e6xxx_g2_set_eeprom8,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index 3e77071949ab..ead2e265c9ef 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -218,7 +218,8 @@ static int mv88e6xxx_g2_clear_pot(struct mv88e6xxx_chip *chip)
 }
 
 /* Offset 0x14: EEPROM Command
- * Offset 0x15: EEPROM Data
+ * Offset 0x15: EEPROM Data (for 16-bit data access)
+ * Offset 0x15: EEPROM Addr (for 8-bit data access)
  */
 
 static int mv88e6xxx_g2_eeprom_wait(struct mv88e6xxx_chip *chip)
@@ -239,6 +240,50 @@ static int mv88e6xxx_g2_eeprom_cmd(struct mv88e6xxx_chip *chip, u16 cmd)
 	return mv88e6xxx_g2_eeprom_wait(chip);
 }
 
+static int mv88e6xxx_g2_eeprom_read8(struct mv88e6xxx_chip *chip,
+				     u16 addr, u8 *data)
+{
+	u16 cmd = GLOBAL2_EEPROM_CMD_OP_READ;
+	int err;
+
+	err = mv88e6xxx_g2_eeprom_wait(chip);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g2_write(chip, GLOBAL2_EEPROM_ADDR, addr);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g2_eeprom_cmd(chip, cmd);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g2_read(chip, GLOBAL2_EEPROM_CMD, &cmd);
+	if (err)
+		return err;
+
+	*data = cmd & 0xff;
+
+	return 0;
+}
+
+static int mv88e6xxx_g2_eeprom_write8(struct mv88e6xxx_chip *chip,
+				      u16 addr, u8 data)
+{
+	u16 cmd = GLOBAL2_EEPROM_CMD_OP_WRITE | GLOBAL2_EEPROM_CMD_WRITE_EN;
+	int err;
+
+	err = mv88e6xxx_g2_eeprom_wait(chip);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g2_write(chip, GLOBAL2_EEPROM_ADDR, addr);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g2_eeprom_cmd(chip, cmd | data);
+}
+
 static int mv88e6xxx_g2_eeprom_read16(struct mv88e6xxx_chip *chip,
 				      u8 addr, u16 *data)
 {
@@ -273,6 +318,52 @@ static int mv88e6xxx_g2_eeprom_write16(struct mv88e6xxx_chip *chip,
 	return mv88e6xxx_g2_eeprom_cmd(chip, cmd);
 }
 
+int mv88e6xxx_g2_get_eeprom8(struct mv88e6xxx_chip *chip,
+			     struct ethtool_eeprom *eeprom, u8 *data)
+{
+	unsigned int offset = eeprom->offset;
+	unsigned int len = eeprom->len;
+	int err;
+
+	eeprom->len = 0;
+
+	while (len) {
+		err = mv88e6xxx_g2_eeprom_read8(chip, offset, data);
+		if (err)
+			return err;
+
+		eeprom->len++;
+		offset++;
+		data++;
+		len--;
+	}
+
+	return 0;
+}
+
+int mv88e6xxx_g2_set_eeprom8(struct mv88e6xxx_chip *chip,
+			     struct ethtool_eeprom *eeprom, u8 *data)
+{
+	unsigned int offset = eeprom->offset;
+	unsigned int len = eeprom->len;
+	int err;
+
+	eeprom->len = 0;
+
+	while (len) {
+		err = mv88e6xxx_g2_eeprom_write8(chip, offset, *data);
+		if (err)
+			return err;
+
+		eeprom->len++;
+		offset++;
+		data++;
+		len--;
+	}
+
+	return 0;
+}
+
 int mv88e6xxx_g2_get_eeprom16(struct mv88e6xxx_chip *chip,
 			      struct ethtool_eeprom *eeprom, u8 *data)
 {
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index 9aefb7d8b0ad..2918f22388f7 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -28,10 +28,17 @@ int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip, int addr, int reg,
 int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip, int addr, int reg,
 			       u16 val);
 int mv88e6xxx_g2_set_switch_mac(struct mv88e6xxx_chip *chip, u8 *addr);
+
+int mv88e6xxx_g2_get_eeprom8(struct mv88e6xxx_chip *chip,
+			     struct ethtool_eeprom *eeprom, u8 *data);
+int mv88e6xxx_g2_set_eeprom8(struct mv88e6xxx_chip *chip,
+			     struct ethtool_eeprom *eeprom, u8 *data);
+
 int mv88e6xxx_g2_get_eeprom16(struct mv88e6xxx_chip *chip,
 			      struct ethtool_eeprom *eeprom, u8 *data);
 int mv88e6xxx_g2_set_eeprom16(struct mv88e6xxx_chip *chip,
 			      struct ethtool_eeprom *eeprom, u8 *data);
+
 int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip);
 int mv88e6xxx_g2_irq_setup(struct mv88e6xxx_chip *chip);
 void mv88e6xxx_g2_irq_free(struct mv88e6xxx_chip *chip);
@@ -67,6 +74,20 @@ static inline int mv88e6xxx_g2_set_switch_mac(struct mv88e6xxx_chip *chip,
 	return -EOPNOTSUPP;
 }
 
+static inline int mv88e6xxx_g2_get_eeprom8(struct mv88e6xxx_chip *chip,
+					   struct ethtool_eeprom *eeprom,
+					   u8 *data)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int mv88e6xxx_g2_set_eeprom8(struct mv88e6xxx_chip *chip,
+					   struct ethtool_eeprom *eeprom,
+					   u8 *data)
+{
+	return -EOPNOTSUPP;
+}
+
 static inline int mv88e6xxx_g2_get_eeprom16(struct mv88e6xxx_chip *chip,
 					    struct ethtool_eeprom *eeprom,
 					    u8 *data)
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index a224d66dafd9..466cfdadb7bd 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -382,6 +382,7 @@
 #define GLOBAL2_EEPROM_CMD_WRITE_EN	BIT(10)
 #define GLOBAL2_EEPROM_CMD_ADDR_MASK	0xff
 #define GLOBAL2_EEPROM_DATA	0x15
+#define GLOBAL2_EEPROM_ADDR	0x15 /* 6390 */
 #define GLOBAL2_PTP_AVB_OP	0x16
 #define GLOBAL2_PTP_AVB_DATA	0x17
 #define GLOBAL2_SMI_PHY_CMD			0x18
-- 
2.11.0
