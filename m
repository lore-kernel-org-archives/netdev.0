From: Stefan Eichenberger <eichest@gmail.com>
Subject: [PATCH v2] net: dsa: mv88e6xxx: add MV88E6097 switch
Date: Tue, 22 Nov 2016 17:47:21 +0100
Message-ID: <20161122164721.4103-1-stefan.eichenberger@netmodule.com>
References: <20161122150754.GF2691@lunn.ch>
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org,
        Stefan Eichenberger <stefan.eichenberger@netmodule.com>
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34083 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756016AbcKVREb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 12:04:31 -0500
Received: by mail-wm0-f66.google.com with SMTP id g23so5179399wme.1
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 09:04:30 -0800 (PST)
In-Reply-To: <20161122150754.GF2691@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the MV88E6097 switch. The change was tested on an Armada
based platform with a MV88E6097 switch.

Signed-off-by: Stefan Eichenberger <stefan.eichenberger@netmodule.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 26 ++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  2 ++
 2 files changed, 28 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 48b58c7..2d5941c 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3208,6 +3208,19 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 };
 
+static const struct mv88e6xxx_ops mv88e6097_ops = {
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
@@ -3579,6 +3592,19 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
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
+		.flags = MV88E6XXX_FLAGS_FAMILY_6097,
+		.ops = &mv88e6097_ops,
+	},
+
 	[MV88E6123] = {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6123,
 		.family = MV88E6XXX_FAMILY_6165,
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 9298faa..ab52c37 100644
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
