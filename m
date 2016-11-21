From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 07/11] net: dsa: mv88e6xxx: Add mv88e6390 statistics unit init
Date: Mon, 21 Nov 2016 23:27:01 +0100
Message-ID: <1479767225-13789-8-git-send-email-andrew@lunn.ch>
References: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47736 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754061AbcKUW3P (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 17:29:15 -0500
In-Reply-To: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The statistics unit on the mv88e6390 needs the histogram mode to be
configured in a different register compared to other devices. Add an
ops to do this.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
v2:
  Rename to mv88e6390_g1_stats_set_histogram
  Move into global1.c
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 20 ++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/global1.c   | 20 ++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/global1.h   |  1 +
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  5 +++++
 4 files changed, 46 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index c228cb1bb171..dc23d042790b 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1009,6 +1009,14 @@ static void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds, int port,
 	mutex_unlock(&chip->reg_lock);
 }
 
+static int mv88e6xxx_stats_set_histogram(struct mv88e6xxx_chip *chip)
+{
+	if (chip->info->ops->stats_set_histogram)
+		return chip->info->ops->stats_set_histogram(chip);
+
+	return 0;
+}
+
 static int mv88e6xxx_get_regs_len(struct dsa_switch *ds, int port)
 {
 	return 32 * sizeof(u16);
@@ -2797,6 +2805,11 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 	if (err)
 		return err;
 
+	/* Initialize the statistics unit */
+	err = mv88e6xxx_stats_set_histogram(chip);
+	if (err)
+		return err;
+
 	/* Clear the statistics counters for all ports */
 	err = mv88e6xxx_g1_write(chip, GLOBAL_STATS_OP,
 				 GLOBAL_STATS_OP_FLUSH_ALL);
@@ -3284,6 +3297,7 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390_port_set_speed,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
+	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 };
 
 static const struct mv88e6xxx_ops mv88e6190x_ops = {
@@ -3296,6 +3310,7 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390x_port_set_speed,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
+	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 };
 
 static const struct mv88e6xxx_ops mv88e6191_ops = {
@@ -3308,6 +3323,7 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390_port_set_speed,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
+	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 };
 
 static const struct mv88e6xxx_ops mv88e6240_ops = {
@@ -3334,6 +3350,7 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390_port_set_speed,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
+	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 };
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
@@ -3410,6 +3427,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390_port_set_speed,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
+	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 };
 
 static const struct mv88e6xxx_ops mv88e6390x_ops = {
@@ -3422,6 +3440,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390x_port_set_speed,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
+	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 };
 
 static const struct mv88e6xxx_ops mv88e6391_ops = {
@@ -3434,6 +3453,7 @@ static const struct mv88e6xxx_ops mv88e6391_ops = {
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390_port_set_speed,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
+	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 };
 
 static const struct mv88e6xxx_info mv88e6xxx_table[] = {
diff --git a/drivers/net/dsa/mv88e6xxx/global1.c b/drivers/net/dsa/mv88e6xxx/global1.c
index a3a441f9c458..fda8b3c7adad 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.c
+++ b/drivers/net/dsa/mv88e6xxx/global1.c
@@ -33,6 +33,26 @@ int mv88e6xxx_g1_wait(struct mv88e6xxx_chip *chip, int reg, u16 mask)
 	return mv88e6xxx_wait(chip, chip->info->global1_addr, reg, mask);
 }
 
+/* Offset 0x1c: Global Control 2 */
+
+int mv88e6390_g1_stats_set_histogram(struct mv88e6xxx_chip *chip)
+{
+	u16 val;
+	int err;
+
+	err = mv88e6xxx_g1_read(chip, GLOBAL_CONTROL_2, &val);
+	if (err)
+		return err;
+
+	val |= GLOBAL_CONTROL_2_HIST_RX_TX;
+
+	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL_2, val);
+
+	return err;
+}
+
+/* Offset 0x1d: Statistics Operation 2 */
+
 static int mv88e6xxx_g1_stats_wait(struct mv88e6xxx_chip *chip)
 {
 	return mv88e6xxx_g1_wait(chip, GLOBAL_STATS_OP, GLOBAL_STATS_OP_BUSY);
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index a9c8943a415a..ffc9f45baad9 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -22,5 +22,6 @@ int mv88e6xxx_g1_wait(struct mv88e6xxx_chip *chip, int reg, u16 mask);
 int mv88e6xxx_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port);
 int mv88e6320_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port);
 int mv88e6390_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port);
+int mv88e6390_g1_stats_set_histogram(struct mv88e6xxx_chip *chip);
 
 #endif /* _MV88E6XXX_GLOBAL1_H */
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index a647e03b9c76..d947a0c4ace6 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -801,6 +801,11 @@ struct mv88e6xxx_ops {
 	 * be read back a leisure but still with a consistent view.
 	 */
 	int (*stats_snapshot)(struct mv88e6xxx_chip *chip, int port);
+
+	/* Set the histogram mode for statistics, when the control registers
+	 * are separated out of the STATS_OP register.
+	 */
+	int (*stats_set_histogram)(struct mv88e6xxx_chip *chip);
 };
 
 enum stat_type {
-- 
2.10.2
