From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 06/11] net: dsa: mv88e6xxx: Add mv88e6390 stats snapshot operation
Date: Mon, 21 Nov 2016 23:27:00 +0100
Message-ID: <1479767225-13789-7-git-send-email-andrew@lunn.ch>
References: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47732 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754060AbcKUW27 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 17:28:59 -0500
In-Reply-To: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MV88E6390 has a control register for what the histogram statistics
actually contain. This means the stat_snapshot method should not set
this information. So implement the 6390 stats_snapshot function without
these bits.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
v2:
  Move the snapshot function into global1.c
---
 drivers/net/dsa/mv88e6xxx/chip.c      |  7 +++++++
 drivers/net/dsa/mv88e6xxx/global1.c   | 16 ++++++++++++++++
 drivers/net/dsa/mv88e6xxx/global1.h   |  1 +
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  4 +++-
 4 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 2ed7fc996176..c228cb1bb171 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3283,6 +3283,7 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390_port_set_speed,
+	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6190x_ops = {
@@ -3294,6 +3295,7 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390x_port_set_speed,
+	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6191_ops = {
@@ -3305,6 +3307,7 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390_port_set_speed,
+	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6240_ops = {
@@ -3330,6 +3333,7 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390_port_set_speed,
+	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
@@ -3405,6 +3409,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390_port_set_speed,
+	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6390x_ops = {
@@ -3416,6 +3421,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390x_port_set_speed,
+	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6391_ops = {
@@ -3427,6 +3433,7 @@ static const struct mv88e6xxx_ops mv88e6391_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390_port_set_speed,
+	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 };
 
 static const struct mv88e6xxx_info mv88e6xxx_table[] = {
diff --git a/drivers/net/dsa/mv88e6xxx/global1.c b/drivers/net/dsa/mv88e6xxx/global1.c
index 47b507d4d163..a3a441f9c458 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.c
+++ b/drivers/net/dsa/mv88e6xxx/global1.c
@@ -59,3 +59,19 @@ int mv88e6320_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port)
 
 	return mv88e6xxx_g1_stats_snapshot(chip, port);
 }
+
+int mv88e6390_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port)
+{
+	int err;
+
+	port = (port + 1) << 5;
+
+	/* Snapshot the hardware statistics counters for this port. */
+	err = mv88e6xxx_g1_write(chip, GLOBAL_STATS_OP,
+				 GLOBAL_STATS_OP_CAPTURE_PORT | port);
+	if (err)
+		return err;
+
+	/* Wait for the snapshotting to complete. */
+	return mv88e6xxx_g1_stats_wait(chip);
+}
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 0080a30733e8..a9c8943a415a 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -21,5 +21,6 @@ int mv88e6xxx_g1_write(struct mv88e6xxx_chip *chip, int reg, u16 val);
 int mv88e6xxx_g1_wait(struct mv88e6xxx_chip *chip, int reg, u16 mask);
 int mv88e6xxx_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port);
 int mv88e6320_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port);
+int mv88e6390_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port);
 
 #endif /* _MV88E6XXX_GLOBAL1_H */
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 7c61cf626e56..a647e03b9c76 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -283,7 +283,9 @@
 #define GLOBAL_CONTROL_2	0x1c
 #define GLOBAL_CONTROL_2_NO_CASCADE		0xe000
 #define GLOBAL_CONTROL_2_MULTIPLE_CASCADE	0xf000
-
+#define GLOBAL_CONTROL_2_HIST_RX	       (0x1 << 6)
+#define GLOBAL_CONTROL_2_HIST_TX	       (0x2 << 6)
+#define GLOBAL_CONTROL_2_HIST_RX_TX	       (0x3 << 6)
 #define GLOBAL_STATS_OP		0x1d
 #define GLOBAL_STATS_OP_BUSY	BIT(15)
 #define GLOBAL_STATS_OP_NOP		(0 << 12)
-- 
2.10.2
