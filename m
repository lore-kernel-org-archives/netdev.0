From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 07/10] net: dsa: mv88e6xxx: prefix Global 2 EEPROM macros
Date: Mon, 19 Jun 2017 10:55:42 -0400
Message-ID: <20170619145545.26697-8-vivien.didelot@savoirfairelinux.com>
References: <20170619145545.26697-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170619145545.26697-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prefix and document the Global 2 EEPROM registers macros.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/global2.c | 32 +++++++++++++++++---------------
 drivers/net/dsa/mv88e6xxx/global2.h | 31 +++++++++++++++++++++----------
 2 files changed, 38 insertions(+), 25 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index dc6c0f5fd605..8621f5893406 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -282,16 +282,17 @@ static int mv88e6xxx_g2_clear_pot(struct mv88e6xxx_chip *chip)
 
 static int mv88e6xxx_g2_eeprom_wait(struct mv88e6xxx_chip *chip)
 {
-	return mv88e6xxx_g2_wait(chip, GLOBAL2_EEPROM_CMD,
-				 GLOBAL2_EEPROM_CMD_BUSY |
-				 GLOBAL2_EEPROM_CMD_RUNNING);
+	return mv88e6xxx_g2_wait(chip, MV88E6XXX_G2_EEPROM_CMD,
+				 MV88E6XXX_G2_EEPROM_CMD_BUSY |
+				 MV88E6XXX_G2_EEPROM_CMD_RUNNING);
 }
 
 static int mv88e6xxx_g2_eeprom_cmd(struct mv88e6xxx_chip *chip, u16 cmd)
 {
 	int err;
 
-	err = mv88e6xxx_g2_write(chip, GLOBAL2_EEPROM_CMD, cmd);
+	err = mv88e6xxx_g2_write(chip, MV88E6XXX_G2_EEPROM_CMD,
+				 MV88E6XXX_G2_EEPROM_CMD_BUSY | cmd);
 	if (err)
 		return err;
 
@@ -301,14 +302,14 @@ static int mv88e6xxx_g2_eeprom_cmd(struct mv88e6xxx_chip *chip, u16 cmd)
 static int mv88e6xxx_g2_eeprom_read8(struct mv88e6xxx_chip *chip,
 				     u16 addr, u8 *data)
 {
-	u16 cmd = GLOBAL2_EEPROM_CMD_OP_READ;
+	u16 cmd = MV88E6XXX_G2_EEPROM_CMD_OP_READ;
 	int err;
 
 	err = mv88e6xxx_g2_eeprom_wait(chip);
 	if (err)
 		return err;
 
-	err = mv88e6xxx_g2_write(chip, GLOBAL2_EEPROM_ADDR, addr);
+	err = mv88e6xxx_g2_write(chip, MV88E6390_G2_EEPROM_ADDR, addr);
 	if (err)
 		return err;
 
@@ -316,7 +317,7 @@ static int mv88e6xxx_g2_eeprom_read8(struct mv88e6xxx_chip *chip,
 	if (err)
 		return err;
 
-	err = mv88e6xxx_g2_read(chip, GLOBAL2_EEPROM_CMD, &cmd);
+	err = mv88e6xxx_g2_read(chip, MV88E6XXX_G2_EEPROM_CMD, &cmd);
 	if (err)
 		return err;
 
@@ -328,14 +329,15 @@ static int mv88e6xxx_g2_eeprom_read8(struct mv88e6xxx_chip *chip,
 static int mv88e6xxx_g2_eeprom_write8(struct mv88e6xxx_chip *chip,
 				      u16 addr, u8 data)
 {
-	u16 cmd = GLOBAL2_EEPROM_CMD_OP_WRITE | GLOBAL2_EEPROM_CMD_WRITE_EN;
+	u16 cmd = MV88E6XXX_G2_EEPROM_CMD_OP_WRITE |
+		MV88E6XXX_G2_EEPROM_CMD_WRITE_EN;
 	int err;
 
 	err = mv88e6xxx_g2_eeprom_wait(chip);
 	if (err)
 		return err;
 
-	err = mv88e6xxx_g2_write(chip, GLOBAL2_EEPROM_ADDR, addr);
+	err = mv88e6xxx_g2_write(chip, MV88E6390_G2_EEPROM_ADDR, addr);
 	if (err)
 		return err;
 
@@ -345,7 +347,7 @@ static int mv88e6xxx_g2_eeprom_write8(struct mv88e6xxx_chip *chip,
 static int mv88e6xxx_g2_eeprom_read16(struct mv88e6xxx_chip *chip,
 				      u8 addr, u16 *data)
 {
-	u16 cmd = GLOBAL2_EEPROM_CMD_OP_READ | addr;
+	u16 cmd = MV88E6XXX_G2_EEPROM_CMD_OP_READ | addr;
 	int err;
 
 	err = mv88e6xxx_g2_eeprom_wait(chip);
@@ -356,20 +358,20 @@ static int mv88e6xxx_g2_eeprom_read16(struct mv88e6xxx_chip *chip,
 	if (err)
 		return err;
 
-	return mv88e6xxx_g2_read(chip, GLOBAL2_EEPROM_DATA, data);
+	return mv88e6xxx_g2_read(chip, MV88E6352_G2_EEPROM_DATA, data);
 }
 
 static int mv88e6xxx_g2_eeprom_write16(struct mv88e6xxx_chip *chip,
 				       u8 addr, u16 data)
 {
-	u16 cmd = GLOBAL2_EEPROM_CMD_OP_WRITE | addr;
+	u16 cmd = MV88E6XXX_G2_EEPROM_CMD_OP_WRITE | addr;
 	int err;
 
 	err = mv88e6xxx_g2_eeprom_wait(chip);
 	if (err)
 		return err;
 
-	err = mv88e6xxx_g2_write(chip, GLOBAL2_EEPROM_DATA, data);
+	err = mv88e6xxx_g2_write(chip, MV88E6352_G2_EEPROM_DATA, data);
 	if (err)
 		return err;
 
@@ -481,11 +483,11 @@ int mv88e6xxx_g2_set_eeprom16(struct mv88e6xxx_chip *chip,
 	int err;
 
 	/* Ensure the RO WriteEn bit is set */
-	err = mv88e6xxx_g2_read(chip, GLOBAL2_EEPROM_CMD, &val);
+	err = mv88e6xxx_g2_read(chip, MV88E6XXX_G2_EEPROM_CMD, &val);
 	if (err)
 		return err;
 
-	if (!(val & GLOBAL2_EEPROM_CMD_WRITE_EN))
+	if (!(val & MV88E6XXX_G2_EEPROM_CMD_WRITE_EN))
 		return -EROFS;
 
 	eeprom->len = 0;
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index 0133c1cdfd6c..a0a6cb3cb6fe 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -99,16 +99,27 @@
 #define GLOBAL2_PRIO_OVERRIDE_SNOOP_SHIFT	4
 #define GLOBAL2_PRIO_OVERRIDE_FORCE_ARP		BIT(3)
 #define GLOBAL2_PRIO_OVERRIDE_ARP_SHIFT		0
-#define GLOBAL2_EEPROM_CMD		0x14
-#define GLOBAL2_EEPROM_CMD_BUSY		BIT(15)
-#define GLOBAL2_EEPROM_CMD_OP_WRITE	((0x3 << 12) | GLOBAL2_EEPROM_CMD_BUSY)
-#define GLOBAL2_EEPROM_CMD_OP_READ	((0x4 << 12) | GLOBAL2_EEPROM_CMD_BUSY)
-#define GLOBAL2_EEPROM_CMD_OP_LOAD	((0x6 << 12) | GLOBAL2_EEPROM_CMD_BUSY)
-#define GLOBAL2_EEPROM_CMD_RUNNING	BIT(11)
-#define GLOBAL2_EEPROM_CMD_WRITE_EN	BIT(10)
-#define GLOBAL2_EEPROM_CMD_ADDR_MASK	0xff
-#define GLOBAL2_EEPROM_DATA	0x15
-#define GLOBAL2_EEPROM_ADDR	0x15 /* 6390, 6341 */
+
+/* Offset 0x14: EEPROM Command */
+#define MV88E6XXX_G2_EEPROM_CMD			0x14
+#define MV88E6XXX_G2_EEPROM_CMD_BUSY		0x8000
+#define MV88E6XXX_G2_EEPROM_CMD_OP_MASK		0x7000
+#define MV88E6XXX_G2_EEPROM_CMD_OP_WRITE	0x3000
+#define MV88E6XXX_G2_EEPROM_CMD_OP_READ		0x4000
+#define MV88E6XXX_G2_EEPROM_CMD_OP_LOAD		0x6000
+#define MV88E6XXX_G2_EEPROM_CMD_RUNNING		0x0800
+#define MV88E6XXX_G2_EEPROM_CMD_WRITE_EN	0x0400
+#define MV88E6352_G2_EEPROM_CMD_ADDR_MASK	0x00ff
+#define MV88E6390_G2_EEPROM_CMD_DATA_MASK	0x00ff
+
+/* Offset 0x15: EEPROM Data */
+#define MV88E6352_G2_EEPROM_DATA	0x15
+#define MV88E6352_G2_EEPROM_DATA_MASK	0xffff
+
+/* Offset 0x15: EEPROM Addr */
+#define MV88E6390_G2_EEPROM_ADDR	0x15
+#define MV88E6390_G2_EEPROM_ADDR_MASK	0xffff
+
 #define GLOBAL2_PTP_AVB_OP	0x16
 #define GLOBAL2_PTP_AVB_DATA	0x17
 
-- 
2.13.1
