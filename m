From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 09/10] net: dsa: mv88e6xxx: prefix Global 2 Watchdog macros
Date: Mon, 19 Jun 2017 10:55:44 -0400
Message-ID: <20170619145545.26697-10-vivien.didelot@savoirfairelinux.com>
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

The Marvell 88E6352 family has a Global 2 register dedicated to the
watchdog setup. But the 88E6390 turned it into an indirect table.

Prefix and document that.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/global2.c | 48 +++++++++++++++++++------------------
 drivers/net/dsa/mv88e6xxx/global2.h | 47 ++++++++++++++++++++----------------
 2 files changed, 52 insertions(+), 43 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index 0977ba1697a6..ab72eaa92cc3 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -752,7 +752,7 @@ static int mv88e6097_watchdog_action(struct mv88e6xxx_chip *chip, int irq)
 {
 	u16 reg;
 
-	mv88e6xxx_g2_read(chip, GLOBAL2_WDOG_CONTROL, &reg);
+	mv88e6xxx_g2_read(chip, MV88E6352_G2_WDOG_CTL, &reg);
 
 	dev_info(chip->dev, "Watchdog event: 0x%04x", reg);
 
@@ -763,20 +763,20 @@ static void mv88e6097_watchdog_free(struct mv88e6xxx_chip *chip)
 {
 	u16 reg;
 
-	mv88e6xxx_g2_read(chip, GLOBAL2_WDOG_CONTROL, &reg);
+	mv88e6xxx_g2_read(chip, MV88E6352_G2_WDOG_CTL, &reg);
 
-	reg &= ~(GLOBAL2_WDOG_CONTROL_EGRESS_ENABLE |
-		 GLOBAL2_WDOG_CONTROL_QC_ENABLE);
+	reg &= ~(MV88E6352_G2_WDOG_CTL_EGRESS_ENABLE |
+		 MV88E6352_G2_WDOG_CTL_QC_ENABLE);
 
-	mv88e6xxx_g2_write(chip, GLOBAL2_WDOG_CONTROL, reg);
+	mv88e6xxx_g2_write(chip, MV88E6352_G2_WDOG_CTL, reg);
 }
 
 static int mv88e6097_watchdog_setup(struct mv88e6xxx_chip *chip)
 {
-	return mv88e6xxx_g2_write(chip, GLOBAL2_WDOG_CONTROL,
-				  GLOBAL2_WDOG_CONTROL_EGRESS_ENABLE |
-				  GLOBAL2_WDOG_CONTROL_QC_ENABLE |
-				  GLOBAL2_WDOG_CONTROL_SWRESET);
+	return mv88e6xxx_g2_write(chip, MV88E6352_G2_WDOG_CTL,
+				  MV88E6352_G2_WDOG_CTL_EGRESS_ENABLE |
+				  MV88E6352_G2_WDOG_CTL_QC_ENABLE |
+				  MV88E6352_G2_WDOG_CTL_SWRESET);
 }
 
 const struct mv88e6xxx_irq_ops mv88e6097_watchdog_ops = {
@@ -787,12 +787,12 @@ const struct mv88e6xxx_irq_ops mv88e6097_watchdog_ops = {
 
 static int mv88e6390_watchdog_setup(struct mv88e6xxx_chip *chip)
 {
-	return mv88e6xxx_g2_update(chip, GLOBAL2_WDOG_CONTROL,
-				   GLOBAL2_WDOG_INT_ENABLE |
-				   GLOBAL2_WDOG_CUT_THROUGH |
-				   GLOBAL2_WDOG_QUEUE_CONTROLLER |
-				   GLOBAL2_WDOG_EGRESS |
-				   GLOBAL2_WDOG_FORCE_IRQ);
+	return mv88e6xxx_g2_update(chip, MV88E6390_G2_WDOG_CTL,
+				   MV88E6390_G2_WDOG_CTL_PTR_INT_ENABLE |
+				   MV88E6390_G2_WDOG_CTL_CUT_THROUGH |
+				   MV88E6390_G2_WDOG_CTL_QUEUE_CONTROLLER |
+				   MV88E6390_G2_WDOG_CTL_EGRESS |
+				   MV88E6390_G2_WDOG_CTL_FORCE_IRQ);
 }
 
 static int mv88e6390_watchdog_action(struct mv88e6xxx_chip *chip, int irq)
@@ -800,17 +800,19 @@ static int mv88e6390_watchdog_action(struct mv88e6xxx_chip *chip, int irq)
 	int err;
 	u16 reg;
 
-	mv88e6xxx_g2_write(chip, GLOBAL2_WDOG_CONTROL, GLOBAL2_WDOG_EVENT);
-	err = mv88e6xxx_g2_read(chip, GLOBAL2_WDOG_CONTROL, &reg);
+	mv88e6xxx_g2_write(chip, MV88E6390_G2_WDOG_CTL,
+			   MV88E6390_G2_WDOG_CTL_PTR_EVENT);
+	err = mv88e6xxx_g2_read(chip, MV88E6390_G2_WDOG_CTL, &reg);
 
 	dev_info(chip->dev, "Watchdog event: 0x%04x",
-		 reg & GLOBAL2_WDOG_DATA_MASK);
+		 reg & MV88E6390_G2_WDOG_CTL_DATA_MASK);
 
-	mv88e6xxx_g2_write(chip, GLOBAL2_WDOG_CONTROL, GLOBAL2_WDOG_HISTORY);
-	err = mv88e6xxx_g2_read(chip, GLOBAL2_WDOG_CONTROL, &reg);
+	mv88e6xxx_g2_write(chip, MV88E6390_G2_WDOG_CTL,
+			   MV88E6390_G2_WDOG_CTL_PTR_HISTORY);
+	err = mv88e6xxx_g2_read(chip, MV88E6390_G2_WDOG_CTL, &reg);
 
 	dev_info(chip->dev, "Watchdog history: 0x%04x",
-		 reg & GLOBAL2_WDOG_DATA_MASK);
+		 reg & MV88E6390_G2_WDOG_CTL_DATA_MASK);
 
 	/* Trigger a software reset to try to recover the switch */
 	if (chip->info->ops->reset)
@@ -823,8 +825,8 @@ static int mv88e6390_watchdog_action(struct mv88e6xxx_chip *chip, int irq)
 
 static void mv88e6390_watchdog_free(struct mv88e6xxx_chip *chip)
 {
-	mv88e6xxx_g2_update(chip, GLOBAL2_WDOG_CONTROL,
-			    GLOBAL2_WDOG_INT_ENABLE);
+	mv88e6xxx_g2_update(chip, MV88E6390_G2_WDOG_CTL,
+			    MV88E6390_G2_WDOG_CTL_PTR_INT_ENABLE);
 }
 
 const struct mv88e6xxx_irq_ops mv88e6390_watchdog_ops = {
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index 6b17343e481e..1f75e7a88633 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -156,26 +156,33 @@
 #define GLOBAL2_SCRATCH_BUSY		BIT(15)
 #define GLOBAL2_SCRATCH_REGISTER_SHIFT	8
 #define GLOBAL2_SCRATCH_VALUE_MASK	0xff
-#define GLOBAL2_WDOG_CONTROL	0x1b
-#define GLOBAL2_WDOG_CONTROL_EGRESS_EVENT	BIT(7)
-#define GLOBAL2_WDOG_CONTROL_RMU_TIMEOUT	BIT(6)
-#define GLOBAL2_WDOG_CONTROL_QC_ENABLE		BIT(5)
-#define GLOBAL2_WDOG_CONTROL_EGRESS_HISTORY	BIT(4)
-#define GLOBAL2_WDOG_CONTROL_EGRESS_ENABLE	BIT(3)
-#define GLOBAL2_WDOG_CONTROL_FORCE_IRQ		BIT(2)
-#define GLOBAL2_WDOG_CONTROL_HISTORY		BIT(1)
-#define GLOBAL2_WDOG_CONTROL_SWRESET		BIT(0)
-#define GLOBAL2_WDOG_UPDATE			BIT(15)
-#define GLOBAL2_WDOG_INT_SOURCE			(0x00 << 8)
-#define GLOBAL2_WDOG_INT_STATUS			(0x10 << 8)
-#define GLOBAL2_WDOG_INT_ENABLE			(0x11 << 8)
-#define GLOBAL2_WDOG_EVENT			(0x12 << 8)
-#define GLOBAL2_WDOG_HISTORY			(0x13 << 8)
-#define GLOBAL2_WDOG_DATA_MASK			0xff
-#define GLOBAL2_WDOG_CUT_THROUGH		BIT(3)
-#define GLOBAL2_WDOG_QUEUE_CONTROLLER		BIT(2)
-#define GLOBAL2_WDOG_EGRESS			BIT(1)
-#define GLOBAL2_WDOG_FORCE_IRQ			BIT(0)
+
+/* Offset 0x1B: Watch Dog Control Register */
+#define MV88E6352_G2_WDOG_CTL			0x1b
+#define MV88E6352_G2_WDOG_CTL_EGRESS_EVENT	0x0080
+#define MV88E6352_G2_WDOG_CTL_RMU_TIMEOUT	0x0040
+#define MV88E6352_G2_WDOG_CTL_QC_ENABLE		0x0020
+#define MV88E6352_G2_WDOG_CTL_EGRESS_HISTORY	0x0010
+#define MV88E6352_G2_WDOG_CTL_EGRESS_ENABLE	0x0008
+#define MV88E6352_G2_WDOG_CTL_FORCE_IRQ		0x0004
+#define MV88E6352_G2_WDOG_CTL_HISTORY		0x0002
+#define MV88E6352_G2_WDOG_CTL_SWRESET		0x0001
+
+/* Offset 0x1B: Watch Dog Control Register */
+#define MV88E6390_G2_WDOG_CTL				0x1b
+#define MV88E6390_G2_WDOG_CTL_UPDATE			0x8000
+#define MV88E6390_G2_WDOG_CTL_PTR_MASK			0x7f00
+#define MV88E6390_G2_WDOG_CTL_PTR_INT_SOURCE		0x0000
+#define MV88E6390_G2_WDOG_CTL_PTR_INT_STS		0x1000
+#define MV88E6390_G2_WDOG_CTL_PTR_INT_ENABLE		0x1100
+#define MV88E6390_G2_WDOG_CTL_PTR_EVENT			0x1200
+#define MV88E6390_G2_WDOG_CTL_PTR_HISTORY		0x1300
+#define MV88E6390_G2_WDOG_CTL_DATA_MASK			0x00ff
+#define MV88E6390_G2_WDOG_CTL_CUT_THROUGH		0x0008
+#define MV88E6390_G2_WDOG_CTL_QUEUE_CONTROLLER		0x0004
+#define MV88E6390_G2_WDOG_CTL_EGRESS			0x0002
+#define MV88E6390_G2_WDOG_CTL_FORCE_IRQ			0x0001
+
 #define GLOBAL2_QOS_WEIGHT	0x1c
 #define GLOBAL2_MISC		0x1d
 #define GLOBAL2_MISC_5_BIT_PORT	BIT(14)
-- 
2.13.1
