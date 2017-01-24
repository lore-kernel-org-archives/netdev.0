From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net-next v6 3/4] net: dsa: mv88e6xxx: Add support for ethernet switch 88E6141
Date: Tue, 24 Jan 2017 21:10:25 +0100
Message-ID: <cb677fe2f286f8ed3a262f70cd176fad063849cd.1485288602.git-series.gregory.clement@free-electrons.com>
References: <cover.b0e18efe751186768e720c341693117fdd4d3c16.1485288602.git-series.gregory.clement@free-electrons.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Nadav Haklai <nadavh@marvell.com>,
        Wilson Ding <dingwei@marvell.com>,
        Kostya Porotchkin <kostap@marvell.com>,
        Joe Zhou <shjzhou@marvell.com>,
        Jon Pannell <jpannell@marvell.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.b0e18efe751186768e720c341693117fdd4d3c16.1485288602.git-series.gregory.clement@free-electrons.com>
In-Reply-To: <cover.b0e18efe751186768e720c341693117fdd4d3c16.1485288602.git-series.gregory.clement@free-electrons.com>
References: <cover.b0e18efe751186768e720c341693117fdd4d3c16.1485288602.git-series.gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Marvell 88E6341 device is single-chip, 6-port Ethernet switch with
four integrated 10/100/1000Mbps Ethernet transceivers and one high speed
SerDes interfaces.

It belongs to the Topaz family and unlike the 88E6341 it does not have
a TCAM.

Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 42 ++++++++++++++++++++++++++++-
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  2 +-
 2 files changed, 44 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 00db33ca1696..cdb8c7c4accd 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3572,6 +3572,34 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.reset = mv88e6352_g1_reset,
 };
 
+static const struct mv88e6xxx_ops mv88e6141_ops = {
+	/* MV88E6XXX_FAMILY_6341 */
+	.get_eeprom = mv88e6xxx_g2_get_eeprom8,
+	.set_eeprom = mv88e6xxx_g2_set_eeprom8,
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
+	.phy_read = mv88e6xxx_g2_smi_phy_read,
+	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
+	.port_set_speed = mv88e6390_port_set_speed,
+	.port_tag_remap = mv88e6095_port_tag_remap,
+	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
+	.port_pause_config = mv88e6097_port_pause_config,
+	.stats_snapshot = mv88e6390_g1_stats_snapshot,
+	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
+	.stats_get_strings = mv88e6320_stats_get_strings,
+	.stats_get_stats = mv88e6390_stats_get_stats,
+	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
+	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.mgmt_rsvd2cpu =  mv88e6390_g1_mgmt_rsvd2cpu,
+	.reset = mv88e6352_g1_reset,
+};
+
 static const struct mv88e6xxx_ops mv88e6341_ops = {
 	/* MV88E6XXX_FAMILY_6341 */
 	.get_eeprom = mv88e6xxx_g2_get_eeprom8,
@@ -3987,6 +4015,20 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.ops = &mv88e6321_ops,
 	},
 
+	[MV88E6141] = {
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6141,
+		.family = MV88E6XXX_FAMILY_6341,
+		.name = "Marvell 88E6341",
+		.num_databases = 4096,
+		.num_ports = 6,
+		.port_base_addr = 0x10,
+		.global1_addr = 0x1b,
+		.age_time_coeff = 15000,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6341,
+		.ops = &mv88e6141_ops,
+	},
+
 	[MV88E6341] = {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6341,
 		.family = MV88E6XXX_FAMILY_6341,
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index e0527db0ef6e..94d1e98d4e2c 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -87,6 +87,7 @@
 #define PORT_SWITCH_ID_PROD_NUM_6131	0x106
 #define PORT_SWITCH_ID_PROD_NUM_6320	0x115
 #define PORT_SWITCH_ID_PROD_NUM_6123	0x121
+#define PORT_SWITCH_ID_PROD_NUM_6141	0x340
 #define PORT_SWITCH_ID_PROD_NUM_6161	0x161
 #define PORT_SWITCH_ID_PROD_NUM_6165	0x165
 #define PORT_SWITCH_ID_PROD_NUM_6171	0x171
@@ -420,6 +421,7 @@ enum mv88e6xxx_model {
 	MV88E6097,
 	MV88E6123,
 	MV88E6131,
+	MV88E6141,
 	MV88E6161,
 	MV88E6165,
 	MV88E6171,
-- 
git-series 0.9.1
