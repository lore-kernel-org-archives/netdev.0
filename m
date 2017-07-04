From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 06/12] net: dsa: mv88e6xxx: add number of Global 2 IRQs
Date: Tue,  4 Jul 2017 19:41:49 -0400
Message-ID: <20170704234155.24360-7-vivien.didelot@savoirfairelinux.com>
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

Similarly to g1_irqs, add a g2_irqs member to the info structure to
indicates the presence of the Global 2 Interrupt Source and Mask
registers.

At the same time, provide helpers and document the registers since they
differ a bit between 88E6352 and 88E6390 families.

This allows us to get rid of the MV88E6XXX_FLAG_G2_INT flag.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c    | 27 ++++++++++++++++++++++++---
 drivers/net/dsa/mv88e6xxx/chip.h    |  9 +--------
 drivers/net/dsa/mv88e6xxx/global2.c | 22 ++++++++++++++++++++--
 drivers/net/dsa/mv88e6xxx/global2.h | 19 +++++++++++++++++--
 4 files changed, 62 insertions(+), 15 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 51f2797ecb52..1be0bc5e7c3f 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3207,6 +3207,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
+		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
@@ -3242,6 +3243,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
+		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
@@ -3260,6 +3262,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
@@ -3295,6 +3298,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
 		.atu_move_port_mask = 0x1f,
+		.g2_irqs = 10,
 		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6341,
@@ -3312,6 +3316,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
@@ -3330,6 +3335,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
@@ -3348,6 +3354,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
@@ -3366,6 +3373,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
@@ -3384,6 +3392,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
@@ -3402,6 +3411,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
@@ -3438,6 +3448,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
+		.g2_irqs = 14,
 		.pvt = true,
 		.atu_move_port_mask = 0x1f,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
@@ -3455,6 +3466,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
+		.g2_irqs = 14,
 		.atu_move_port_mask = 0x1f,
 		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
@@ -3473,6 +3485,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
+		.g2_irqs = 14,
 		.atu_move_port_mask = 0x1f,
 		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
@@ -3491,6 +3504,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
@@ -3509,6 +3523,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
+		.g2_irqs = 14,
 		.atu_move_port_mask = 0x1f,
 		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
@@ -3562,6 +3577,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
 		.atu_move_port_mask = 0x1f,
+		.g2_irqs = 10,
 		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6341,
@@ -3579,6 +3595,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
@@ -3597,6 +3614,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
@@ -3615,6 +3633,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
@@ -3632,6 +3651,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
+		.g2_irqs = 14,
 		.atu_move_port_mask = 0x1f,
 		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
@@ -3649,6 +3669,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
+		.g2_irqs = 14,
 		.atu_move_port_mask = 0x1f,
 		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
@@ -3970,7 +3991,7 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 		if (err)
 			goto out;
 
-		if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_INT)) {
+		if (chip->info->g2_irqs > 0) {
 			err = mv88e6xxx_g2_irq_setup(chip);
 			if (err)
 				goto out_g1_irq;
@@ -3990,7 +4011,7 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 out_mdio:
 	mv88e6xxx_mdios_unregister(chip);
 out_g2_irq:
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_INT) && chip->irq > 0)
+	if (chip->info->g2_irqs > 0 && chip->irq > 0)
 		mv88e6xxx_g2_irq_free(chip);
 out_g1_irq:
 	if (chip->irq > 0) {
@@ -4012,7 +4033,7 @@ static void mv88e6xxx_remove(struct mdio_device *mdiodev)
 	mv88e6xxx_mdios_unregister(chip);
 
 	if (chip->irq > 0) {
-		if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_INT))
+		if (chip->info->g2_irqs > 0)
 			mv88e6xxx_g2_irq_free(chip);
 		mv88e6xxx_g1_irq_free(chip);
 	}
diff --git a/drivers/net/dsa/mv88e6xxx/chip.h b/drivers/net/dsa/mv88e6xxx/chip.h
index 8eab123f0fed..2e760fd0ad24 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.h
+++ b/drivers/net/dsa/mv88e6xxx/chip.h
@@ -113,7 +113,6 @@ enum mv88e6xxx_cap {
 	 * The device contains a second set of global 16-bit registers.
 	 */
 	MV88E6XXX_CAP_GLOBAL2,
-	MV88E6XXX_CAP_G2_INT,		/* (0x00) Interrupt Status */
 	MV88E6XXX_CAP_G2_MGMT_EN_2X,	/* (0x02) MGMT Enable Register 2x */
 	MV88E6XXX_CAP_G2_MGMT_EN_0X,	/* (0x03) MGMT Enable Register 0x */
 	MV88E6XXX_CAP_G2_POT,		/* (0x0f) Priority Override Table */
@@ -126,7 +125,6 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_SMI_DATA		BIT_ULL(MV88E6XXX_CAP_SMI_DATA)
 
 #define MV88E6XXX_FLAG_GLOBAL2		BIT_ULL(MV88E6XXX_CAP_GLOBAL2)
-#define MV88E6XXX_FLAG_G2_INT		BIT_ULL(MV88E6XXX_CAP_G2_INT)
 #define MV88E6XXX_FLAG_G2_MGMT_EN_2X	BIT_ULL(MV88E6XXX_CAP_G2_MGMT_EN_2X)
 #define MV88E6XXX_FLAG_G2_MGMT_EN_0X	BIT_ULL(MV88E6XXX_CAP_G2_MGMT_EN_0X)
 #define MV88E6XXX_FLAG_G2_POT		BIT_ULL(MV88E6XXX_CAP_G2_POT)
@@ -143,7 +141,6 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAGS_FAMILY_6097	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAG_G2_INT |        \
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
@@ -151,7 +148,6 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAGS_FAMILY_6165	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAG_G2_INT |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
@@ -173,13 +169,11 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAGS_FAMILY_6341	\
 	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAG_G2_INT |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAG_G2_INT |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
@@ -188,7 +182,6 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAGS_FAMILY_6352	\
 	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAG_G2_INT |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
@@ -197,7 +190,6 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAGS_FAMILY_6390	\
 	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAG_G2_INT |        \
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 struct mv88e6xxx_ops;
@@ -213,6 +205,7 @@ struct mv88e6xxx_info {
 	unsigned int global1_addr;
 	unsigned int age_time_coeff;
 	unsigned int g1_irqs;
+	unsigned int g2_irqs;
 	bool pvt;
 	enum dsa_tag_protocol tag_protocol;
 	unsigned long long flags;
diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index 158d0f499874..be704c98dcbb 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -40,6 +40,21 @@ static int mv88e6xxx_g2_wait(struct mv88e6xxx_chip *chip, int reg, u16 mask)
 	return mv88e6xxx_wait(chip, MV88E6XXX_G2, reg, mask);
 }
 
+/* Offset 0x00: Interrupt Source Register */
+
+static int mv88e6xxx_g2_int_source(struct mv88e6xxx_chip *chip, u16 *src)
+{
+	/* Read (and clear most of) the Interrupt Source bits */
+	return mv88e6xxx_g2_read(chip, MV88E6XXX_G2_INT_SRC, src);
+}
+
+/* Offset 0x01: Interrupt Mask Register */
+
+static int mv88e6xxx_g2_int_mask(struct mv88e6xxx_chip *chip, u16 mask)
+{
+	return mv88e6xxx_g2_write(chip, MV88E6XXX_G2_INT_MASK, mask);
+}
+
 /* Offset 0x02: Management Enable 2x */
 /* Offset 0x03: Management Enable 0x */
 
@@ -933,7 +948,7 @@ static irqreturn_t mv88e6xxx_g2_irq_thread_fn(int irq, void *dev_id)
 	u16 reg;
 
 	mutex_lock(&chip->reg_lock);
-	err = mv88e6xxx_g2_read(chip, MV88E6XXX_G2_INT_SOURCE, &reg);
+	err = mv88e6xxx_g2_int_source(chip, &reg);
 	mutex_unlock(&chip->reg_lock);
 	if (err)
 		goto out;
@@ -959,8 +974,11 @@ static void mv88e6xxx_g2_irq_bus_lock(struct irq_data *d)
 static void mv88e6xxx_g2_irq_bus_sync_unlock(struct irq_data *d)
 {
 	struct mv88e6xxx_chip *chip = irq_data_get_irq_chip_data(d);
+	int err;
 
-	mv88e6xxx_g2_write(chip, MV88E6XXX_G2_INT_MASK, ~chip->g2_irq.masked);
+	err = mv88e6xxx_g2_int_mask(chip, ~chip->g2_irq.masked);
+	if (err)
+		dev_err(chip->dev, "failed to mask interrupts\n");
 
 	mutex_unlock(&chip->reg_lock);
 }
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index 317ffd8f323d..7b21b2556af2 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -20,11 +20,26 @@
 #define MV88E6XXX_G2	0x1c
 
 /* Offset 0x00: Interrupt Source Register */
-#define MV88E6XXX_G2_INT_SOURCE			0x00
+#define MV88E6XXX_G2_INT_SRC			0x00
+#define MV88E6XXX_G2_INT_SRC_WDOG		0x8000
+#define MV88E6XXX_G2_INT_SRC_JAM_LIMIT		0x4000
+#define MV88E6XXX_G2_INT_SRC_DUPLEX_MISMATCH	0x2000
+#define MV88E6XXX_G2_INT_SRC_WAKE_EVENT		0x1000
+#define MV88E6352_G2_INT_SRC_SERDES		0x0800
+#define MV88E6352_G2_INT_SRC_PHY		0x001f
+#define MV88E6390_G2_INT_SRC_PHY		0x07fe
+
 #define MV88E6XXX_G2_INT_SOURCE_WATCHDOG	15
 
 /* Offset 0x01: Interrupt Mask Register */
-#define MV88E6XXX_G2_INT_MASK	0x01
+#define MV88E6XXX_G2_INT_MASK			0x01
+#define MV88E6XXX_G2_INT_MASK_WDOG		0x8000
+#define MV88E6XXX_G2_INT_MASK_JAM_LIMIT		0x4000
+#define MV88E6XXX_G2_INT_MASK_DUPLEX_MISMATCH	0x2000
+#define MV88E6XXX_G2_INT_MASK_WAKE_EVENT	0x1000
+#define MV88E6352_G2_INT_MASK_SERDES		0x0800
+#define MV88E6352_G2_INT_MASK_PHY		0x001f
+#define MV88E6390_G2_INT_MASK_PHY		0x07fe
 
 /* Offset 0x02: MGMT Enable Register 2x */
 #define MV88E6XXX_G2_MGMT_EN_2X		0x02
-- 
2.13.2
