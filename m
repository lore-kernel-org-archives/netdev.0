From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v3 net-next 2/2] net: dsa: mv88e6xxx: Add mv88e6390 watchdog interrupt support
Date: Thu,  9 Feb 2017 00:03:43 +0100
Message-ID: <1486595023-28371-3-git-send-email-andrew@lunn.ch>
References: <1486595023-28371-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60473 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751829AbdBHXER (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 18:04:17 -0500
In-Reply-To: <1486595023-28371-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement the ops needed to support the watchdog for the MV88E6390
family.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
v2:
   All new
v3:
   Remove g2_ prefix from ops.
---
 drivers/net/dsa/mv88e6xxx/chip.c      |  9 +++++++
 drivers/net/dsa/mv88e6xxx/global2.c   | 48 +++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/global2.h   |  2 ++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 12 +++++++++
 4 files changed, 71 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 489a59f5dea3..7658284beaf9 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3419,6 +3419,7 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.stats_get_stats = mv88e6390_stats_get_stats,
 	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 };
@@ -3446,6 +3447,7 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.stats_get_stats = mv88e6390_stats_get_stats,
 	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 };
@@ -3473,6 +3475,7 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.stats_get_stats = mv88e6390_stats_get_stats,
 	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 };
@@ -3530,6 +3533,7 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.stats_get_stats = mv88e6390_stats_get_stats,
 	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 };
@@ -3694,6 +3698,7 @@ static const struct mv88e6xxx_ops mv88e6141_ops = {
 	.stats_get_stats = mv88e6390_stats_get_stats,
 	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu =  mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 };
@@ -3722,6 +3727,7 @@ static const struct mv88e6xxx_ops mv88e6341_ops = {
 	.stats_get_stats = mv88e6390_stats_get_stats,
 	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu =  mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 };
@@ -3752,6 +3758,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.stats_get_stats = mv88e6390_stats_get_stats,
 	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 };
@@ -3781,6 +3788,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.stats_get_stats = mv88e6390_stats_get_stats,
 	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 };
@@ -3808,6 +3816,7 @@ static const struct mv88e6xxx_ops mv88e6391_ops = {
 	.stats_get_stats = mv88e6390_stats_get_stats,
 	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 };
diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index 1e2d65826d12..8f15bc7b1f5f 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -686,6 +686,54 @@ const struct mv88e6xxx_irq_ops mv88e6097_watchdog_ops = {
 	.irq_free = mv88e6097_watchdog_free,
 };
 
+static int mv88e6390_watchdog_setup(struct mv88e6xxx_chip *chip)
+{
+	return mv88e6xxx_g2_update(chip, GLOBAL2_WDOG_CONTROL,
+				   GLOBAL2_WDOG_INT_ENABLE |
+				   GLOBAL2_WDOG_CUT_THROUGH |
+				   GLOBAL2_WDOG_QUEUE_CONTROLLER |
+				   GLOBAL2_WDOG_EGRESS |
+				   GLOBAL2_WDOG_FORCE_IRQ);
+}
+
+static int mv88e6390_watchdog_action(struct mv88e6xxx_chip *chip, int irq)
+{
+	int err;
+	u16 reg;
+
+	mv88e6xxx_g2_write(chip, GLOBAL2_WDOG_CONTROL, GLOBAL2_WDOG_EVENT);
+	err = mv88e6xxx_g2_read(chip, GLOBAL2_WDOG_CONTROL, &reg);
+
+	dev_info(chip->dev, "Watchdog event: 0x%04x",
+		 reg & GLOBAL2_WDOG_DATA_MASK);
+
+	mv88e6xxx_g2_write(chip, GLOBAL2_WDOG_CONTROL, GLOBAL2_WDOG_HISTORY);
+	err = mv88e6xxx_g2_read(chip, GLOBAL2_WDOG_CONTROL, &reg);
+
+	dev_info(chip->dev, "Watchdog history: 0x%04x",
+		 reg & GLOBAL2_WDOG_DATA_MASK);
+
+	/* Trigger a software reset to try to recover the switch */
+	if (chip->info->ops->reset)
+		chip->info->ops->reset(chip);
+
+	mv88e6390_watchdog_setup(chip);
+
+	return IRQ_HANDLED;
+}
+
+static void mv88e6390_watchdog_free(struct mv88e6xxx_chip *chip)
+{
+	mv88e6xxx_g2_update(chip, GLOBAL2_WDOG_CONTROL,
+			    GLOBAL2_WDOG_INT_ENABLE);
+}
+
+const struct mv88e6xxx_irq_ops mv88e6390_watchdog_ops = {
+	.irq_action = mv88e6390_watchdog_action,
+	.irq_setup = mv88e6390_watchdog_setup,
+	.irq_free = mv88e6390_watchdog_free,
+};
+
 static irqreturn_t mv88e6xxx_g2_watchdog_thread_fn(int irq, void *dev_id)
 {
 	struct mv88e6xxx_chip *chip = dev_id;
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index 8305f6941fd1..a8b2f9486a4a 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -47,6 +47,7 @@ void mv88e6xxx_g2_irq_free(struct mv88e6xxx_chip *chip);
 int mv88e6095_g2_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip);
 
 extern const struct mv88e6xxx_irq_ops mv88e6097_watchdog_ops;
+extern const struct mv88e6xxx_irq_ops mv88e6390_watchdog_ops;
 
 #else /* !CONFIG_NET_DSA_MV88E6XXX_GLOBAL2 */
 
@@ -128,6 +129,7 @@ static inline int mv88e6095_g2_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip)
 }
 
 static const struct mv88e6xxx_irq_ops mv88e6097_watchdog_ops = {};
+static const struct mv88e6xxx_irq_ops mv88e6390_watchdog_ops = {};
 
 #endif /* CONFIG_NET_DSA_MV88E6XXX_GLOBAL2 */
 
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index e97adc75b6fc..9c11b446d505 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -423,6 +423,17 @@
 #define GLOBAL2_WDOG_CONTROL_FORCE_IRQ		BIT(2)
 #define GLOBAL2_WDOG_CONTROL_HISTORY		BIT(1)
 #define GLOBAL2_WDOG_CONTROL_SWRESET		BIT(0)
+#define GLOBAL2_WDOG_UPDATE			BIT(15)
+#define GLOBAL2_WDOG_INT_SOURCE			(0x00 << 8)
+#define GLOBAL2_WDOG_INT_STATUS			(0x10 << 8)
+#define GLOBAL2_WDOG_INT_ENABLE			(0x11 << 8)
+#define GLOBAL2_WDOG_EVENT			(0x12 << 8)
+#define GLOBAL2_WDOG_HISTORY			(0x13 << 8)
+#define GLOBAL2_WDOG_DATA_MASK			0xff
+#define GLOBAL2_WDOG_CUT_THROUGH		BIT(3)
+#define GLOBAL2_WDOG_QUEUE_CONTROLLER		BIT(2)
+#define GLOBAL2_WDOG_EGRESS			BIT(1)
+#define GLOBAL2_WDOG_FORCE_IRQ			BIT(0)
 #define GLOBAL2_QOS_WEIGHT	0x1c
 #define GLOBAL2_MISC		0x1d
 
@@ -674,6 +685,7 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAGS_FAMILY_6390	\
 	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
+	 MV88E6XXX_FLAG_G2_INT |        \
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
-- 
2.11.0
