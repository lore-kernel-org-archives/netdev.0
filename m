From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 4/7] net: dsa: mv88e6xxx: do not prefix ops with g1
Date: Thu,  8 Jun 2017 18:34:11 -0400
Message-ID: <20170608223414.594-5-vivien.didelot@savoirfairelinux.com>
References: <20170608223414.594-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170608223414.594-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The mv88e6xxx_ops describe functionalities, regardless their locations
(which can be Global1, Global2, or whatever register set.)

Rename the g1_set_cpu_port and g1_set_egress_port ops to set_cpu_port
and set_egress_port. No functional changes.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 108 +++++++++++++++++++--------------------
 drivers/net/dsa/mv88e6xxx/chip.h |   4 +-
 2 files changed, 56 insertions(+), 56 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index e25d48ecf880..f33b83bf3ee8 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2015,14 +2015,14 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 	u32 upstream_port = dsa_upstream_port(ds);
 	int err;
 
-	if (chip->info->ops->g1_set_cpu_port) {
-		err = chip->info->ops->g1_set_cpu_port(chip, upstream_port);
+	if (chip->info->ops->set_cpu_port) {
+		err = chip->info->ops->set_cpu_port(chip, upstream_port);
 		if (err)
 			return err;
 	}
 
-	if (chip->info->ops->g1_set_egress_port) {
-		err = chip->info->ops->g1_set_egress_port(chip, upstream_port);
+	if (chip->info->ops->set_egress_port) {
+		err = chip->info->ops->set_egress_port(chip, upstream_port);
 		if (err)
 			return err;
 	}
@@ -2369,8 +2369,8 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
-	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.set_cpu_port = mv88e6095_g1_set_cpu_port,
+	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.ppu_enable = mv88e6185_g1_ppu_enable,
@@ -2424,8 +2424,8 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
-	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.set_cpu_port = mv88e6095_g1_set_cpu_port,
+	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
@@ -2449,8 +2449,8 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
-	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.set_cpu_port = mv88e6095_g1_set_cpu_port,
+	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
@@ -2478,8 +2478,8 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
-	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.set_cpu_port = mv88e6095_g1_set_cpu_port,
+	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.ppu_enable = mv88e6185_g1_ppu_enable,
@@ -2513,8 +2513,8 @@ static const struct mv88e6xxx_ops mv88e6141_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
-	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.set_cpu_port = mv88e6390_g1_set_cpu_port,
+	.set_egress_port = mv88e6390_g1_set_egress_port,
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu =  mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
@@ -2543,8 +2543,8 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
-	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.set_cpu_port = mv88e6095_g1_set_cpu_port,
+	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
@@ -2566,8 +2566,8 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
-	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.set_cpu_port = mv88e6095_g1_set_cpu_port,
+	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
@@ -2597,8 +2597,8 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
-	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.set_cpu_port = mv88e6095_g1_set_cpu_port,
+	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
@@ -2630,8 +2630,8 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
-	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.set_cpu_port = mv88e6095_g1_set_cpu_port,
+	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
@@ -2662,8 +2662,8 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
-	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.set_cpu_port = mv88e6095_g1_set_cpu_port,
+	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
@@ -2695,8 +2695,8 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
-	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.set_cpu_port = mv88e6095_g1_set_cpu_port,
+	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
@@ -2721,8 +2721,8 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
-	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.set_cpu_port = mv88e6095_g1_set_cpu_port,
+	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.ppu_enable = mv88e6185_g1_ppu_enable,
@@ -2755,8 +2755,8 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
-	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.set_cpu_port = mv88e6390_g1_set_cpu_port,
+	.set_egress_port = mv88e6390_g1_set_egress_port,
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
@@ -2788,8 +2788,8 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
-	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.set_cpu_port = mv88e6390_g1_set_cpu_port,
+	.set_egress_port = mv88e6390_g1_set_egress_port,
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
@@ -2821,8 +2821,8 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
-	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.set_cpu_port = mv88e6390_g1_set_cpu_port,
+	.set_egress_port = mv88e6390_g1_set_egress_port,
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
@@ -2855,8 +2855,8 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
-	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.set_cpu_port = mv88e6095_g1_set_cpu_port,
+	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
@@ -2889,8 +2889,8 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
-	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.set_cpu_port = mv88e6390_g1_set_cpu_port,
+	.set_egress_port = mv88e6390_g1_set_egress_port,
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
@@ -2922,8 +2922,8 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6320_stats_get_stats,
-	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.set_cpu_port = mv88e6095_g1_set_cpu_port,
+	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6185_g1_vtu_getnext,
@@ -2953,8 +2953,8 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6320_stats_get_stats,
-	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.set_cpu_port = mv88e6095_g1_set_cpu_port,
+	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6185_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6185_g1_vtu_loadpurge,
@@ -2984,8 +2984,8 @@ static const struct mv88e6xxx_ops mv88e6341_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
-	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.set_cpu_port = mv88e6390_g1_set_cpu_port,
+	.set_egress_port = mv88e6390_g1_set_egress_port,
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu =  mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
@@ -3015,8 +3015,8 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
-	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.set_cpu_port = mv88e6095_g1_set_cpu_port,
+	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
@@ -3046,8 +3046,8 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
-	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.set_cpu_port = mv88e6095_g1_set_cpu_port,
+	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
@@ -3079,8 +3079,8 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
-	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.set_cpu_port = mv88e6095_g1_set_cpu_port,
+	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
@@ -3115,8 +3115,8 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
-	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.set_cpu_port = mv88e6390_g1_set_cpu_port,
+	.set_egress_port = mv88e6390_g1_set_egress_port,
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
@@ -3150,8 +3150,8 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
-	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.set_cpu_port = mv88e6390_g1_set_cpu_port,
+	.set_egress_port = mv88e6390_g1_set_egress_port,
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
diff --git a/drivers/net/dsa/mv88e6xxx/chip.h b/drivers/net/dsa/mv88e6xxx/chip.h
index fb7dea33a44a..07b35cccb0c4 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.h
+++ b/drivers/net/dsa/mv88e6xxx/chip.h
@@ -456,8 +456,8 @@ struct mv88e6xxx_ops {
 	void (*stats_get_strings)(struct mv88e6xxx_chip *chip,  uint8_t *data);
 	void (*stats_get_stats)(struct mv88e6xxx_chip *chip,  int port,
 				uint64_t *data);
-	int (*g1_set_cpu_port)(struct mv88e6xxx_chip *chip, int port);
-	int (*g1_set_egress_port)(struct mv88e6xxx_chip *chip, int port);
+	int (*set_cpu_port)(struct mv88e6xxx_chip *chip, int port);
+	int (*set_egress_port)(struct mv88e6xxx_chip *chip, int port);
 	const struct mv88e6xxx_irq_ops *watchdog_ops;
 
 	/* Can be either in g1 or g2, so don't use a prefix */
-- 
2.13.1
