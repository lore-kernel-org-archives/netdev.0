From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 12/14] net: dsa: mv88e6xxx: add port ATU learn limit op
Date: Thu,  9 Mar 2017 18:33:22 -0500
Message-ID: <20170309233324.18539-13-vivien.didelot@savoirfairelinux.com>
References: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new operation to disable the limiting of learnt MAC addresses.

Setting such limit is not likely to be used soon, so provide a
port_disable_learn_limit operation directly. This can be changed later
for port_set_learn_limit when we'll need it.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 36 +++++++++++++++++++++++++++++------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  1 +
 drivers/net/dsa/mv88e6xxx/port.c      |  7 +++++++
 drivers/net/dsa/mv88e6xxx/port.h      |  3 +++
 4 files changed, 41 insertions(+), 6 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 07b08329aa9b..a4fe0576258b 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2404,15 +2404,15 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 			return err;
 	}
 
+	if (chip->info->ops->port_disable_learn_limit) {
+		err = chip->info->ops->port_disable_learn_limit(chip, port);
+		if (err)
+			return err;
+	}
+
 	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
 	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
 	    mv88e6xxx_6320_family(chip) || mv88e6xxx_6341_family(chip)) {
-		/* Port ATU control: disable limiting the number of
-		 * address database entries that this port is allowed
-		 * to use.
-		 */
-		err = mv88e6xxx_port_write(chip, port, PORT_ATU_CONTROL,
-					   0x0000);
 		/* Priority Override: disable DA, SA and VTU priority
 		 * override.
 		 */
@@ -2842,6 +2842,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -2891,6 +2892,7 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6095_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -2912,6 +2914,7 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_set_frame_mode = mv88e6085_port_set_frame_mode,
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -2967,6 +2970,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -2986,6 +2990,7 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3013,6 +3018,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3042,6 +3048,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3069,6 +3076,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3098,6 +3106,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3150,6 +3159,7 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_pause_config = mv88e6390_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3178,6 +3188,7 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_pause_config = mv88e6390_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3206,6 +3217,7 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_pause_config = mv88e6390_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3236,6 +3248,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3264,6 +3277,7 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_pause_config = mv88e6390_port_pause_config,
 	.port_set_cmode = mv88e6390x_port_set_cmode,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3293,6 +3307,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3320,6 +3335,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3345,6 +3361,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3372,6 +3389,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3401,6 +3419,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3430,6 +3449,7 @@ static const struct mv88e6xxx_ops mv88e6141_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3459,6 +3479,7 @@ static const struct mv88e6xxx_ops mv88e6341_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3489,6 +3510,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6390_port_pause_config,
 	.port_set_cmode = mv88e6390x_port_set_cmode,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3519,6 +3541,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6390_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3547,6 +3570,7 @@ static const struct mv88e6xxx_ops mv88e6391_ops = {
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_pause_config = mv88e6390_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 0b8ce86c98ce..8b341a976366 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -876,6 +876,7 @@ struct mv88e6xxx_ops {
 
 	int (*port_egress_rate_limiting)(struct mv88e6xxx_chip *chip, int port);
 	int (*port_pause_config)(struct mv88e6xxx_chip *chip, int port);
+	int (*port_disable_learn_limit)(struct mv88e6xxx_chip *chip, int port);
 
 	/* CMODE control what PHY mode the MAC will use, eg. SGMII, RGMII, etc.
 	 * Some chips allow this to be configured on specific ports.
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index b028d07134d9..129f4e67d8af 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -805,6 +805,13 @@ int mv88e6097_port_egress_rate_limiting(struct mv88e6xxx_chip *chip, int port)
 	return mv88e6xxx_port_write(chip, port, PORT_RATE_CONTROL, 0x0001);
 }
 
+/* Offset 0x0C: Port ATU Control */
+
+int mv88e6xxx_port_disable_learn_limit(struct mv88e6xxx_chip *chip, int port)
+{
+	return mv88e6xxx_port_write(chip, port, PORT_ATU_CONTROL, 0);
+}
+
 /* Offset 0x0f: Port Ether type */
 
 int mv88e6351_port_set_ether_type(struct mv88e6xxx_chip *chip, int port,
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 3e130908a585..f96ecdbfe8b5 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -75,4 +75,7 @@ int mv88e6xxx_port_get_cmode(struct mv88e6xxx_chip *chip, int port, u8 *cmode);
 int mv88e6xxx_port_set_map_da(struct mv88e6xxx_chip *chip, int port);
 int mv88e6095_port_set_upstream_port(struct mv88e6xxx_chip *chip, int port,
 				     int upstream_port);
+
+int mv88e6xxx_port_disable_learn_limit(struct mv88e6xxx_chip *chip, int port);
+
 #endif /* _MV88E6XXX_PORT_H */
-- 
2.12.0
