From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/6] net: dsa: mv88e6xxx: describe Multi-chip registers
Date: Mon, 15 Aug 2016 17:18:58 -0400
Message-ID: <20160815211902.2236-3-vivien.didelot@savoirfairelinux.com>
References: <20160815211902.2236-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160815211902.2236-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add flags to describe the presence of SMI Command and Data registers
used to indirectly access internal SMI devices registers when the switch
SMI address is not zero.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      |  2 +-
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 40 ++++++++++++++++++++++-------------
 2 files changed, 26 insertions(+), 16 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index a5a96bc..44debf2 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3883,7 +3883,7 @@ static int mv88e6xxx_smi_init(struct mv88e6xxx_chip *chip,
 
 	if (sw_addr == 0)
 		chip->smi_ops = &mv88e6xxx_smi_single_chip_ops;
-	else if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_MULTI_CHIP))
+	else if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_MULTI_CHIP))
 		chip->smi_ops = &mv88e6xxx_smi_multi_chip_ops;
 	else
 		return -EINVAL;
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 48d6ea7..527a880 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -388,6 +388,13 @@ enum mv88e6xxx_cap {
 	 */
 	MV88E6XXX_CAP_EEE,
 
+	/* Multi-chip Addressing Mode.
+	 * Some chips respond to only 2 registers of its own SMI device address
+	 * when it is non-zero, and use indirect access to internal registers.
+	 */
+	MV88E6XXX_CAP_SMI_CMD,		/* (0x00) SMI Command */
+	MV88E6XXX_CAP_SMI_DATA,		/* (0x01) SMI Data */
+
 	/* Switch Global 2 Registers.
 	 * The device contains a second set of global 16-bit registers.
 	 */
@@ -403,12 +410,6 @@ enum mv88e6xxx_cap {
 	MV88E6XXX_CAP_G2_EEPROM_CMD,	/* (0x14) EEPROM Command */
 	MV88E6XXX_CAP_G2_EEPROM_DATA,	/* (0x15) EEPROM Data */
 
-	/* Multi-chip Addressing Mode.
-	 * Some chips require an indirect SMI access when their SMI device
-	 * address is not zero. See SMI_CMD and SMI_DATA.
-	 */
-	MV88E6XXX_CAP_MULTI_CHIP,
-
 	/* PHY Polling Unit.
 	 * See GLOBAL_CONTROL_PPU_ENABLE and GLOBAL_STATUS_PPU_POLLING.
 	 */
@@ -441,6 +442,10 @@ enum mv88e6xxx_cap {
 
 /* Bitmask of capabilities */
 #define MV88E6XXX_FLAG_EEE		BIT(MV88E6XXX_CAP_EEE)
+
+#define MV88E6XXX_FLAG_SMI_CMD		BIT(MV88E6XXX_CAP_SMI_CMD)
+#define MV88E6XXX_FLAG_SMI_DATA		BIT(MV88E6XXX_CAP_SMI_DATA)
+
 #define MV88E6XXX_FLAG_GLOBAL2		BIT(MV88E6XXX_CAP_GLOBAL2)
 #define MV88E6XXX_FLAG_G2_MGMT_EN_2X	BIT(MV88E6XXX_CAP_G2_MGMT_EN_2X)
 #define MV88E6XXX_FLAG_G2_MGMT_EN_0X	BIT(MV88E6XXX_CAP_G2_MGMT_EN_0X)
@@ -452,7 +457,7 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_G2_POT		BIT(MV88E6XXX_CAP_G2_POT)
 #define MV88E6XXX_FLAG_G2_EEPROM_CMD	BIT(MV88E6XXX_CAP_G2_EEPROM_CMD)
 #define MV88E6XXX_FLAG_G2_EEPROM_DATA	BIT(MV88E6XXX_CAP_G2_EEPROM_DATA)
-#define MV88E6XXX_FLAG_MULTI_CHIP	BIT(MV88E6XXX_CAP_MULTI_CHIP)
+
 #define MV88E6XXX_FLAG_PPU		BIT(MV88E6XXX_CAP_PPU)
 #define MV88E6XXX_FLAG_PPU_ACTIVE	BIT(MV88E6XXX_CAP_PPU_ACTIVE)
 #define MV88E6XXX_FLAG_SMI_PHY		BIT(MV88E6XXX_CAP_SMI_PHY)
@@ -471,6 +476,11 @@ enum mv88e6xxx_cap {
 	(MV88E6XXX_FLAG_G2_IRL_CMD |	\
 	 MV88E6XXX_FLAG_G2_IRL_DATA)
 
+/* Multi-chip Addressing Mode */
+#define MV88E6XXX_FLAGS_MULTI_CHIP	\
+	(MV88E6XXX_FLAG_SMI_CMD |	\
+	 MV88E6XXX_FLAG_SMI_DATA)
+
 /* Cross-chip Port VLAN Table */
 #define MV88E6XXX_FLAGS_PVT		\
 	(MV88E6XXX_FLAG_G2_PVT_ADDR |	\
@@ -479,20 +489,20 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAGS_FAMILY_6095	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
-	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU |		\
-	 MV88E6XXX_FLAG_VTU)
+	 MV88E6XXX_FLAG_VTU |		\
+	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6097	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
+	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
 	 MV88E6XXX_FLAGS_PVT)
 
 #define MV88E6XXX_FLAGS_FAMILY_6165	\
@@ -501,17 +511,17 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
+	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
 	 MV88E6XXX_FLAGS_PVT)
 
 #define MV88E6XXX_FLAGS_FAMILY_6185	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
-	 MV88E6XXX_FLAG_MULTI_CHIP |	\
+	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_VTU)
 
@@ -522,7 +532,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
 	 MV88E6XXX_FLAG_TEMP |		\
@@ -530,6 +539,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_EEPROM16 |	\
 	 MV88E6XXX_FLAGS_IRL |		\
+	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
 	 MV88E6XXX_FLAGS_PVT)
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
@@ -538,13 +548,13 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
+	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
 	 MV88E6XXX_FLAGS_PVT)
 
 #define MV88E6XXX_FLAGS_FAMILY_6352	\
@@ -554,7 +564,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
 	 MV88E6XXX_FLAG_STU |		\
@@ -563,6 +572,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_EEPROM16 |	\
 	 MV88E6XXX_FLAGS_IRL |		\
+	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
 	 MV88E6XXX_FLAGS_PVT)
 
 struct mv88e6xxx_info {
-- 
2.9.3
