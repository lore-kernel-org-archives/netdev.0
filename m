From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 12/12] net: dsa: mv88e6xxx: add a multi_chip info flag
Date: Tue,  4 Jul 2017 19:41:55 -0400
Message-ID: <20170704234155.24360-13-vivien.didelot@savoirfairelinux.com>
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

Instead of relying on a bitmap flag, add a new multi_chip info flag to
describe the presence of the indirect SMI access though the two device
registers 0x0 and 0x1.

All remaining capabilities and flags are now unused. Remove the
mv88e6xxx_cap enum and the info flags bitmaps.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 54 ++++++++++++++++++-------------------
 drivers/net/dsa/mv88e6xxx/chip.h | 58 +++++-----------------------------------
 2 files changed, 33 insertions(+), 79 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index be61983dfed4..947ea352a57a 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3267,8 +3267,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
+		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6097,
 		.ops = &mv88e6085_ops,
 	},
 
@@ -3285,8 +3285,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
 		.atu_move_port_mask = 0xf,
+		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6095,
 		.ops = &mv88e6095_ops,
 	},
 
@@ -3305,8 +3305,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
+		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6097,
 		.ops = &mv88e6097_ops,
 	},
 
@@ -3325,8 +3325,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
+		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 		.ops = &mv88e6123_ops,
 	},
 
@@ -3343,8 +3343,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.atu_move_port_mask = 0xf,
+		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
 		.ops = &mv88e6131_ops,
 	},
 
@@ -3362,8 +3362,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.atu_move_port_mask = 0x1f,
 		.g2_irqs = 10,
 		.pvt = true,
+		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6341,
 		.ops = &mv88e6141_ops,
 	},
 
@@ -3382,8 +3382,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
+		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 		.ops = &mv88e6161_ops,
 	},
 
@@ -3402,8 +3402,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
+		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 		.ops = &mv88e6165_ops,
 	},
 
@@ -3422,8 +3422,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
+		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 		.ops = &mv88e6171_ops,
 	},
 
@@ -3442,8 +3442,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
+		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 		.ops = &mv88e6172_ops,
 	},
 
@@ -3462,8 +3462,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
+		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 		.ops = &mv88e6175_ops,
 	},
 
@@ -3482,8 +3482,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
+		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 		.ops = &mv88e6176_ops,
 	},
 
@@ -3500,8 +3500,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
 		.atu_move_port_mask = 0xf,
+		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
 		.ops = &mv88e6185_ops,
 	},
 
@@ -3520,8 +3520,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.g1_irqs = 9,
 		.g2_irqs = 14,
 		.pvt = true,
+		.multi_chip = true,
 		.atu_move_port_mask = 0x1f,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6190_ops,
 	},
 
@@ -3540,8 +3540,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.g2_irqs = 14,
 		.atu_move_port_mask = 0x1f,
 		.pvt = true,
+		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6190x_ops,
 	},
 
@@ -3560,8 +3560,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.g2_irqs = 14,
 		.atu_move_port_mask = 0x1f,
 		.pvt = true,
+		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6191_ops,
 	},
 
@@ -3580,8 +3580,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
+		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 		.ops = &mv88e6240_ops,
 	},
 
@@ -3600,8 +3600,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.g2_irqs = 14,
 		.atu_move_port_mask = 0x1f,
 		.pvt = true,
+		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6290_ops,
 	},
 
@@ -3619,8 +3619,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.g1_irqs = 8,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
+		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
 		.ops = &mv88e6320_ops,
 	},
 
@@ -3637,8 +3637,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
 		.atu_move_port_mask = 0xf,
+		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
 		.ops = &mv88e6321_ops,
 	},
 
@@ -3656,8 +3656,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.atu_move_port_mask = 0x1f,
 		.g2_irqs = 10,
 		.pvt = true,
+		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6341,
 		.ops = &mv88e6341_ops,
 	},
 
@@ -3676,8 +3676,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
+		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 		.ops = &mv88e6350_ops,
 	},
 
@@ -3696,8 +3696,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
+		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 		.ops = &mv88e6351_ops,
 	},
 
@@ -3716,8 +3716,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.g2_irqs = 10,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
+		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 		.ops = &mv88e6352_ops,
 	},
 	[MV88E6390] = {
@@ -3735,8 +3735,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.g2_irqs = 14,
 		.atu_move_port_mask = 0x1f,
 		.pvt = true,
+		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6390_ops,
 	},
 	[MV88E6390X] = {
@@ -3754,8 +3754,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.g2_irqs = 14,
 		.atu_move_port_mask = 0x1f,
 		.pvt = true,
+		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
-		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6390x_ops,
 	},
 };
@@ -3825,7 +3825,7 @@ static int mv88e6xxx_smi_init(struct mv88e6xxx_chip *chip,
 {
 	if (sw_addr == 0)
 		chip->smi_ops = &mv88e6xxx_smi_single_chip_ops;
-	else if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_MULTI_CHIP))
+	else if (chip->info->multi_chip)
 		chip->smi_ops = &mv88e6xxx_smi_multi_chip_ops;
 	else
 		return -EINVAL;
diff --git a/drivers/net/dsa/mv88e6xxx/chip.h b/drivers/net/dsa/mv88e6xxx/chip.h
index 3fbee01d2d84..9111e1316250 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.h
+++ b/drivers/net/dsa/mv88e6xxx/chip.h
@@ -97,51 +97,6 @@ enum mv88e6xxx_family {
 	MV88E6XXX_FAMILY_6390,  /* 6190 6190X 6191 6290 6390 6390X */
 };
 
-enum mv88e6xxx_cap {
-	/* Multi-chip Addressing Mode.
-	 * Some chips respond to only 2 registers of its own SMI device address
-	 * when it is non-zero, and use indirect access to internal registers.
-	 */
-	MV88E6XXX_CAP_SMI_CMD,		/* (0x00) SMI Command */
-	MV88E6XXX_CAP_SMI_DATA,		/* (0x01) SMI Data */
-};
-
-/* Bitmask of capabilities */
-#define MV88E6XXX_FLAG_SMI_CMD		BIT_ULL(MV88E6XXX_CAP_SMI_CMD)
-#define MV88E6XXX_FLAG_SMI_DATA		BIT_ULL(MV88E6XXX_CAP_SMI_DATA)
-
-/* Multi-chip Addressing Mode */
-#define MV88E6XXX_FLAGS_MULTI_CHIP	\
-	(MV88E6XXX_FLAG_SMI_CMD |	\
-	 MV88E6XXX_FLAG_SMI_DATA)
-
-#define MV88E6XXX_FLAGS_FAMILY_6095	\
-	(MV88E6XXX_FLAGS_MULTI_CHIP)
-
-#define MV88E6XXX_FLAGS_FAMILY_6097	\
-	(MV88E6XXX_FLAGS_MULTI_CHIP)
-
-#define MV88E6XXX_FLAGS_FAMILY_6165	\
-	(MV88E6XXX_FLAGS_MULTI_CHIP)
-
-#define MV88E6XXX_FLAGS_FAMILY_6185	\
-	(MV88E6XXX_FLAGS_MULTI_CHIP)
-
-#define MV88E6XXX_FLAGS_FAMILY_6320	\
-	(MV88E6XXX_FLAGS_MULTI_CHIP)
-
-#define MV88E6XXX_FLAGS_FAMILY_6341	\
-	(MV88E6XXX_FLAGS_MULTI_CHIP)
-
-#define MV88E6XXX_FLAGS_FAMILY_6351	\
-	(MV88E6XXX_FLAGS_MULTI_CHIP)
-
-#define MV88E6XXX_FLAGS_FAMILY_6352	\
-	(MV88E6XXX_FLAGS_MULTI_CHIP)
-
-#define MV88E6XXX_FLAGS_FAMILY_6390	\
-	(MV88E6XXX_FLAGS_MULTI_CHIP)
-
 struct mv88e6xxx_ops;
 
 struct mv88e6xxx_info {
@@ -158,8 +113,13 @@ struct mv88e6xxx_info {
 	unsigned int g1_irqs;
 	unsigned int g2_irqs;
 	bool pvt;
+
+	/* Multi-chip Addressing Mode.
+	 * Some chips respond to only 2 registers of its own SMI device address
+	 * when it is non-zero, and use indirect access to internal registers.
+	 */
+	bool multi_chip;
 	enum dsa_tag_protocol tag_protocol;
-	unsigned long long flags;
 
 	/* Mask for FromPort and ToPort value of PortVec used in ATU Move
 	 * operation. 0 means that the ATU Move operation is not supported.
@@ -410,12 +370,6 @@ struct mv88e6xxx_hw_stat {
 	int type;
 };
 
-static inline bool mv88e6xxx_has(struct mv88e6xxx_chip *chip,
-				 unsigned long flags)
-{
-	return (chip->info->flags & flags) == flags;
-}
-
 static inline bool mv88e6xxx_has_pvt(struct mv88e6xxx_chip *chip)
 {
 	return chip->info->pvt;
-- 
2.13.2
