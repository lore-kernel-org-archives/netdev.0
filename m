From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 3/6] net: dsa: mv88e6xxx: add support for 6390 ATU Move
Date: Fri, 17 Feb 2017 10:05:28 -0500
Message-ID: <20170217150531.2181-4-vivien.didelot@savoirfairelinux.com>
References: <20170217150531.2181-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170217150531.2181-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 6390 family of Marvell chips uses 5 bits to describe the ToPort and
FromPort values of PortVec in the ATU Move operation, while older
switches use 0xf.

Add an atu_move_port_mask member in the info structure to describe that.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c        | 26 ++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/global1_atu.c | 10 ++++++++--
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h   |  5 +++++
 3 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 4809eea933da..b16975d996d9 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3622,6 +3622,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6097,
 		.ops = &mv88e6085_ops,
@@ -3637,6 +3638,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6095,
 		.ops = &mv88e6095_ops,
@@ -3652,6 +3654,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6097,
 		.ops = &mv88e6097_ops,
@@ -3667,6 +3670,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 		.ops = &mv88e6123_ops,
@@ -3682,6 +3686,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
 		.ops = &mv88e6131_ops,
@@ -3697,6 +3702,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 		.ops = &mv88e6161_ops,
@@ -3712,6 +3718,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 		.ops = &mv88e6165_ops,
@@ -3727,6 +3734,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 		.ops = &mv88e6171_ops,
@@ -3742,6 +3750,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 		.ops = &mv88e6172_ops,
@@ -3757,6 +3766,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 		.ops = &mv88e6175_ops,
@@ -3772,6 +3782,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 		.ops = &mv88e6176_ops,
@@ -3787,6 +3798,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
 		.ops = &mv88e6185_ops,
@@ -3803,6 +3815,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0x1f,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6190_ops,
 	},
@@ -3817,6 +3830,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0x1f,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6190x_ops,
@@ -3832,6 +3846,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0x1f,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6391_ops,
@@ -3847,6 +3862,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 		.ops = &mv88e6240_ops,
@@ -3862,6 +3878,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0x1f,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6290_ops,
@@ -3877,6 +3894,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
 		.ops = &mv88e6320_ops,
@@ -3892,6 +3910,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
 		.ops = &mv88e6321_ops,
@@ -3906,6 +3925,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
+		.atu_move_port_mask = 0x1f,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6341,
 		.ops = &mv88e6141_ops,
@@ -3920,6 +3940,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
+		.atu_move_port_mask = 0x1f,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6341,
 		.ops = &mv88e6341_ops,
@@ -3935,6 +3956,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 		.ops = &mv88e6350_ops,
@@ -3950,6 +3972,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 		.ops = &mv88e6351_ops,
@@ -3965,6 +3988,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 		.ops = &mv88e6352_ops,
@@ -3979,6 +4003,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0x1f,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6390_ops,
@@ -3993,6 +4018,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0x1f,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6390x_ops,
diff --git a/drivers/net/dsa/mv88e6xxx/global1_atu.c b/drivers/net/dsa/mv88e6xxx/global1_atu.c
index 4758a68f88ea..eb80a6916ca6 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_atu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_atu.c
@@ -224,9 +224,12 @@ static int mv88e6xxx_g1_atu_move(struct mv88e6xxx_chip *chip, u16 fid,
 				 int from_port, int to_port, bool static_too)
 {
 	struct mv88e6xxx_atu_entry entry = { 0 };
-	unsigned long mask = 0xf;
+	unsigned long mask = chip->info->atu_move_port_mask;
 	int shift = bitmap_weight(&mask, 16);
 
+	if (!mask)
+		return -EOPNOTSUPP;
+
 	entry.fid = fid,
 	entry.state = 0xf, /* Full EntryState means Move */
 	entry.portvec = from_port & mask;
@@ -239,7 +242,10 @@ int mv88e6xxx_g1_atu_remove(struct mv88e6xxx_chip *chip, u16 fid, int port,
 			    bool static_too)
 {
 	int from_port = port;
-	int to_port = 0xf;
+	int to_port = chip->info->atu_move_port_mask;
+
+	if (!to_port)
+		return -EOPNOTSUPP;
 
 	return mv88e6xxx_g1_atu_move(chip, fid, from_port, to_port, static_too);
 }
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 93a686819d17..4dac9793a539 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -707,6 +707,11 @@ struct mv88e6xxx_info {
 	unsigned int g1_irqs;
 	enum dsa_tag_protocol tag_protocol;
 	unsigned long long flags;
+
+	/* Mask for FromPort and ToPort value of PortVec used in ATU Move
+	 * operation. 0 means that the ATU Move operation is not supported.
+	 */
+	u8 atu_move_port_mask;
 	const struct mv88e6xxx_ops *ops;
 };
 
-- 
2.11.1
