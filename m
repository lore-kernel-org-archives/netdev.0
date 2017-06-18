From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 10/10] net: dsa: mv88e6xxx: prefix Global 2 remaining macros
Date: Sat, 17 Jun 2017 23:06:41 -0400
Message-ID: <20170618030641.32463-11-vivien.didelot@savoirfairelinux.com>
References: <20170618030641.32463-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170618030641.32463-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prefix and document the remaining Global 2 registers macros.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/global2.c | 27 ++++++++-------
 drivers/net/dsa/mv88e6xxx/global2.h | 65 +++++++++++++++++++++++++------------
 2 files changed, 57 insertions(+), 35 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index ab72eaa92cc3..158d0f499874 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -1,6 +1,5 @@
 /*
- * Marvell 88E6xxx Switch Global 2 Registers support (device address
- * 0x1C)
+ * Marvell 88E6xxx Switch Global 2 Registers support
  *
  * Copyright (c) 2008 Marvell Semiconductor
  *
@@ -23,22 +22,22 @@
 
 static int mv88e6xxx_g2_read(struct mv88e6xxx_chip *chip, int reg, u16 *val)
 {
-	return mv88e6xxx_read(chip, ADDR_GLOBAL2, reg, val);
+	return mv88e6xxx_read(chip, MV88E6XXX_G2, reg, val);
 }
 
 static int mv88e6xxx_g2_write(struct mv88e6xxx_chip *chip, int reg, u16 val)
 {
-	return mv88e6xxx_write(chip, ADDR_GLOBAL2, reg, val);
+	return mv88e6xxx_write(chip, MV88E6XXX_G2, reg, val);
 }
 
 static int mv88e6xxx_g2_update(struct mv88e6xxx_chip *chip, int reg, u16 update)
 {
-	return mv88e6xxx_update(chip, ADDR_GLOBAL2, reg, update);
+	return mv88e6xxx_update(chip, MV88E6XXX_G2, reg, update);
 }
 
 static int mv88e6xxx_g2_wait(struct mv88e6xxx_chip *chip, int reg, u16 mask)
 {
-	return mv88e6xxx_wait(chip, ADDR_GLOBAL2, reg, mask);
+	return mv88e6xxx_wait(chip, MV88E6XXX_G2, reg, mask);
 }
 
 /* Offset 0x02: Management Enable 2x */
@@ -258,7 +257,7 @@ static int mv88e6xxx_g2_pot_write(struct mv88e6xxx_chip *chip, int pointer,
 {
 	u16 val = (pointer << 8) | (data & 0x7);
 
-	return mv88e6xxx_g2_update(chip, GLOBAL2_PRIO_OVERRIDE, val);
+	return mv88e6xxx_g2_update(chip, MV88E6XXX_G2_PRIO_OVERRIDE, val);
 }
 
 static int mv88e6xxx_g2_clear_pot(struct mv88e6xxx_chip *chip)
@@ -864,7 +863,7 @@ static int mv88e6xxx_g2_watchdog_setup(struct mv88e6xxx_chip *chip)
 	int err;
 
 	chip->watchdog_irq = irq_find_mapping(chip->g2_irq.domain,
-					      GLOBAL2_INT_SOURCE_WATCHDOG);
+					      MV88E6XXX_G2_INT_SOURCE_WATCHDOG);
 	if (chip->watchdog_irq < 0)
 		return chip->watchdog_irq;
 
@@ -891,16 +890,16 @@ static int mv88e6xxx_g2_misc_5_bit_port(struct mv88e6xxx_chip *chip,
 	u16 val;
 	int err;
 
-	err = mv88e6xxx_g2_read(chip, GLOBAL2_MISC, &val);
+	err = mv88e6xxx_g2_read(chip, MV88E6XXX_G2_MISC, &val);
 	if (err)
 		return err;
 
 	if (port_5_bit)
-		val |= GLOBAL2_MISC_5_BIT_PORT;
+		val |= MV88E6XXX_G2_MISC_5_BIT_PORT;
 	else
-		val &= ~GLOBAL2_MISC_5_BIT_PORT;
+		val &= ~MV88E6XXX_G2_MISC_5_BIT_PORT;
 
-	return mv88e6xxx_g2_write(chip, GLOBAL2_MISC, val);
+	return mv88e6xxx_g2_write(chip, MV88E6XXX_G2_MISC, val);
 }
 
 int mv88e6xxx_g2_misc_4_bit_port(struct mv88e6xxx_chip *chip)
@@ -934,7 +933,7 @@ static irqreturn_t mv88e6xxx_g2_irq_thread_fn(int irq, void *dev_id)
 	u16 reg;
 
 	mutex_lock(&chip->reg_lock);
-	err = mv88e6xxx_g2_read(chip, GLOBAL2_INT_SOURCE, &reg);
+	err = mv88e6xxx_g2_read(chip, MV88E6XXX_G2_INT_SOURCE, &reg);
 	mutex_unlock(&chip->reg_lock);
 	if (err)
 		goto out;
@@ -961,7 +960,7 @@ static void mv88e6xxx_g2_irq_bus_sync_unlock(struct irq_data *d)
 {
 	struct mv88e6xxx_chip *chip = irq_data_get_irq_chip_data(d);
 
-	mv88e6xxx_g2_write(chip, GLOBAL2_INT_MASK, ~chip->g2_irq.masked);
+	mv88e6xxx_g2_write(chip, MV88E6XXX_G2_INT_MASK, ~chip->g2_irq.masked);
 
 	mutex_unlock(&chip->reg_lock);
 }
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index 211e136dd7d9..392f1c493611 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -1,5 +1,5 @@
 /*
- * Marvell 88E6xxx Switch Global 2 Registers support (device address 0x1C)
+ * Marvell 88E6xxx Switch Global 2 Registers support
  *
  * Copyright (c) 2008 Marvell Semiconductor
  *
@@ -17,11 +17,14 @@
 
 #include "chip.h"
 
-#define ADDR_GLOBAL2	0x1c
+#define MV88E6XXX_G2	0x1c
 
-#define GLOBAL2_INT_SOURCE	0x00
-#define GLOBAL2_INT_SOURCE_WATCHDOG	15
-#define GLOBAL2_INT_MASK	0x01
+/* Offset 0x00: Interrupt Source Register */
+#define MV88E6XXX_G2_INT_SOURCE			0x00
+#define MV88E6XXX_G2_INT_SOURCE_WATCHDOG	15
+
+/* Offset 0x01: Interrupt Mask Register */
+#define MV88E6XXX_G2_INT_MASK	0x01
 
 /* Offset 0x02: MGMT Enable Register 2x */
 #define MV88E6XXX_G2_MGMT_EN_2X		0x02
@@ -29,7 +32,8 @@
 /* Offset 0x03: MGMT Enable Register 0x */
 #define MV88E6XXX_G2_MGMT_EN_0X		0x03
 
-#define GLOBAL2_FLOW_CONTROL	0x04
+/* Offset 0x04: Flow Control Delay Register */
+#define MV88E6XXX_G2_FLOW_CTL	0x04
 
 /* Offset 0x05: Switch Management Register */
 #define MV88E6XXX_G2_SWITCH_MGMT			0x05
@@ -98,12 +102,18 @@
 #define MV88E6XXX_G2_SWITCH_MAC_PTR_MASK	0x1f00
 #define MV88E6XXX_G2_SWITCH_MAC_DATA_MASK	0x00ff
 
-#define GLOBAL2_ATU_STATS	0x0e
-#define GLOBAL2_PRIO_OVERRIDE	0x0f
-#define GLOBAL2_PRIO_OVERRIDE_FORCE_SNOOP	BIT(7)
-#define GLOBAL2_PRIO_OVERRIDE_SNOOP_SHIFT	4
-#define GLOBAL2_PRIO_OVERRIDE_FORCE_ARP		BIT(3)
-#define GLOBAL2_PRIO_OVERRIDE_ARP_SHIFT		0
+/* Offset 0x0E: ATU Stats Register */
+#define MV88E6XXX_G2_ATU_STATS		0x0e
+
+/* Offset 0x0F: Priority Override Table */
+#define MV88E6XXX_G2_PRIO_OVERRIDE		0x0f
+#define MV88E6XXX_G2_PRIO_OVERRIDE_UPDATE	0x8000
+#define MV88E6XXX_G2_PRIO_OVERRIDE_FPRISET	0x1000
+#define MV88E6XXX_G2_PRIO_OVERRIDE_PTR_MASK	0x0f00
+#define MV88E6352_G2_PRIO_OVERRIDE_QPRIAVBEN	0x0080
+#define MV88E6352_G2_PRIO_OVERRIDE_DATAAVB_MASK	0x0030
+#define MV88E6XXX_G2_PRIO_OVERRIDE_QFPRIEN	0x0008
+#define MV88E6XXX_G2_PRIO_OVERRIDE_DATA_MASK	0x0007
 
 /* Offset 0x14: EEPROM Command */
 #define MV88E6XXX_G2_EEPROM_CMD			0x14
@@ -125,8 +135,11 @@
 #define MV88E6390_G2_EEPROM_ADDR	0x15
 #define MV88E6390_G2_EEPROM_ADDR_MASK	0xffff
 
-#define GLOBAL2_PTP_AVB_OP	0x16
-#define GLOBAL2_PTP_AVB_DATA	0x17
+/* Offset 0x16: AVB Command Register */
+#define MV88E6352_G2_AVB_CMD		0x16
+
+/* Offset 0x17: AVB Data Register */
+#define MV88E6352_G2_AVB_DATA		0x17
 
 /* Offset 0x18: SMI PHY Command Register */
 #define MV88E6XXX_G2_SMI_PHY_CMD			0x18
@@ -152,10 +165,11 @@
 /* Offset 0x19: SMI PHY Data Register */
 #define MV88E6XXX_G2_SMI_PHY_DATA	0x19
 
-#define GLOBAL2_SCRATCH_MISC	0x1a
-#define GLOBAL2_SCRATCH_BUSY		BIT(15)
-#define GLOBAL2_SCRATCH_REGISTER_SHIFT	8
-#define GLOBAL2_SCRATCH_VALUE_MASK	0xff
+/* Offset 0x1A: Scratch and Misc. Register */
+#define MV88E6XXX_G2_SCRATCH_MISC_MISC		0x1a
+#define MV88E6XXX_G2_SCRATCH_MISC_UPDATE	0x8000
+#define MV88E6XXX_G2_SCRATCH_MISC_PTR_MASK	0x7f00
+#define MV88E6XXX_G2_SCRATCH_MISC_DATA_MASK	0x00ff
 
 /* Offset 0x1B: Watch Dog Control Register */
 #define MV88E6352_G2_WDOG_CTL			0x1b
@@ -183,9 +197,18 @@
 #define MV88E6390_G2_WDOG_CTL_EGRESS			0x0002
 #define MV88E6390_G2_WDOG_CTL_FORCE_IRQ			0x0001
 
-#define GLOBAL2_QOS_WEIGHT	0x1c
-#define GLOBAL2_MISC		0x1d
-#define GLOBAL2_MISC_5_BIT_PORT	BIT(14)
+/* Offset 0x1C: QoS Weights Register */
+#define MV88E6XXX_G2_QOS_WEIGHTS		0x1c
+#define MV88E6XXX_G2_QOS_WEIGHTS_UPDATE		0x8000
+#define MV88E6352_G2_QOS_WEIGHTS_PTR_MASK	0x3f00
+#define MV88E6390_G2_QOS_WEIGHTS_PTR_MASK	0x7f00
+#define MV88E6XXX_G2_QOS_WEIGHTS_DATA_MASK	0x00ff
+
+/* Offset 0x1D: Misc Register */
+#define MV88E6XXX_G2_MISC		0x1d
+#define MV88E6XXX_G2_MISC_5_BIT_PORT	0x4000
+#define MV88E6352_G2_NOEGR_POLICY	0x2000
+#define MV88E6390_G2_LAG_ID_4		0x2000
 
 #ifdef CONFIG_NET_DSA_MV88E6XXX_GLOBAL2
 
-- 
2.13.1
