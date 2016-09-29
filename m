From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 09/10] net: dsa: mv88e6xxx: add set_switch_mac to ops
Date: Thu, 29 Sep 2016 12:22:01 -0400
Message-ID: <20160929162202.10685-10-vivien.didelot@savoirfairelinux.com>
References: <20160929162202.10685-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48859 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755704AbcI2QWh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 12:22:37 -0400
In-Reply-To: <20160929162202.10685-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a set_switch_mac chip-wide function to mv88e6xxx_ops and remove
MV88E6XXX_FLAG_G2_SWITCH_MAC flags.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 28 +++++++++++++++++++++-------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  8 ++------
 2 files changed, 23 insertions(+), 13 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 83a3769..e40b71b 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2909,14 +2909,11 @@ static int mv88e6xxx_set_addr(struct dsa_switch *ds, u8 *addr)
 	struct mv88e6xxx_chip *chip = ds->priv;
 	int err;
 
+	if (!chip->info->ops->set_switch_mac)
+		return -EOPNOTSUPP;
+
 	mutex_lock(&chip->reg_lock);
-
-	/* Has an indirect Switch MAC/WoL/WoF register in Global 2? */
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_SWITCH_MAC))
-		err = mv88e6xxx_g2_set_switch_mac(chip, addr);
-	else
-		err = mv88e6xxx_g1_set_switch_mac(chip, addr);
-
+	err = chip->info->ops->set_switch_mac(chip, addr);
 	mutex_unlock(&chip->reg_lock);
 
 	return err;
@@ -3210,86 +3207,103 @@ static int mv88e6xxx_set_eeprom(struct dsa_switch *ds,
 }
 
 static const struct mv88e6xxx_ops mv88e6085_ops = {
+	.set_switch_mac = mv88e6xxx_g1_set_switch_mac,
 	.phy_read = mv88e6xxx_phy_ppu_read,
 	.phy_write = mv88e6xxx_phy_ppu_write,
 };
 
 static const struct mv88e6xxx_ops mv88e6095_ops = {
+	.set_switch_mac = mv88e6xxx_g1_set_switch_mac,
 	.phy_read = mv88e6xxx_phy_ppu_read,
 	.phy_write = mv88e6xxx_phy_ppu_write,
 };
 
 static const struct mv88e6xxx_ops mv88e6123_ops = {
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_read,
 	.phy_write = mv88e6xxx_write,
 };
 
 static const struct mv88e6xxx_ops mv88e6131_ops = {
+	.set_switch_mac = mv88e6xxx_g1_set_switch_mac,
 	.phy_read = mv88e6xxx_phy_ppu_read,
 	.phy_write = mv88e6xxx_phy_ppu_write,
 };
 
 static const struct mv88e6xxx_ops mv88e6161_ops = {
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_read,
 	.phy_write = mv88e6xxx_write,
 };
 
 static const struct mv88e6xxx_ops mv88e6165_ops = {
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_read,
 	.phy_write = mv88e6xxx_write,
 };
 
 static const struct mv88e6xxx_ops mv88e6171_ops = {
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 };
 
 static const struct mv88e6xxx_ops mv88e6172_ops = {
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 };
 
 static const struct mv88e6xxx_ops mv88e6175_ops = {
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 };
 
 static const struct mv88e6xxx_ops mv88e6176_ops = {
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 };
 
 static const struct mv88e6xxx_ops mv88e6185_ops = {
+	.set_switch_mac = mv88e6xxx_g1_set_switch_mac,
 	.phy_read = mv88e6xxx_phy_ppu_read,
 	.phy_write = mv88e6xxx_phy_ppu_write,
 };
 
 static const struct mv88e6xxx_ops mv88e6240_ops = {
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 };
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 };
 
 static const struct mv88e6xxx_ops mv88e6321_ops = {
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 };
 
 static const struct mv88e6xxx_ops mv88e6350_ops = {
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 };
 
 static const struct mv88e6xxx_ops mv88e6351_ops = {
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 };
 
 static const struct mv88e6xxx_ops mv88e6352_ops = {
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 };
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 8e12902..d04184c 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -423,7 +423,6 @@ enum mv88e6xxx_cap {
 	MV88E6XXX_CAP_G2_IRL_DATA,	/* (0x0a) Ingress Rate Data */
 	MV88E6XXX_CAP_G2_PVT_ADDR,	/* (0x0b) Cross Chip Port VLAN Addr */
 	MV88E6XXX_CAP_G2_PVT_DATA,	/* (0x0c) Cross Chip Port VLAN Data */
-	MV88E6XXX_CAP_G2_SWITCH_MAC,	/* (0x0d) Switch MAC/WoL/WoF */
 	MV88E6XXX_CAP_G2_POT,		/* (0x0f) Priority Override Table */
 	MV88E6XXX_CAP_G2_EEPROM_CMD,	/* (0x14) EEPROM Command */
 	MV88E6XXX_CAP_G2_EEPROM_DATA,	/* (0x15) EEPROM Data */
@@ -473,7 +472,6 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_G2_IRL_DATA	BIT_ULL(MV88E6XXX_CAP_G2_IRL_DATA)
 #define MV88E6XXX_FLAG_G2_PVT_ADDR	BIT_ULL(MV88E6XXX_CAP_G2_PVT_ADDR)
 #define MV88E6XXX_FLAG_G2_PVT_DATA	BIT_ULL(MV88E6XXX_CAP_G2_PVT_DATA)
-#define MV88E6XXX_FLAG_G2_SWITCH_MAC	BIT_ULL(MV88E6XXX_CAP_G2_SWITCH_MAC)
 #define MV88E6XXX_FLAG_G2_POT		BIT_ULL(MV88E6XXX_CAP_G2_POT)
 #define MV88E6XXX_FLAG_G2_EEPROM_CMD	BIT_ULL(MV88E6XXX_CAP_G2_EEPROM_CMD)
 #define MV88E6XXX_FLAG_G2_EEPROM_DATA	BIT_ULL(MV88E6XXX_CAP_G2_EEPROM_DATA)
@@ -537,7 +535,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
-	 MV88E6XXX_FLAG_G2_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_TEMP |		\
@@ -559,7 +556,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
-	 MV88E6XXX_FLAG_G2_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_TEMP |		\
@@ -577,7 +573,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
-	 MV88E6XXX_FLAG_G2_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_STU |		\
@@ -595,7 +590,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
-	 MV88E6XXX_FLAG_G2_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_STU |		\
@@ -702,6 +696,8 @@ struct mv88e6xxx_bus_ops {
 };
 
 struct mv88e6xxx_ops {
+	int (*set_switch_mac)(struct mv88e6xxx_chip *chip, u8 *addr);
+
 	int (*phy_read)(struct mv88e6xxx_chip *chip, int addr, int reg,
 			u16 *val);
 	int (*phy_write)(struct mv88e6xxx_chip *chip, int addr, int reg,
-- 
2.10.0
