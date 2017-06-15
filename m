From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 5/8] net: dsa: mv88e6xxx: prefix Global Control macros
Date: Thu, 15 Jun 2017 12:14:03 -0400
Message-ID: <20170615161406.20546-6-vivien.didelot@savoirfairelinux.com>
References: <20170615161406.20546-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170615161406.20546-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prefix and document the Global Control and Control 2 registers macros
and give a clear 16-bit registers representation.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c    | 18 +++++++--------
 drivers/net/dsa/mv88e6xxx/global1.c | 32 +++++++++++++-------------
 drivers/net/dsa/mv88e6xxx/global1.h | 46 ++++++++++++++++++++-----------------
 3 files changed, 50 insertions(+), 46 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index f2ce054913e4..c31ad01c7f96 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -292,14 +292,14 @@ static void mv88e6xxx_g1_irq_bus_sync_unlock(struct irq_data *d)
 	u16 reg;
 	int err;
 
-	err = mv88e6xxx_g1_read(chip, GLOBAL_CONTROL, &reg);
+	err = mv88e6xxx_g1_read(chip, MV88E6XXX_G1_CTL1, &reg);
 	if (err)
 		goto out;
 
 	reg &= ~mask;
 	reg |= (~chip->g1_irq.masked & mask);
 
-	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL, reg);
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_CTL1, reg);
 	if (err)
 		goto out;
 
@@ -338,9 +338,9 @@ static void mv88e6xxx_g1_irq_free(struct mv88e6xxx_chip *chip)
 	int irq, virq;
 	u16 mask;
 
-	mv88e6xxx_g1_read(chip, GLOBAL_CONTROL, &mask);
+	mv88e6xxx_g1_read(chip, MV88E6XXX_G1_CTL1, &mask);
 	mask |= GENMASK(chip->g1_irq.nirqs, 0);
-	mv88e6xxx_g1_write(chip, GLOBAL_CONTROL, mask);
+	mv88e6xxx_g1_write(chip, MV88E6XXX_G1_CTL1, mask);
 
 	free_irq(chip->irq, chip);
 
@@ -370,13 +370,13 @@ static int mv88e6xxx_g1_irq_setup(struct mv88e6xxx_chip *chip)
 	chip->g1_irq.chip = mv88e6xxx_g1_irq_chip;
 	chip->g1_irq.masked = ~0;
 
-	err = mv88e6xxx_g1_read(chip, GLOBAL_CONTROL, &mask);
+	err = mv88e6xxx_g1_read(chip, MV88E6XXX_G1_CTL1, &mask);
 	if (err)
 		goto out_mapping;
 
 	mask &= ~GENMASK(chip->g1_irq.nirqs, 0);
 
-	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL, mask);
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_CTL1, mask);
 	if (err)
 		goto out_disable;
 
@@ -396,7 +396,7 @@ static int mv88e6xxx_g1_irq_setup(struct mv88e6xxx_chip *chip)
 
 out_disable:
 	mask |= GENMASK(chip->g1_irq.nirqs, 0);
-	mv88e6xxx_g1_write(chip, GLOBAL_CONTROL, mask);
+	mv88e6xxx_g1_write(chip, MV88E6XXX_G1_CTL1, mask);
 
 out_mapping:
 	for (irq = 0; irq < 16; irq++) {
@@ -2014,8 +2014,8 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 	}
 
 	/* Disable remote management, and set the switch's DSA device number. */
-	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL_2,
-				 GLOBAL_CONTROL_2_MULTIPLE_CASCADE |
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_CTL2,
+				 MV88E6XXX_G1_CTL2_MULTIPLE_CASCADE |
 				 (ds->index & 0x1f));
 	if (err)
 		return err;
diff --git a/drivers/net/dsa/mv88e6xxx/global1.c b/drivers/net/dsa/mv88e6xxx/global1.c
index 0ddf1021442b..63e3ad1ba52a 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.c
+++ b/drivers/net/dsa/mv88e6xxx/global1.c
@@ -162,14 +162,14 @@ int mv88e6185_g1_reset(struct mv88e6xxx_chip *chip)
 	/* Set the SWReset bit 15 along with the PPUEn bit 14, to also restart
 	 * the PPU, including re-doing PHY detection and initialization
 	 */
-	err = mv88e6xxx_g1_read(chip, GLOBAL_CONTROL, &val);
+	err = mv88e6xxx_g1_read(chip, MV88E6XXX_G1_CTL1, &val);
 	if (err)
 		return err;
 
-	val |= GLOBAL_CONTROL_SW_RESET;
-	val |= GLOBAL_CONTROL_PPU_ENABLE;
+	val |= MV88E6XXX_G1_CTL1_SW_RESET;
+	val |= MV88E6XXX_G1_CTL1_PPU_ENABLE;
 
-	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL, val);
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_CTL1, val);
 	if (err)
 		return err;
 
@@ -186,13 +186,13 @@ int mv88e6352_g1_reset(struct mv88e6xxx_chip *chip)
 	int err;
 
 	/* Set the SWReset bit 15 */
-	err = mv88e6xxx_g1_read(chip, GLOBAL_CONTROL, &val);
+	err = mv88e6xxx_g1_read(chip, MV88E6XXX_G1_CTL1, &val);
 	if (err)
 		return err;
 
-	val |= GLOBAL_CONTROL_SW_RESET;
+	val |= MV88E6XXX_G1_CTL1_SW_RESET;
 
-	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL, val);
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_CTL1, val);
 	if (err)
 		return err;
 
@@ -208,13 +208,13 @@ int mv88e6185_g1_ppu_enable(struct mv88e6xxx_chip *chip)
 	u16 val;
 	int err;
 
-	err = mv88e6xxx_g1_read(chip, GLOBAL_CONTROL, &val);
+	err = mv88e6xxx_g1_read(chip, MV88E6XXX_G1_CTL1, &val);
 	if (err)
 		return err;
 
-	val |= GLOBAL_CONTROL_PPU_ENABLE;
+	val |= MV88E6XXX_G1_CTL1_PPU_ENABLE;
 
-	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL, val);
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_CTL1, val);
 	if (err)
 		return err;
 
@@ -226,13 +226,13 @@ int mv88e6185_g1_ppu_disable(struct mv88e6xxx_chip *chip)
 	u16 val;
 	int err;
 
-	err = mv88e6xxx_g1_read(chip, GLOBAL_CONTROL, &val);
+	err = mv88e6xxx_g1_read(chip, MV88E6XXX_G1_CTL1, &val);
 	if (err)
 		return err;
 
-	val &= ~GLOBAL_CONTROL_PPU_ENABLE;
+	val &= ~MV88E6XXX_G1_CTL1_PPU_ENABLE;
 
-	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL, val);
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_CTL1, val);
 	if (err)
 		return err;
 
@@ -342,13 +342,13 @@ int mv88e6390_g1_stats_set_histogram(struct mv88e6xxx_chip *chip)
 	u16 val;
 	int err;
 
-	err = mv88e6xxx_g1_read(chip, GLOBAL_CONTROL_2, &val);
+	err = mv88e6xxx_g1_read(chip, MV88E6XXX_G1_CTL2, &val);
 	if (err)
 		return err;
 
-	val |= GLOBAL_CONTROL_2_HIST_RX_TX;
+	val |= MV88E6XXX_G1_CTL2_HIST_RX_TX;
 
-	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL_2, val);
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_CTL2, val);
 
 	return err;
 }
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 56ba709628c7..af1a510f7a45 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -55,21 +55,22 @@
 #define MV88E6352_G1_VTU_SID		0x03
 #define MV88E6352_G1_VTU_SID_MASK	0x3f
 
-#define GLOBAL_CONTROL		0x04
-#define GLOBAL_CONTROL_SW_RESET		BIT(15)
-#define GLOBAL_CONTROL_PPU_ENABLE	BIT(14)
-#define GLOBAL_CONTROL_DISCARD_EXCESS	BIT(13) /* 6352 */
-#define GLOBAL_CONTROL_SCHED_PRIO	BIT(11) /* 6152 */
-#define GLOBAL_CONTROL_MAX_FRAME_1632	BIT(10) /* 6152 */
-#define GLOBAL_CONTROL_RELOAD_EEPROM	BIT(9)	/* 6152 */
-#define GLOBAL_CONTROL_DEVICE_EN	BIT(7)
-#define GLOBAL_CONTROL_STATS_DONE_EN	BIT(6)
-#define GLOBAL_CONTROL_VTU_PROBLEM_EN	BIT(5)
-#define GLOBAL_CONTROL_VTU_DONE_EN	BIT(4)
-#define GLOBAL_CONTROL_ATU_PROBLEM_EN	BIT(3)
-#define GLOBAL_CONTROL_ATU_DONE_EN	BIT(2)
-#define GLOBAL_CONTROL_TCAM_EN		BIT(1)
-#define GLOBAL_CONTROL_EEPROM_DONE_EN	BIT(0)
+/* Offset 0x04: Switch Global Control Register */
+#define MV88E6XXX_G1_CTL1			0x04
+#define MV88E6XXX_G1_CTL1_SW_RESET		0x8000
+#define MV88E6XXX_G1_CTL1_PPU_ENABLE		0x4000
+#define MV88E6352_G1_CTL1_DISCARD_EXCESS	0x2000
+#define MV88E6185_G1_CTL1_SCHED_PRIO		0x0800
+#define MV88E6185_G1_CTL1_MAX_FRAME_1632	0x0400
+#define MV88E6185_G1_CTL1_RELOAD_EEPROM		0x0200
+#define MV88E6XXX_G1_CTL1_DEVICE_EN		0x0080
+#define MV88E6XXX_G1_CTL1_STATS_DONE_EN		0x0040
+#define MV88E6XXX_G1_CTL1_VTU_PROBLEM_EN	0x0020
+#define MV88E6XXX_G1_CTL1_VTU_DONE_EN		0x0010
+#define MV88E6XXX_G1_CTL1_ATU_PROBLEM_EN	0x0008
+#define MV88E6XXX_G1_CTL1_ATU_DONE_EN		0x0004
+#define MV88E6XXX_G1_CTL1_TCAM_EN		0x0002
+#define MV88E6XXX_G1_CTL1_EEPROM_DONE_EN	0x0001
 
 /* Offset 0x05: VTU Operation Register */
 #define MV88E6XXX_G1_VTU_OP			0x05
@@ -172,12 +173,15 @@
 #define GLOBAL_MONITOR_CONTROL_INGRESS			(0x20 << 8)
 #define GLOBAL_MONITOR_CONTROL_EGRESS			(0x21 << 8)
 #define GLOBAL_MONITOR_CONTROL_CPU_DEST			(0x30 << 8)
-#define GLOBAL_CONTROL_2	0x1c
-#define GLOBAL_CONTROL_2_NO_CASCADE		0xe000
-#define GLOBAL_CONTROL_2_MULTIPLE_CASCADE	0xf000
-#define GLOBAL_CONTROL_2_HIST_RX	       (0x1 << 6)
-#define GLOBAL_CONTROL_2_HIST_TX	       (0x2 << 6)
-#define GLOBAL_CONTROL_2_HIST_RX_TX	       (0x3 << 6)
+
+/* Offset 0x1C: Global Control 2 */
+#define MV88E6XXX_G1_CTL2			0x1c
+#define MV88E6XXX_G1_CTL2_NO_CASCADE		0xe000
+#define MV88E6XXX_G1_CTL2_MULTIPLE_CASCADE	0xf000
+#define MV88E6XXX_G1_CTL2_HIST_RX		0x0040
+#define MV88E6XXX_G1_CTL2_HIST_TX		0x0080
+#define MV88E6XXX_G1_CTL2_HIST_RX_TX		0x00c0
+
 #define GLOBAL_STATS_OP		0x1d
 #define GLOBAL_STATS_OP_BUSY	BIT(15)
 #define GLOBAL_STATS_OP_NOP		(0 << 12)
-- 
2.13.1
