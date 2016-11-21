From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 03/11] net: dsa: mv88e6xxx: Add the mv88e6390 family
Date: Mon, 21 Nov 2016 23:26:57 +0100
Message-ID: <1479767225-13789-4-git-send-email-andrew@lunn.ch>
References: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47727 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753260AbcKUW2f (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 17:28:35 -0500
In-Reply-To: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the devices added to the tables, the probe will recognize the
switch. This however is not sufficient to make it work properly, other
changes are needed because of incompatibilities.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
v2: Change the compatible to 'marvell,mv88e6190'
Add _ops structures for all variants of the 6390 family.
---
 .../devicetree/bindings/net/dsa/marvell.txt        |   3 +-
 drivers/net/dsa/mv88e6xxx/chip.c                   | 155 +++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h              |  25 ++++
 3 files changed, 182 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/dsa/marvell.txt b/Documentation/devicetree/bindings/net/dsa/marvell.txt
index 32025eb4b31b..b3dd6b40e0de 100644
--- a/Documentation/devicetree/bindings/net/dsa/marvell.txt
+++ b/Documentation/devicetree/bindings/net/dsa/marvell.txt
@@ -14,7 +14,8 @@ The properties described here are those specific to Marvell devices.
 Additional required and optional properties can be found in dsa.txt.
 
 Required properties:
-- compatible           : Should be one of "marvell,mv88e6085",
+- compatible	       : Should be one of "marvell,mv88e6085" or
+			 "marvell,mv88e6190"
 - reg                  : Address on the MII bus for the switch.
 
 Optional properties:
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index c0152125680f..02d1b3529ee4 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3262,6 +3262,36 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 };
 
+static const struct mv88e6xxx_ops mv88e6190_ops = {
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
+	.phy_read = mv88e6xxx_g2_smi_phy_read,
+	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
+	.port_set_speed = mv88e6390_port_set_speed,
+};
+
+static const struct mv88e6xxx_ops mv88e6190x_ops = {
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
+	.phy_read = mv88e6xxx_g2_smi_phy_read,
+	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
+	.port_set_speed = mv88e6390x_port_set_speed,
+};
+
+static const struct mv88e6xxx_ops mv88e6191_ops = {
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
+	.phy_read = mv88e6xxx_g2_smi_phy_read,
+	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
+	.port_set_speed = mv88e6390_port_set_speed,
+};
+
 static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
@@ -3274,6 +3304,16 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.port_set_speed = mv88e6352_port_set_speed,
 };
 
+static const struct mv88e6xxx_ops mv88e6290_ops = {
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
+	.phy_read = mv88e6xxx_g2_smi_phy_read,
+	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
+	.port_set_speed = mv88e6390_port_set_speed,
+};
+
 static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
@@ -3328,6 +3368,36 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
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
+static const struct mv88e6xxx_ops mv88e6391_ops = {
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
+	.phy_read = mv88e6xxx_g2_smi_phy_read,
+	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
+	.port_set_speed = mv88e6390_port_set_speed,
+};
+
 static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	[MV88E6085] = {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6085,
@@ -3483,6 +3553,47 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
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
+		.ops = &mv88e6190_ops,
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
+		.ops = &mv88e6190x_ops,
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
+		.ops = &mv88e6391_ops,
+	},
+
 	[MV88E6240] = {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6240,
 		.family = MV88E6XXX_FAMILY_6352,
@@ -3497,6 +3608,20 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
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
+		.ops = &mv88e6290_ops,
+	},
+
 	[MV88E6320] = {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6320,
 		.family = MV88E6XXX_FAMILY_6320,
@@ -3566,6 +3691,32 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
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
@@ -3949,6 +4100,10 @@ static const struct of_device_id mv88e6xxx_of_match[] = {
 		.compatible = "marvell,mv88e6085",
 		.data = &mv88e6xxx_table[MV88E6085],
 	},
+	{
+		.compatible = "marvell,mv88e6190",
+		.data = &mv88e6xxx_table[MV88E6190],
+	},
 	{ /* sentinel */ },
 };
 
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index a3869504f881..de179c59f5cf 100644
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
