From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/8] net: dsa: mv88e6xxx: prefix Global Status macros
Date: Thu, 15 Jun 2017 12:13:59 -0400
Message-ID: <20170615161406.20546-2-vivien.didelot@savoirfairelinux.com>
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

Prefix and document the Global Status Register macros and give clear
16-bit register representation.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c    |  4 ++--
 drivers/net/dsa/mv88e6xxx/global1.c | 20 ++++++++++----------
 drivers/net/dsa/mv88e6xxx/global1.h | 36 +++++++++++++++++++-----------------
 drivers/net/dsa/mv88e6xxx/global2.c |  4 ++--
 4 files changed, 33 insertions(+), 31 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index fb950ca29081..9cc10dadf17c 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -261,7 +261,7 @@ static irqreturn_t mv88e6xxx_g1_irq_thread_fn(int irq, void *dev_id)
 	int err;
 
 	mutex_lock(&chip->reg_lock);
-	err = mv88e6xxx_g1_read(chip, GLOBAL_STATUS, &reg);
+	err = mv88e6xxx_g1_read(chip, MV88E6XXX_G1_STS, &reg);
 	mutex_unlock(&chip->reg_lock);
 
 	if (err)
@@ -381,7 +381,7 @@ static int mv88e6xxx_g1_irq_setup(struct mv88e6xxx_chip *chip)
 		goto out_disable;
 
 	/* Reading the interrupt status clears (most of) them */
-	err = mv88e6xxx_g1_read(chip, GLOBAL_STATUS, &reg);
+	err = mv88e6xxx_g1_read(chip, MV88E6XXX_G1_STS, &reg);
 	if (err)
 		goto out_disable;
 
diff --git a/drivers/net/dsa/mv88e6xxx/global1.c b/drivers/net/dsa/mv88e6xxx/global1.c
index 4081ff0d38a0..84559d22bf4e 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.c
+++ b/drivers/net/dsa/mv88e6xxx/global1.c
@@ -42,13 +42,13 @@ static int mv88e6185_g1_wait_ppu_disabled(struct mv88e6xxx_chip *chip)
 	int i, err;
 
 	for (i = 0; i < 16; i++) {
-		err = mv88e6xxx_g1_read(chip, GLOBAL_STATUS, &state);
+		err = mv88e6xxx_g1_read(chip, MV88E6XXX_G1_STS, &state);
 		if (err)
 			return err;
 
 		/* Check the value of the PPUState bits 15:14 */
-		state &= GLOBAL_STATUS_PPU_STATE_MASK;
-		if (state != GLOBAL_STATUS_PPU_STATE_POLLING)
+		state &= MV88E6185_G1_STS_PPU_STATE_MASK;
+		if (state != MV88E6185_G1_STS_PPU_STATE_POLLING)
 			return 0;
 
 		usleep_range(1000, 2000);
@@ -63,13 +63,13 @@ static int mv88e6185_g1_wait_ppu_polling(struct mv88e6xxx_chip *chip)
 	int i, err;
 
 	for (i = 0; i < 16; ++i) {
-		err = mv88e6xxx_g1_read(chip, GLOBAL_STATUS, &state);
+		err = mv88e6xxx_g1_read(chip, MV88E6XXX_G1_STS, &state);
 		if (err)
 			return err;
 
 		/* Check the value of the PPUState bits 15:14 */
-		state &= GLOBAL_STATUS_PPU_STATE_MASK;
-		if (state == GLOBAL_STATUS_PPU_STATE_POLLING)
+		state &= MV88E6185_G1_STS_PPU_STATE_MASK;
+		if (state == MV88E6185_G1_STS_PPU_STATE_POLLING)
 			return 0;
 
 		usleep_range(1000, 2000);
@@ -84,12 +84,12 @@ static int mv88e6352_g1_wait_ppu_polling(struct mv88e6xxx_chip *chip)
 	int i, err;
 
 	for (i = 0; i < 16; ++i) {
-		err = mv88e6xxx_g1_read(chip, GLOBAL_STATUS, &state);
+		err = mv88e6xxx_g1_read(chip, MV88E6XXX_G1_STS, &state);
 		if (err)
 			return err;
 
 		/* Check the value of the PPUState (or InitState) bit 15 */
-		if (state & GLOBAL_STATUS_PPU_STATE)
+		if (state & MV88E6352_G1_STS_PPU_STATE)
 			return 0;
 
 		usleep_range(1000, 2000);
@@ -109,11 +109,11 @@ static int mv88e6xxx_g1_wait_init_ready(struct mv88e6xxx_chip *chip)
 	 * have finished their initialization and are ready to accept frames.
 	 */
 	while (time_before(jiffies, timeout)) {
-		err = mv88e6xxx_g1_read(chip, GLOBAL_STATUS, &val);
+		err = mv88e6xxx_g1_read(chip, MV88E6XXX_G1_STS, &val);
 		if (err)
 			return err;
 
-		if (val & GLOBAL_STATUS_INIT_READY)
+		if (val & MV88E6XXX_G1_STS_INIT_READY)
 			break;
 
 		usleep_range(1000, 2000);
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 3e2765c53f89..7ad63a049249 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -17,23 +17,25 @@
 
 #include "chip.h"
 
-#define GLOBAL_STATUS		0x00
-#define GLOBAL_STATUS_PPU_STATE BIT(15) /* 6351 and 6171 */
-#define GLOBAL_STATUS_PPU_STATE_MASK		(0x3 << 14) /* 6165 6185 */
-#define GLOBAL_STATUS_PPU_STATE_DISABLED_RST	(0x0 << 14)
-#define GLOBAL_STATUS_PPU_STATE_INITIALIZING	(0x1 << 14)
-#define GLOBAL_STATUS_PPU_STATE_DISABLED	(0x2 << 14)
-#define GLOBAL_STATUS_PPU_STATE_POLLING		(0x3 << 14)
-#define GLOBAL_STATUS_INIT_READY	BIT(11)
-#define GLOBAL_STATUS_IRQ_AVB		8
-#define GLOBAL_STATUS_IRQ_DEVICE	7
-#define GLOBAL_STATUS_IRQ_STATS		6
-#define GLOBAL_STATUS_IRQ_VTU_PROBLEM	5
-#define GLOBAL_STATUS_IRQ_VTU_DONE	4
-#define GLOBAL_STATUS_IRQ_ATU_PROBLEM	3
-#define GLOBAL_STATUS_IRQ_ATU_DONE	2
-#define GLOBAL_STATUS_IRQ_TCAM_DONE	1
-#define GLOBAL_STATUS_IRQ_EEPROM_DONE	0
+/* Offset 0x00: Switch Global Status Register */
+#define MV88E6XXX_G1_STS				0x00
+#define MV88E6352_G1_STS_PPU_STATE			0x8000
+#define MV88E6185_G1_STS_PPU_STATE_MASK			0xc000
+#define MV88E6185_G1_STS_PPU_STATE_DISABLED_RST		0x0000
+#define MV88E6185_G1_STS_PPU_STATE_INITIALIZING		0x4000
+#define MV88E6185_G1_STS_PPU_STATE_DISABLED		0x8000
+#define MV88E6185_G1_STS_PPU_STATE_POLLING		0xc000
+#define MV88E6XXX_G1_STS_INIT_READY			0x0800
+#define MV88E6XXX_G1_STS_IRQ_AVB			8
+#define MV88E6XXX_G1_STS_IRQ_DEVICE			7
+#define MV88E6XXX_G1_STS_IRQ_STATS			6
+#define MV88E6XXX_G1_STS_IRQ_VTU_PROBLEM		5
+#define MV88E6XXX_G1_STS_IRQ_VTU_DONE			4
+#define MV88E6XXX_G1_STS_IRQ_ATU_PROBLEM		3
+#define MV88E6XXX_G1_STS_IRQ_ATU_DONE			2
+#define MV88E6XXX_G1_STS_IRQ_TCAM_DONE			1
+#define MV88E6XXX_G1_STS_IRQ_EEPROM_DONE		0
+
 #define GLOBAL_MAC_01		0x01
 #define GLOBAL_MAC_23		0x02
 #define GLOBAL_MAC_45		0x03
diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index d63af31e7840..8e8bc4ee464f 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -17,7 +17,7 @@
 #include <linux/irqdomain.h>
 
 #include "chip.h"
-#include "global1.h" /* for GLOBAL_STATUS_IRQ_DEVICE */
+#include "global1.h" /* for MV88E6XXX_G1_STS_IRQ_DEVICE */
 #include "global2.h"
 
 static int mv88e6xxx_g2_read(struct mv88e6xxx_chip *chip, int reg, u16 *val)
@@ -977,7 +977,7 @@ int mv88e6xxx_g2_irq_setup(struct mv88e6xxx_chip *chip)
 	chip->g2_irq.masked = ~0;
 
 	chip->device_irq = irq_find_mapping(chip->g1_irq.domain,
-					    GLOBAL_STATUS_IRQ_DEVICE);
+					    MV88E6XXX_G1_STS_IRQ_DEVICE);
 	if (chip->device_irq < 0) {
 		err = chip->device_irq;
 		goto out;
-- 
2.13.1
