From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 1/9] net: dsa: mv88e6xxx: move PVT description in info
Date: Thu, 30 Mar 2017 17:37:07 -0400
Message-ID: <20170330213715.9666-2-vivien.didelot@savoirfairelinux.com>
References: <20170330213715.9666-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170330213715.9666-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Not all Marvell switch chips feature a Cross-chip Port VLAN Table (PVT).

Chips with a PVT use the same implementation, so a new mv88e6xxx_ops
member won't be necessary yet. Add a "pvt" boolean member to the
mv88e6xxx_info structure and kill the obsolete MV88E6XXX_FLAGS_PVT flag.

Add a mv88e6xxx_has_pvt helper to wrap future checks of that condition.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 22 ++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/global2.c   |  2 +-
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 32 +++++++++++---------------------
 3 files changed, 34 insertions(+), 22 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 3c946af1159d..8f1f881d0375 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3578,6 +3578,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
 		.atu_move_port_mask = 0xf,
+		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6097,
 		.ops = &mv88e6085_ops,
@@ -3610,6 +3611,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
 		.atu_move_port_mask = 0xf,
+		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6097,
 		.ops = &mv88e6097_ops,
@@ -3626,6 +3628,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.atu_move_port_mask = 0xf,
+		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 		.ops = &mv88e6123_ops,
@@ -3657,6 +3660,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
 		.atu_move_port_mask = 0x1f,
+		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6341,
 		.ops = &mv88e6141_ops,
@@ -3673,6 +3677,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.atu_move_port_mask = 0xf,
+		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 		.ops = &mv88e6161_ops,
@@ -3689,6 +3694,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.atu_move_port_mask = 0xf,
+		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 		.ops = &mv88e6165_ops,
@@ -3705,6 +3711,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.atu_move_port_mask = 0xf,
+		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 		.ops = &mv88e6171_ops,
@@ -3721,6 +3728,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.atu_move_port_mask = 0xf,
+		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 		.ops = &mv88e6172_ops,
@@ -3737,6 +3745,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.atu_move_port_mask = 0xf,
+		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 		.ops = &mv88e6175_ops,
@@ -3753,6 +3762,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.atu_move_port_mask = 0xf,
+		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 		.ops = &mv88e6176_ops,
@@ -3785,6 +3795,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
+		.pvt = true,
 		.atu_move_port_mask = 0x1f,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6190_ops,
@@ -3801,6 +3812,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
 		.atu_move_port_mask = 0x1f,
+		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6190x_ops,
@@ -3817,6 +3829,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
 		.atu_move_port_mask = 0x1f,
+		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6191_ops,
@@ -3833,6 +3846,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.atu_move_port_mask = 0xf,
+		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 		.ops = &mv88e6240_ops,
@@ -3849,6 +3863,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
 		.atu_move_port_mask = 0x1f,
+		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6290_ops,
@@ -3865,6 +3880,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
 		.atu_move_port_mask = 0xf,
+		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
 		.ops = &mv88e6320_ops,
@@ -3896,6 +3912,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
 		.atu_move_port_mask = 0x1f,
+		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6341,
 		.ops = &mv88e6341_ops,
@@ -3912,6 +3929,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.atu_move_port_mask = 0xf,
+		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 		.ops = &mv88e6350_ops,
@@ -3928,6 +3946,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.atu_move_port_mask = 0xf,
+		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 		.ops = &mv88e6351_ops,
@@ -3944,6 +3963,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.atu_move_port_mask = 0xf,
+		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 		.ops = &mv88e6352_ops,
@@ -3959,6 +3979,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
 		.atu_move_port_mask = 0x1f,
+		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6390_ops,
@@ -3974,6 +3995,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
 		.atu_move_port_mask = 0x1f,
+		.pvt = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6390x_ops,
diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index 132559d46b95..6228aab2ad35 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -966,7 +966,7 @@ int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 				return err;
 	}
 
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_PVT)) {
+	if (mv88e6xxx_has_pvt(chip)) {
 		/* Initialize Cross-chip Port VLAN Table to reset defaults */
 		err = mv88e6xxx_g2_write(chip, GLOBAL2_PVT_ADDR,
 					 GLOBAL2_PVT_ADDR_OP_INIT_ONES);
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 55367d05374e..97dd3e2d2a56 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -527,8 +527,6 @@ enum mv88e6xxx_cap {
 	MV88E6XXX_CAP_G2_MGMT_EN_0X,	/* (0x03) MGMT Enable Register 0x */
 	MV88E6XXX_CAP_G2_IRL_CMD,	/* (0x09) Ingress Rate Command */
 	MV88E6XXX_CAP_G2_IRL_DATA,	/* (0x0a) Ingress Rate Data */
-	MV88E6XXX_CAP_G2_PVT_ADDR,	/* (0x0b) Cross Chip Port VLAN Addr */
-	MV88E6XXX_CAP_G2_PVT_DATA,	/* (0x0c) Cross Chip Port VLAN Data */
 	MV88E6XXX_CAP_G2_POT,		/* (0x0f) Priority Override Table */
 
 	/* Per VLAN Spanning Tree Unit (STU).
@@ -561,8 +559,6 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_G2_MGMT_EN_0X	BIT_ULL(MV88E6XXX_CAP_G2_MGMT_EN_0X)
 #define MV88E6XXX_FLAG_G2_IRL_CMD	BIT_ULL(MV88E6XXX_CAP_G2_IRL_CMD)
 #define MV88E6XXX_FLAG_G2_IRL_DATA	BIT_ULL(MV88E6XXX_CAP_G2_IRL_DATA)
-#define MV88E6XXX_FLAG_G2_PVT_ADDR	BIT_ULL(MV88E6XXX_CAP_G2_PVT_ADDR)
-#define MV88E6XXX_FLAG_G2_PVT_DATA	BIT_ULL(MV88E6XXX_CAP_G2_PVT_DATA)
 #define MV88E6XXX_FLAG_G2_POT		BIT_ULL(MV88E6XXX_CAP_G2_POT)
 
 #define MV88E6XXX_FLAG_STU		BIT_ULL(MV88E6XXX_CAP_STU)
@@ -578,11 +574,6 @@ enum mv88e6xxx_cap {
 	(MV88E6XXX_FLAG_SMI_CMD |	\
 	 MV88E6XXX_FLAG_SMI_DATA)
 
-/* Cross-chip Port VLAN Table */
-#define MV88E6XXX_FLAGS_PVT		\
-	(MV88E6XXX_FLAG_G2_PVT_ADDR |	\
-	 MV88E6XXX_FLAG_G2_PVT_DATA)
-
 /* Fiber/SERDES Registers at SMI address F, page 1 */
 #define MV88E6XXX_FLAGS_SERDES		\
 	(MV88E6XXX_FLAG_PHY_PAGE |	\
@@ -604,8 +595,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
-	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
-	 MV88E6XXX_FLAGS_PVT)
+	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6165	\
 	(MV88E6XXX_FLAG_G1_VTU_FID |	\
@@ -617,8 +607,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
-	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
-	 MV88E6XXX_FLAGS_PVT)
+	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6185	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
@@ -635,8 +624,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
-	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
-	 MV88E6XXX_FLAGS_PVT)
+	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6341	\
 	(MV88E6XXX_FLAG_EEE |		\
@@ -648,7 +636,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
-	 MV88E6XXX_FLAGS_PVT |		\
 	 MV88E6XXX_FLAGS_SERDES)
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
@@ -661,8 +648,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
-	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
-	 MV88E6XXX_FLAGS_PVT)
+	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6352	\
 	(MV88E6XXX_FLAG_EEE |		\
@@ -676,7 +662,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
-	 MV88E6XXX_FLAGS_PVT |		\
 	 MV88E6XXX_FLAGS_SERDES)
 
 #define MV88E6XXX_FLAGS_FAMILY_6390	\
@@ -686,8 +671,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
-	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
-	 MV88E6XXX_FLAGS_PVT)
+	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 struct mv88e6xxx_ops;
 
@@ -701,6 +685,7 @@ struct mv88e6xxx_info {
 	unsigned int global1_addr;
 	unsigned int age_time_coeff;
 	unsigned int g1_irqs;
+	bool pvt;
 	enum dsa_tag_protocol tag_protocol;
 	unsigned long long flags;
 
@@ -936,6 +921,11 @@ static inline bool mv88e6xxx_has(struct mv88e6xxx_chip *chip,
 	return (chip->info->flags & flags) == flags;
 }
 
+static inline bool mv88e6xxx_has_pvt(struct mv88e6xxx_chip *chip)
+{
+	return chip->info->pvt;
+}
+
 static inline unsigned int mv88e6xxx_num_databases(struct mv88e6xxx_chip *chip)
 {
 	return chip->info->num_databases;
-- 
2.12.1
