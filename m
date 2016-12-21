From: Romain Perier <romain.perier@free-electrons.com>
Subject: [PATCH net-next v4 2/2] net: dsa: mv88e6xxx: Add support for ethernet switch 88E6341/88E6141
Date: Wed, 21 Dec 2016 13:57:34 +0100
Message-ID: <20161221125734.1034-3-romain.perier@free-electrons.com>
References: <20161221125734.1034-1-romain.perier@free-electrons.com>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Rob Herring <robh+dt@kernel.org>,
        Ian Campbell <ijc+devicetree@hellion.org.uk>,
        Pawel Moll <pawel.moll@arm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Kumar Gala <galak@codeaurora.org>,
        linux-arm-kernel@lists.infradead.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Romain Perier <romain.perier@free-electrons.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:58609 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752204AbcLUM5v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 07:57:51 -0500
In-Reply-To: <20161221125734.1034-1-romain.perier@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Marvell 88E6341 device is single-chip, 6-port ethernet switch with
four integrated 10/100/1000Mbps ethernet transceivers and one high speed
SerDes interfaces. It is compatible with switches of family 88E6352.

This commit adds basic support for this switch by describing its
capabilities to the driver.

Signed-off-by: Romain Perier <romain.perier@free-electrons.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---

Changes in v3:
 - Added tag "Reviewed-by" by Andrew
 
Changes in v2:
 - Add a dedicated data structure for the operations of the 88E6341
 - Re-ordered PORT_SWITCH_ID_PROD_NUM_6341 in alphabetic order with other
   macros

 drivers/net/dsa/mv88e6xxx/chip.c      | 42 +++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  4 +++-
 2 files changed, 45 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 76d944e..5e97dc4 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3625,6 +3625,34 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.reset = mv88e6352_g1_reset,
 };
 
+static const struct mv88e6xxx_ops mv88e6341_ops = {
+	/* MV88E6XXX_FAMILY_6352 */
+	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
+	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
+	.phy_read = mv88e6xxx_g2_smi_phy_read,
+	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
+	.port_set_speed = mv88e6352_port_set_speed,
+	.port_tag_remap = mv88e6095_port_tag_remap,
+	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
+	.port_pause_config = mv88e6097_port_pause_config,
+	.stats_snapshot = mv88e6320_g1_stats_snapshot,
+	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
+	.stats_get_strings = mv88e6095_stats_get_strings,
+	.stats_get_stats = mv88e6095_stats_get_stats,
+	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
+	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.reset = mv88e6352_g1_reset,
+};
+
 static const struct mv88e6xxx_ops mv88e6350_ops = {
 	/* MV88E6XXX_FAMILY_6351 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -4086,6 +4114,20 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.ops = &mv88e6321_ops,
 	},
 
+	[MV88E6341] = {
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6341,
+		.family = MV88E6XXX_FAMILY_6352,
+		.name = "Marvell 88E6341",
+		.num_databases = 4096,
+		.num_ports = 6,
+		.port_base_addr = 0x10,
+		.global1_addr = 0x1b,
+		.age_time_coeff = 15000,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
+		.ops = &mv88e6341_ops,
+	},
+
 	[MV88E6350] = {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6350,
 		.family = MV88E6XXX_FAMILY_6351,
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index af54bae..cb55fdb 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -100,6 +100,7 @@
 #define PORT_SWITCH_ID_PROD_NUM_6240	0x240
 #define PORT_SWITCH_ID_PROD_NUM_6290	0x290
 #define PORT_SWITCH_ID_PROD_NUM_6321	0x310
+#define PORT_SWITCH_ID_PROD_NUM_6341	0x340
 #define PORT_SWITCH_ID_PROD_NUM_6352	0x352
 #define PORT_SWITCH_ID_PROD_NUM_6350	0x371
 #define PORT_SWITCH_ID_PROD_NUM_6351	0x375
@@ -432,6 +433,7 @@ enum mv88e6xxx_model {
 	MV88E6290,
 	MV88E6320,
 	MV88E6321,
+	MV88E6341,
 	MV88E6350,
 	MV88E6351,
 	MV88E6352,
@@ -448,7 +450,7 @@ enum mv88e6xxx_family {
 	MV88E6XXX_FAMILY_6185,	/* 6108 6121 6122 6131 6152 6155 6182 6185 */
 	MV88E6XXX_FAMILY_6320,	/* 6320 6321 */
 	MV88E6XXX_FAMILY_6351,	/* 6171 6175 6350 6351 */
-	MV88E6XXX_FAMILY_6352,	/* 6172 6176 6240 6352 */
+	MV88E6XXX_FAMILY_6352,	/* 6172 6176 6240 6341 6352 */
 	MV88E6XXX_FAMILY_6390,  /* 6190 6190X 6191 6290 6390 6390X */
 };
 
-- 
2.9.3
