From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v1 net-next 5/5] net: dsa: mv88e6xxx: Implement mv88e6390 pause control
Date: Sat,  3 Dec 2016 04:45:20 +0100
Message-ID: <1480736720-12608-6-git-send-email-andrew@lunn.ch>
References: <1480736720-12608-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38555 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751547AbcLCDpi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 22:45:38 -0500
In-Reply-To: <1480736720-12608-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6390 has a number flow control registers accessed via the
Flow Control register. Use these to set the pause control.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      |  7 +++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  2 ++
 drivers/net/dsa/mv88e6xxx/port.c      | 13 +++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h      |  1 +
 4 files changed, 23 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 3ddb1f79e709..ca453f3243cd 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3490,6 +3490,7 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_pause_config = mv88e6390_port_pause_config,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3513,6 +3514,7 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_pause_config = mv88e6390_port_pause_config,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3536,6 +3538,7 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_pause_config = mv88e6390_port_pause_config,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3586,6 +3589,7 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_pause_config = mv88e6390_port_pause_config,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3739,6 +3743,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
+	.port_pause_config = mv88e6390_port_pause_config,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3764,6 +3769,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
+	.port_pause_config = mv88e6390_port_pause_config,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3787,6 +3793,7 @@ static const struct mv88e6xxx_ops mv88e6391_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_pause_config = mv88e6390_port_pause_config,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 3b1f3ab490b9..13c7cc443454 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -78,6 +78,8 @@
 #define PORT_PCS_CTRL_SPEED_10000	(0x03) /* 6390X */
 #define PORT_PCS_CTRL_SPEED_UNFORCED	(0x03)
 #define PORT_PAUSE_CTRL		0x02
+#define PORT_FLOW_CTRL_LIMIT_IN		((0x00 << 8) | BIT(15))
+#define PORT_FLOW_CTRL_LIMIT_OUT	((0x01 << 8) | BIT(15))
 #define PORT_SWITCH_ID		0x03
 #define PORT_SWITCH_ID_PROD_NUM_6085	0x04a
 #define PORT_SWITCH_ID_PROD_NUM_6095	0x095
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 8d14833b2e49..0db7fa0373ae 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -315,6 +315,19 @@ int mv88e6097_port_pause_config(struct mv88e6xxx_chip *chip, int port)
 	return mv88e6xxx_port_write(chip, port, PORT_PAUSE_CTRL, 0x0000);
 }
 
+int mv88e6390_port_pause_config(struct mv88e6xxx_chip *chip, int port)
+{
+	int err;
+
+	err = mv88e6xxx_port_write(chip, port, PORT_PAUSE_CTRL,
+				   PORT_FLOW_CTRL_LIMIT_IN | 0);
+	if (err)
+		return err;
+
+	return mv88e6xxx_port_write(chip, port, PORT_PAUSE_CTRL,
+				    PORT_FLOW_CTRL_LIMIT_OUT | 0);
+}
+
 /* Offset 0x04: Port Control Register */
 
 static const char * const mv88e6xxx_port_state_names[] = {
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 8c964cfd9032..7b3bacaacbfe 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -66,5 +66,6 @@ int mv88e6165_port_jumbo_config(struct mv88e6xxx_chip *chip, int port);
 int mv88e6095_port_egress_rate_limiting(struct mv88e6xxx_chip *chip, int port);
 int mv88e6097_port_egress_rate_limiting(struct mv88e6xxx_chip *chip, int port);
 int mv88e6097_port_pause_config(struct mv88e6xxx_chip *chip, int port);
+int mv88e6390_port_pause_config(struct mv88e6xxx_chip *chip, int port);
 
 #endif /* _MV88E6XXX_PORT_H */
-- 
2.10.2
