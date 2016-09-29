From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 10/10] net: dsa: mv88e6xxx: add eeprom ops
Date: Thu, 29 Sep 2016 12:22:02 -0400
Message-ID: <20160929162202.10685-11-vivien.didelot@savoirfairelinux.com>
References: <20160929162202.10685-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160929162202.10685-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove EEPROM flags in favor of new {get,set}_eeprom chip-wide
functions in the mv88e6xxx_ops structure.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 34 +++++++++++++++++++++-------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 16 +++++-----------
 2 files changed, 26 insertions(+), 24 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index e40b71b..883fd98 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3168,13 +3168,11 @@ static int mv88e6xxx_get_eeprom(struct dsa_switch *ds,
 	struct mv88e6xxx_chip *chip = ds->priv;
 	int err;
 
+	if (!chip->info->ops->get_eeprom)
+		return -EOPNOTSUPP;
+
 	mutex_lock(&chip->reg_lock);
-
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_EEPROM16))
-		err = mv88e6xxx_g2_get_eeprom16(chip, eeprom, data);
-	else
-		err = -EOPNOTSUPP;
-
+	err = chip->info->ops->get_eeprom(chip, eeprom, data);
 	mutex_unlock(&chip->reg_lock);
 
 	if (err)
@@ -3191,16 +3189,14 @@ static int mv88e6xxx_set_eeprom(struct dsa_switch *ds,
 	struct mv88e6xxx_chip *chip = ds->priv;
 	int err;
 
+	if (!chip->info->ops->set_eeprom)
+		return -EOPNOTSUPP;
+
 	if (eeprom->magic != 0xc3ec4951)
 		return -EINVAL;
 
 	mutex_lock(&chip->reg_lock);
-
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_EEPROM16))
-		err = mv88e6xxx_g2_set_eeprom16(chip, eeprom, data);
-	else
-		err = -EOPNOTSUPP;
-
+	err = chip->info->ops->set_eeprom(chip, eeprom, data);
 	mutex_unlock(&chip->reg_lock);
 
 	return err;
@@ -3249,6 +3245,8 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6172_ops = {
+	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
+	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3261,6 +3259,8 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6176_ops = {
+	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
+	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3273,18 +3273,24 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6240_ops = {
+	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
+	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 };
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
+	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
+	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 };
 
 static const struct mv88e6xxx_ops mv88e6321_ops = {
+	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
+	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3303,6 +3309,8 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6352_ops = {
+	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
+	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3825,7 +3833,7 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	if (IS_ERR(chip->reset))
 		return PTR_ERR(chip->reset);
 
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_EEPROM16) &&
+	if (chip->info->ops->get_eeprom &&
 	    !of_property_read_u32(np, "eeprom-length", &eeprom_len))
 		chip->eeprom_len = eeprom_len;
 
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index d04184c..e572121 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -424,8 +424,6 @@ enum mv88e6xxx_cap {
 	MV88E6XXX_CAP_G2_PVT_ADDR,	/* (0x0b) Cross Chip Port VLAN Addr */
 	MV88E6XXX_CAP_G2_PVT_DATA,	/* (0x0c) Cross Chip Port VLAN Data */
 	MV88E6XXX_CAP_G2_POT,		/* (0x0f) Priority Override Table */
-	MV88E6XXX_CAP_G2_EEPROM_CMD,	/* (0x14) EEPROM Command */
-	MV88E6XXX_CAP_G2_EEPROM_DATA,	/* (0x15) EEPROM Data */
 
 	/* PHY Polling Unit.
 	 * See GLOBAL_CONTROL_PPU_ENABLE and GLOBAL_STATUS_PPU_POLLING.
@@ -473,8 +471,6 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_G2_PVT_ADDR	BIT_ULL(MV88E6XXX_CAP_G2_PVT_ADDR)
 #define MV88E6XXX_FLAG_G2_PVT_DATA	BIT_ULL(MV88E6XXX_CAP_G2_PVT_DATA)
 #define MV88E6XXX_FLAG_G2_POT		BIT_ULL(MV88E6XXX_CAP_G2_POT)
-#define MV88E6XXX_FLAG_G2_EEPROM_CMD	BIT_ULL(MV88E6XXX_CAP_G2_EEPROM_CMD)
-#define MV88E6XXX_FLAG_G2_EEPROM_DATA	BIT_ULL(MV88E6XXX_CAP_G2_EEPROM_DATA)
 
 #define MV88E6XXX_FLAG_PPU		BIT_ULL(MV88E6XXX_CAP_PPU)
 #define MV88E6XXX_FLAG_PPU_ACTIVE	BIT_ULL(MV88E6XXX_CAP_PPU_ACTIVE)
@@ -483,11 +479,6 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_TEMP_LIMIT	BIT_ULL(MV88E6XXX_CAP_TEMP_LIMIT)
 #define MV88E6XXX_FLAG_VTU		BIT_ULL(MV88E6XXX_CAP_VTU)
 
-/* EEPROM Programming via Global2 with 16-bit data */
-#define MV88E6XXX_FLAGS_EEPROM16	\
-	(MV88E6XXX_FLAG_G2_EEPROM_CMD |	\
-	 MV88E6XXX_FLAG_G2_EEPROM_DATA)
-
 /* Ingress Rate Limit unit */
 #define MV88E6XXX_FLAGS_IRL		\
 	(MV88E6XXX_FLAG_G2_IRL_CMD |	\
@@ -561,7 +552,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_TEMP_LIMIT |	\
 	 MV88E6XXX_FLAG_VTU |		\
-	 MV88E6XXX_FLAGS_EEPROM16 |	\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
 	 MV88E6XXX_FLAGS_PVT)
@@ -596,7 +586,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_TEMP_LIMIT |	\
 	 MV88E6XXX_FLAG_VTU |		\
-	 MV88E6XXX_FLAGS_EEPROM16 |	\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
 	 MV88E6XXX_FLAGS_PVT |		\
@@ -696,6 +685,11 @@ struct mv88e6xxx_bus_ops {
 };
 
 struct mv88e6xxx_ops {
+	int (*get_eeprom)(struct mv88e6xxx_chip *chip,
+			  struct ethtool_eeprom *eeprom, u8 *data);
+	int (*set_eeprom)(struct mv88e6xxx_chip *chip,
+			  struct ethtool_eeprom *eeprom, u8 *data);
+
 	int (*set_switch_mac)(struct mv88e6xxx_chip *chip, u8 *addr);
 
 	int (*phy_read)(struct mv88e6xxx_chip *chip, int addr, int reg,
-- 
2.10.0
