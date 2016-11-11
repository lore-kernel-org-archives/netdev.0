From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 03/11] net: dsa: mv88e6xxx: Add the mv88e6390 family
Date: Fri, 11 Nov 2016 03:53:35 +0100
Message-ID: <1478832823-31471-4-git-send-email-andrew@lunn.ch>
References: <1478832823-31471-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34669 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965451AbcKKC53 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 21:57:29 -0500
In-Reply-To: <1478832823-31471-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the devices added to the tables, the probe will recognize the
switch. This however is not sufficient to make it work properly, other
changes are needed because of incompatibilities.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 .../devicetree/bindings/net/dsa/marvell.txt        |   3 +-
 drivers/net/dsa/mv88e6xxx/chip.c                   | 105 +++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h              |  25 +++++
 3 files changed, 132 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/dsa/marvell.txt b/Documentation/devicetree/bindings/net/dsa/marvell.txt
index 32025eb4b31b..f543483458a1 100644
--- a/Documentation/devicetree/bindings/net/dsa/marvell.txt
+++ b/Documentation/devicetree/bindings/net/dsa/marvell.txt
@@ -14,7 +14,8 @@ The properties described here are those specific to Marvell devices.
 Additional required and optional properties can be found in dsa.txt.
 
 Required properties:
-- compatible           : Should be one of "marvell,mv88e6085",
+- compatible	       : Should be one of "marvell,mv88e6085" or
+			 "marvell,mv88e6390"
 - reg                  : Address on the MII bus for the switch.
 
 Optional properties:
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index a4d52f0fdc90..066d9479c981 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3312,6 +3312,26 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.port_set_speed = mv88e6352_port_set_speed,
 };
 
+static const struct mv88e6xxx_ops mv88e6390_ops = {
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
+	.phy_read = mv88e6xxx_g2_smi_phy_read,
+	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
+	.port_set_speed = mv88e6390_port_set_speed,
+};
+
+static const struct mv88e6xxx_ops mv88e6390x_ops = {
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
+	.phy_read = mv88e6xxx_g2_smi_phy_read,
+	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
+	.port_set_speed = mv88e6390x_port_set_speed,
+};
+
 static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	[MV88E6085] = {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6085,
@@ -3467,6 +3487,47 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.ops = &mv88e6185_ops,
 	},
 
+	[MV88E6190] = {
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6190,
+		.family = MV88E6XXX_FAMILY_6390,
+		.name = "Marvell 88E6190",
+		.num_databases = 4096,
+		.num_ports = 11,	/* 10 + Z80 */
+		.port_base_addr = 0x0,
+		.global1_addr = 0x1b,
+		.age_time_coeff = 15000,
+		.g1_irqs = 9,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
+		.ops = &mv88e6390_ops,
+	},
+
+	[MV88E6190X] = {
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6190X,
+		.family = MV88E6XXX_FAMILY_6390,
+		.name = "Marvell 88E6190X",
+		.num_databases = 4096,
+		.num_ports = 11,	/* 10 + Z80 */
+		.port_base_addr = 0x0,
+		.global1_addr = 0x1b,
+		.age_time_coeff = 15000,
+		.g1_irqs = 9,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
+		.ops = &mv88e6390x_ops,
+	},
+
+	[MV88E6191] = {
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6191,
+		.family = MV88E6XXX_FAMILY_6390,
+		.name = "Marvell 88E6191",
+		.num_databases = 4096,
+		.num_ports = 11,	/* 10 + Z80 */
+		.port_base_addr = 0x0,
+		.global1_addr = 0x1b,
+		.age_time_coeff = 15000,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
+		.ops = &mv88e6390_ops,
+	},
+
 	[MV88E6240] = {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6240,
 		.family = MV88E6XXX_FAMILY_6352,
@@ -3481,6 +3542,20 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.ops = &mv88e6240_ops,
 	},
 
+	[MV88E6290] = {
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6290,
+		.family = MV88E6XXX_FAMILY_6390,
+		.name = "Marvell 88E6290",
+		.num_databases = 4096,
+		.num_ports = 11,	/* 10 + Z80 */
+		.port_base_addr = 0x0,
+		.global1_addr = 0x1b,
+		.age_time_coeff = 15000,
+		.g1_irqs = 9,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
+		.ops = &mv88e6390_ops,
+	},
+
 	[MV88E6320] = {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6320,
 		.family = MV88E6XXX_FAMILY_6320,
@@ -3550,6 +3625,32 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 		.ops = &mv88e6352_ops,
 	},
+	[MV88E6390] = {
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6390,
+		.family = MV88E6XXX_FAMILY_6390,
+		.name = "Marvell 88E6390",
+		.num_databases = 4096,
+		.num_ports = 11,	/* 10 + Z80 */
+		.port_base_addr = 0x0,
+		.global1_addr = 0x1b,
+		.age_time_coeff = 15000,
+		.g1_irqs = 9,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
+		.ops = &mv88e6390_ops,
+	},
+	[MV88E6390X] = {
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6390X,
+		.family = MV88E6XXX_FAMILY_6390,
+		.name = "Marvell 88E6390X",
+		.num_databases = 4096,
+		.num_ports = 11,	/* 10 + Z80 */
+		.port_base_addr = 0x0,
+		.global1_addr = 0x1b,
+		.age_time_coeff = 15000,
+		.g1_irqs = 9,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
+		.ops = &mv88e6390x_ops,
+	},
 };
 
 static const struct mv88e6xxx_info *mv88e6xxx_lookup_info(unsigned int prod_num)
@@ -3927,6 +4028,10 @@ static const struct of_device_id mv88e6xxx_of_match[] = {
 		.compatible = "marvell,mv88e6085",
 		.data = &mv88e6xxx_table[MV88E6085],
 	},
+	{
+		.compatible = "marvell,mv88e6390",
+		.data = &mv88e6xxx_table[MV88E6390],
+	},
 	{ /* sentinel */ },
 };
 
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 929613021eff..48915e5e3a3d 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -91,11 +91,17 @@
 #define PORT_SWITCH_ID_PROD_NUM_6175	0x175
 #define PORT_SWITCH_ID_PROD_NUM_6176	0x176
 #define PORT_SWITCH_ID_PROD_NUM_6185	0x1a7
+#define PORT_SWITCH_ID_PROD_NUM_6190	0x190
+#define PORT_SWITCH_ID_PROD_NUM_6190X	0x0a0
+#define PORT_SWITCH_ID_PROD_NUM_6191	0x191
 #define PORT_SWITCH_ID_PROD_NUM_6240	0x240
+#define PORT_SWITCH_ID_PROD_NUM_6290	0x290
 #define PORT_SWITCH_ID_PROD_NUM_6321	0x310
 #define PORT_SWITCH_ID_PROD_NUM_6352	0x352
 #define PORT_SWITCH_ID_PROD_NUM_6350	0x371
 #define PORT_SWITCH_ID_PROD_NUM_6351	0x375
+#define PORT_SWITCH_ID_PROD_NUM_6390	0x390
+#define PORT_SWITCH_ID_PROD_NUM_6390X	0x0a1
 #define PORT_CONTROL		0x04
 #define PORT_CONTROL_USE_CORE_TAG	BIT(15)
 #define PORT_CONTROL_DROP_ON_LOCK	BIT(14)
@@ -378,12 +384,18 @@ enum mv88e6xxx_model {
 	MV88E6175,
 	MV88E6176,
 	MV88E6185,
+	MV88E6190,
+	MV88E6190X,
+	MV88E6191,
 	MV88E6240,
+	MV88E6290,
 	MV88E6320,
 	MV88E6321,
 	MV88E6350,
 	MV88E6351,
 	MV88E6352,
+	MV88E6390,
+	MV88E6390X,
 };
 
 enum mv88e6xxx_family {
@@ -396,6 +408,7 @@ enum mv88e6xxx_family {
 	MV88E6XXX_FAMILY_6320,	/* 6320 6321 */
 	MV88E6XXX_FAMILY_6351,	/* 6171 6175 6350 6351 */
 	MV88E6XXX_FAMILY_6352,	/* 6172 6176 6240 6352 */
+	MV88E6XXX_FAMILY_6390,  /* 6190 6190X 6191 6290 6390 6390X */
 };
 
 enum mv88e6xxx_cap {
@@ -615,6 +628,18 @@ enum mv88e6xxx_cap {
 
 struct mv88e6xxx_ops;
 
+#define MV88E6XXX_FLAGS_FAMILY_6390	\
+	(MV88E6XXX_FLAG_EEE |		\
+	 MV88E6XXX_FLAG_GLOBAL2 |	\
+	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
+	 MV88E6XXX_FLAG_STU |		\
+	 MV88E6XXX_FLAG_TEMP |		\
+	 MV88E6XXX_FLAG_TEMP_LIMIT |	\
+	 MV88E6XXX_FLAG_VTU |		\
+	 MV88E6XXX_FLAGS_IRL |		\
+	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
+	 MV88E6XXX_FLAGS_PVT)
+
 struct mv88e6xxx_info {
 	enum mv88e6xxx_family family;
 	u16 prod_num;
-- 
2.10.2
