From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 10/12] net: dsa: mv88e6xxx: add a global2_addr info flag
Date: Tue,  4 Jul 2017 19:41:53 -0400
Message-ID: <20170704234155.24360-11-vivien.didelot@savoirfairelinux.com>
References: <20170704234155.24360-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170704234155.24360-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Similarly to global1_addr, add a global2_addr member in the info
structure to describe the presence of the Global 2 Registers.

This allows us to get rid of the MV88E6XXX_FLAG_GLOBAL2 flag.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c    | 28 +++++++++++++++++++++++++++-
 drivers/net/dsa/mv88e6xxx/chip.h    | 27 ++++++---------------------
 drivers/net/dsa/mv88e6xxx/global2.c |  8 ++++----
 drivers/net/dsa/mv88e6xxx/global2.h |  4 +---
 4 files changed, 38 insertions(+), 29 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 6351230f82ad..eb4871a66076 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2132,7 +2132,7 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
 		goto unlock;
 
 	/* Setup Switch Global 2 Registers */
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_GLOBAL2)) {
+	if (chip->info->global2_addr) {
 		err = mv88e6xxx_g2_setup(chip);
 		if (err)
 			goto unlock;
@@ -3240,6 +3240,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
 		.g2_irqs = 10,
@@ -3259,6 +3260,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
 		.atu_move_port_mask = 0xf,
@@ -3276,6 +3278,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
 		.g2_irqs = 10,
@@ -3295,6 +3298,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.g2_irqs = 10,
@@ -3314,6 +3318,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.atu_move_port_mask = 0xf,
@@ -3331,6 +3336,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.age_time_coeff = 3750,
 		.atu_move_port_mask = 0x1f,
 		.g2_irqs = 10,
@@ -3349,6 +3355,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.g2_irqs = 10,
@@ -3368,6 +3375,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.g2_irqs = 10,
@@ -3387,6 +3395,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.g2_irqs = 10,
@@ -3406,6 +3415,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.g2_irqs = 10,
@@ -3425,6 +3435,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.g2_irqs = 10,
@@ -3444,6 +3455,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.g2_irqs = 10,
@@ -3463,6 +3475,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
 		.atu_move_port_mask = 0xf,
@@ -3480,6 +3493,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 8191,
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
@@ -3499,6 +3513,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 8191,
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
 		.g2_irqs = 14,
@@ -3518,6 +3533,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 8191,
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
 		.g2_irqs = 14,
@@ -3537,6 +3553,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.g2_irqs = 10,
@@ -3556,6 +3573,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 8191,
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
 		.g2_irqs = 14,
@@ -3575,6 +3593,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
 		.atu_move_port_mask = 0xf,
@@ -3593,6 +3612,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
 		.atu_move_port_mask = 0xf,
@@ -3610,6 +3630,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.age_time_coeff = 3750,
 		.atu_move_port_mask = 0x1f,
 		.g2_irqs = 10,
@@ -3628,6 +3649,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.g2_irqs = 10,
@@ -3647,6 +3669,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.g2_irqs = 10,
@@ -3666,6 +3689,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.g2_irqs = 10,
@@ -3684,6 +3708,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 8191,
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
 		.g2_irqs = 14,
@@ -3702,6 +3727,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.max_vid = 8191,
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
+		.global2_addr = 0x1c,
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
 		.g2_irqs = 14,
diff --git a/drivers/net/dsa/mv88e6xxx/chip.h b/drivers/net/dsa/mv88e6xxx/chip.h
index 822286250aff..15b793446400 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.h
+++ b/drivers/net/dsa/mv88e6xxx/chip.h
@@ -108,11 +108,6 @@ enum mv88e6xxx_cap {
 	 */
 	MV88E6XXX_CAP_SMI_CMD,		/* (0x00) SMI Command */
 	MV88E6XXX_CAP_SMI_DATA,		/* (0x01) SMI Data */
-
-	/* Switch Global 2 Registers.
-	 * The device contains a second set of global 16-bit registers.
-	 */
-	MV88E6XXX_CAP_GLOBAL2,
 };
 
 /* Bitmask of capabilities */
@@ -121,51 +116,40 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_SMI_CMD		BIT_ULL(MV88E6XXX_CAP_SMI_CMD)
 #define MV88E6XXX_FLAG_SMI_DATA		BIT_ULL(MV88E6XXX_CAP_SMI_DATA)
 
-#define MV88E6XXX_FLAG_GLOBAL2		BIT_ULL(MV88E6XXX_CAP_GLOBAL2)
-
 /* Multi-chip Addressing Mode */
 #define MV88E6XXX_FLAGS_MULTI_CHIP	\
 	(MV88E6XXX_FLAG_SMI_CMD |	\
 	 MV88E6XXX_FLAG_SMI_DATA)
 
 #define MV88E6XXX_FLAGS_FAMILY_6095	\
-	(MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAGS_MULTI_CHIP)
+	(MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6097	\
-	(MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAGS_MULTI_CHIP)
+	(MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6165	\
-	(MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAGS_MULTI_CHIP)
+	(MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6185	\
-	(MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAGS_MULTI_CHIP)
+	(MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6320	\
 	(MV88E6XXX_FLAG_EEE |		\
-	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6341	\
 	(MV88E6XXX_FLAG_EEE |		\
-	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
-	(MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAGS_MULTI_CHIP)
+	(MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6352	\
 	(MV88E6XXX_FLAG_EEE |		\
-	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6390	\
 	(MV88E6XXX_FLAG_EEE |		\
-	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 struct mv88e6xxx_ops;
@@ -179,6 +163,7 @@ struct mv88e6xxx_info {
 	unsigned int max_vid;
 	unsigned int port_base_addr;
 	unsigned int global1_addr;
+	unsigned int global2_addr;
 	unsigned int age_time_coeff;
 	unsigned int g1_irqs;
 	unsigned int g2_irqs;
diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index aaf98e818d0d..16f556261022 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -22,22 +22,22 @@
 
 static int mv88e6xxx_g2_read(struct mv88e6xxx_chip *chip, int reg, u16 *val)
 {
-	return mv88e6xxx_read(chip, MV88E6XXX_G2, reg, val);
+	return mv88e6xxx_read(chip, chip->info->global2_addr, reg, val);
 }
 
 static int mv88e6xxx_g2_write(struct mv88e6xxx_chip *chip, int reg, u16 val)
 {
-	return mv88e6xxx_write(chip, MV88E6XXX_G2, reg, val);
+	return mv88e6xxx_write(chip, chip->info->global2_addr, reg, val);
 }
 
 static int mv88e6xxx_g2_update(struct mv88e6xxx_chip *chip, int reg, u16 update)
 {
-	return mv88e6xxx_update(chip, MV88E6XXX_G2, reg, update);
+	return mv88e6xxx_update(chip, chip->info->global2_addr, reg, update);
 }
 
 static int mv88e6xxx_g2_wait(struct mv88e6xxx_chip *chip, int reg, u16 mask)
 {
-	return mv88e6xxx_wait(chip, MV88E6XXX_G2, reg, mask);
+	return mv88e6xxx_wait(chip, chip->info->global2_addr, reg, mask);
 }
 
 /* Offset 0x00: Interrupt Source Register */
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index d89d7b810a45..669f59017b12 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -17,8 +17,6 @@
 
 #include "chip.h"
 
-#define MV88E6XXX_G2	0x1c
-
 /* Offset 0x00: Interrupt Source Register */
 #define MV88E6XXX_G2_INT_SRC			0x00
 #define MV88E6XXX_G2_INT_SRC_WDOG		0x8000
@@ -273,7 +271,7 @@ extern const struct mv88e6xxx_irq_ops mv88e6390_watchdog_ops;
 
 static inline int mv88e6xxx_g2_require(struct mv88e6xxx_chip *chip)
 {
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_GLOBAL2)) {
+	if (chip->info->global2_addr) {
 		dev_err(chip->dev, "this chip requires CONFIG_NET_DSA_MV88E6XXX_GLOBAL2 enabled\n");
 		return -EOPNOTSUPP;
 	}
-- 
2.13.2
