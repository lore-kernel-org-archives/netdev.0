From: Stefan Eichenberger <eichest@gmail.com>
Subject: [PATCH net-next v2 2/2] net: dsa: mv88e6xxx: add MV88E6097 switch
Date: Wed, 23 Nov 2016 21:59:52 +0100
Message-ID: <20161123205952.6231-3-stefan.eichenberger@netmodule.com>
References: <20161123205952.6231-1-stefan.eichenberger@netmodule.com>
Cc: netdev@vger.kernel.org,
        Stefan Eichenberger <stefan.eichenberger@netmodule.com>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f196.google.com ([209.85.210.196]:36849 "EHLO
        mail-wj0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933168AbcKWVVH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 16:21:07 -0500
Received: by mail-wj0-f196.google.com with SMTP id jb2so1923025wjb.3
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 13:20:24 -0800 (PST)
In-Reply-To: <20161123205952.6231-1-stefan.eichenberger@netmodule.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the MV88E6097 switch. The change was tested on an Armada
based platform with a MV88E6097 switch.

Signed-off-by: Stefan Eichenberger <stefan.eichenberger@netmodule.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 28 ++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  2 ++
 2 files changed, 30 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index bada646..68eb8fc 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3209,6 +3209,20 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 };
 
+static const struct mv88e6xxx_ops mv88e6097_ops = {
+	/* MV88E6XXX_FAMILY_6097 */
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
+	.phy_read = mv88e6xxx_g2_smi_phy_read,
+	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
+	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
+	.stats_get_strings = mv88e6095_stats_get_strings,
+	.stats_get_stats = mv88e6095_stats_get_stats,
+};
+
 static const struct mv88e6xxx_ops mv88e6123_ops = {
 	/* MV88E6XXX_FAMILY_6165 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -3580,6 +3594,20 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.ops = &mv88e6095_ops,
 	},
 
+	[MV88E6097] = {
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6097,
+		.family = MV88E6XXX_FAMILY_6097,
+		.name = "Marvell 88E6097/88E6097F",
+		.num_databases = 4096,
+		.num_ports = 11,
+		.port_base_addr = 0x10,
+		.global1_addr = 0x1b,
+		.age_time_coeff = 15000,
+		.g1_irqs = 8,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6097,
+		.ops = &mv88e6097_ops,
+	},
+
 	[MV88E6123] = {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6123,
 		.family = MV88E6XXX_FAMILY_6165,
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 3e69526..a2ff1fc 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -81,6 +81,7 @@
 #define PORT_SWITCH_ID		0x03
 #define PORT_SWITCH_ID_PROD_NUM_6085	0x04a
 #define PORT_SWITCH_ID_PROD_NUM_6095	0x095
+#define PORT_SWITCH_ID_PROD_NUM_6097	0x099
 #define PORT_SWITCH_ID_PROD_NUM_6131	0x106
 #define PORT_SWITCH_ID_PROD_NUM_6320	0x115
 #define PORT_SWITCH_ID_PROD_NUM_6123	0x121
@@ -378,6 +379,7 @@
 enum mv88e6xxx_model {
 	MV88E6085,
 	MV88E6095,
+	MV88E6097,
 	MV88E6123,
 	MV88E6131,
 	MV88E6161,
-- 
2.9.3
