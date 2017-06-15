From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 7/8] net: dsa: mv88e6xxx: prefix Global Stats macros
Date: Thu, 15 Jun 2017 12:14:05 -0400
Message-ID: <20170615161406.20546-8-vivien.didelot@savoirfairelinux.com>
References: <20170615161406.20546-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48608 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751016AbdFOQQX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 12:16:23 -0400
In-Reply-To: <20170615161406.20546-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prefix and document the Global Stats Operation and Counter registers and
give them a clear 16-bit registers representation.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c    | 14 ++++++++------
 drivers/net/dsa/mv88e6xxx/global1.c | 24 ++++++++++++++----------
 drivers/net/dsa/mv88e6xxx/global1.h | 33 +++++++++++++++++++--------------
 3 files changed, 41 insertions(+), 30 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index c31ad01c7f96..46e8d1871847 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -725,7 +725,7 @@ static void mv88e6095_stats_get_stats(struct mv88e6xxx_chip *chip, int port,
 {
 	return mv88e6xxx_stats_get_stats(chip, port, data,
 					 STATS_TYPE_BANK0 | STATS_TYPE_PORT,
-					 0, GLOBAL_STATS_OP_HIST_RX_TX);
+					 0, MV88E6XXX_G1_STATS_OP_HIST_RX_TX);
 }
 
 static void mv88e6320_stats_get_stats(struct mv88e6xxx_chip *chip, int port,
@@ -733,8 +733,8 @@ static void mv88e6320_stats_get_stats(struct mv88e6xxx_chip *chip, int port,
 {
 	return mv88e6xxx_stats_get_stats(chip, port, data,
 					 STATS_TYPE_BANK0 | STATS_TYPE_BANK1,
-					 GLOBAL_STATS_OP_BANK_1_BIT_9,
-					 GLOBAL_STATS_OP_HIST_RX_TX);
+					 MV88E6XXX_G1_STATS_OP_BANK_1_BIT_9,
+					 MV88E6XXX_G1_STATS_OP_HIST_RX_TX);
 }
 
 static void mv88e6390_stats_get_stats(struct mv88e6xxx_chip *chip, int port,
@@ -742,7 +742,8 @@ static void mv88e6390_stats_get_stats(struct mv88e6xxx_chip *chip, int port,
 {
 	return mv88e6xxx_stats_get_stats(chip, port, data,
 					 STATS_TYPE_BANK0 | STATS_TYPE_BANK1,
-					 GLOBAL_STATS_OP_BANK_1_BIT_10, 0);
+					 MV88E6XXX_G1_STATS_OP_BANK_1_BIT_10,
+					 0);
 }
 
 static void mv88e6xxx_get_stats(struct mv88e6xxx_chip *chip, int port,
@@ -2057,8 +2058,9 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 		return err;
 
 	/* Clear the statistics counters for all ports */
-	err = mv88e6xxx_g1_write(chip, GLOBAL_STATS_OP,
-				 GLOBAL_STATS_OP_FLUSH_ALL);
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_STATS_OP,
+				 MV88E6XXX_G1_STATS_OP_BUSY |
+				 MV88E6XXX_G1_STATS_OP_FLUSH_ALL);
 	if (err)
 		return err;
 
diff --git a/drivers/net/dsa/mv88e6xxx/global1.c b/drivers/net/dsa/mv88e6xxx/global1.c
index ee77840d5271..d76d7c7ea819 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.c
+++ b/drivers/net/dsa/mv88e6xxx/global1.c
@@ -370,7 +370,8 @@ int mv88e6390_g1_stats_set_histogram(struct mv88e6xxx_chip *chip)
 
 int mv88e6xxx_g1_stats_wait(struct mv88e6xxx_chip *chip)
 {
-	return mv88e6xxx_g1_wait(chip, GLOBAL_STATS_OP, GLOBAL_STATS_OP_BUSY);
+	return mv88e6xxx_g1_wait(chip, MV88E6XXX_G1_STATS_OP,
+				 MV88E6XXX_G1_STATS_OP_BUSY);
 }
 
 int mv88e6xxx_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port)
@@ -378,9 +379,10 @@ int mv88e6xxx_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port)
 	int err;
 
 	/* Snapshot the hardware statistics counters for this port. */
-	err = mv88e6xxx_g1_write(chip, GLOBAL_STATS_OP,
-				 GLOBAL_STATS_OP_CAPTURE_PORT |
-				 GLOBAL_STATS_OP_HIST_RX_TX | port);
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_STATS_OP,
+				 MV88E6XXX_G1_STATS_OP_BUSY |
+				 MV88E6XXX_G1_STATS_OP_CAPTURE_PORT |
+				 MV88E6XXX_G1_STATS_OP_HIST_RX_TX | port);
 	if (err)
 		return err;
 
@@ -402,8 +404,9 @@ int mv88e6390_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port)
 	port = (port + 1) << 5;
 
 	/* Snapshot the hardware statistics counters for this port. */
-	err = mv88e6xxx_g1_write(chip, GLOBAL_STATS_OP,
-				 GLOBAL_STATS_OP_CAPTURE_PORT | port);
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_STATS_OP,
+				 MV88E6XXX_G1_STATS_OP_BUSY |
+				 MV88E6XXX_G1_STATS_OP_CAPTURE_PORT | port);
 	if (err)
 		return err;
 
@@ -419,8 +422,9 @@ void mv88e6xxx_g1_stats_read(struct mv88e6xxx_chip *chip, int stat, u32 *val)
 
 	*val = 0;
 
-	err = mv88e6xxx_g1_write(chip, GLOBAL_STATS_OP,
-				 GLOBAL_STATS_OP_READ_CAPTURED | stat);
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_STATS_OP,
+				 MV88E6XXX_G1_STATS_OP_BUSY |
+				 MV88E6XXX_G1_STATS_OP_READ_CAPTURED | stat);
 	if (err)
 		return;
 
@@ -428,13 +432,13 @@ void mv88e6xxx_g1_stats_read(struct mv88e6xxx_chip *chip, int stat, u32 *val)
 	if (err)
 		return;
 
-	err = mv88e6xxx_g1_read(chip, GLOBAL_STATS_COUNTER_32, &reg);
+	err = mv88e6xxx_g1_read(chip, MV88E6XXX_G1_STATS_COUNTER_32, &reg);
 	if (err)
 		return;
 
 	value = reg << 16;
 
-	err = mv88e6xxx_g1_read(chip, GLOBAL_STATS_COUNTER_01, &reg);
+	err = mv88e6xxx_g1_read(chip, MV88E6XXX_G1_STATS_COUNTER_01, &reg);
 	if (err)
 		return;
 
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 020b21c0c9c3..16c21bd671c5 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -186,20 +186,25 @@
 #define MV88E6XXX_G1_CTL2_HIST_TX		0x0080
 #define MV88E6XXX_G1_CTL2_HIST_RX_TX		0x00c0
 
-#define GLOBAL_STATS_OP		0x1d
-#define GLOBAL_STATS_OP_BUSY	BIT(15)
-#define GLOBAL_STATS_OP_NOP		(0 << 12)
-#define GLOBAL_STATS_OP_FLUSH_ALL	((1 << 12) | GLOBAL_STATS_OP_BUSY)
-#define GLOBAL_STATS_OP_FLUSH_PORT	((2 << 12) | GLOBAL_STATS_OP_BUSY)
-#define GLOBAL_STATS_OP_READ_CAPTURED	((4 << 12) | GLOBAL_STATS_OP_BUSY)
-#define GLOBAL_STATS_OP_CAPTURE_PORT	((5 << 12) | GLOBAL_STATS_OP_BUSY)
-#define GLOBAL_STATS_OP_HIST_RX		((1 << 10) | GLOBAL_STATS_OP_BUSY)
-#define GLOBAL_STATS_OP_HIST_TX		((2 << 10) | GLOBAL_STATS_OP_BUSY)
-#define GLOBAL_STATS_OP_HIST_RX_TX	((3 << 10) | GLOBAL_STATS_OP_BUSY)
-#define GLOBAL_STATS_OP_BANK_1_BIT_9	BIT(9)
-#define GLOBAL_STATS_OP_BANK_1_BIT_10	BIT(10)
-#define GLOBAL_STATS_COUNTER_32	0x1e
-#define GLOBAL_STATS_COUNTER_01	0x1f
+/* Offset 0x1D: Stats Operation Register */
+#define MV88E6XXX_G1_STATS_OP			0x1d
+#define MV88E6XXX_G1_STATS_OP_BUSY		0x8000
+#define MV88E6XXX_G1_STATS_OP_NOP		0x0000
+#define MV88E6XXX_G1_STATS_OP_FLUSH_ALL		0x1000
+#define MV88E6XXX_G1_STATS_OP_FLUSH_PORT	0x2000
+#define MV88E6XXX_G1_STATS_OP_READ_CAPTURED	0x4000
+#define MV88E6XXX_G1_STATS_OP_CAPTURE_PORT	0x5000
+#define MV88E6XXX_G1_STATS_OP_HIST_RX		0x0400
+#define MV88E6XXX_G1_STATS_OP_HIST_TX		0x0800
+#define MV88E6XXX_G1_STATS_OP_HIST_RX_TX	0x0c00
+#define MV88E6XXX_G1_STATS_OP_BANK_1_BIT_9	0x0200
+#define MV88E6XXX_G1_STATS_OP_BANK_1_BIT_10	0x0400
+
+/* Offset 0x1E: Stats Counter Register Bytes 3 & 2
+ * Offset 0x1F: Stats Counter Register Bytes 1 & 0
+ */
+#define MV88E6XXX_G1_STATS_COUNTER_32	0x1e
+#define MV88E6XXX_G1_STATS_COUNTER_01	0x1f
 
 int mv88e6xxx_g1_read(struct mv88e6xxx_chip *chip, int reg, u16 *val);
 int mv88e6xxx_g1_write(struct mv88e6xxx_chip *chip, int reg, u16 val);
-- 
2.13.1
