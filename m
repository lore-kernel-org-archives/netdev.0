From: Stefan Eichenberger <eichest@gmail.com>
Subject: [PATCH] net: dsa: mv88e6xxx: add MV88E6097 switch
Date: Tue, 22 Nov 2016 11:28:36 +0100
Message-ID: <20161122102836.23980-1-stefan.eichenberger@netmodule.com>
Cc: netdev@vger.kernel.org,
        Stefan Eichenberger <stefan.eichenberger@netmodule.com>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33531 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752746AbcKVK3r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 05:29:47 -0500
Received: by mail-qk0-f195.google.com with SMTP id x190so2574089qkb.0
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 02:29:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the MV88E6097 switch. The change was tested on an Armada
based platform with a MV88E6097 switch.

Signed-off-by: Stefan Eichenberger <stefan.eichenberger@netmodule.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 19 +++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  2 ++
 2 files changed, 21 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 5a9729b..20d6fb5 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3213,6 +3213,12 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.phy_write = mv88e6xxx_phy_ppu_write,
 };
 
+static const struct mv88e6xxx_ops mv88e6097_ops = {
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
+	.phy_read = mv88e6xxx_g2_smi_phy_read,
+	.phy_write = mv88e6xxx_g2_smi_phy_write,
+};
+
 static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_read,
@@ -3342,6 +3348,19 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
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
index e572121..42e28f8 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -74,6 +74,7 @@
 #define PORT_SWITCH_ID		0x03
 #define PORT_SWITCH_ID_PROD_NUM_6085	0x04a
 #define PORT_SWITCH_ID_PROD_NUM_6095	0x095
+#define PORT_SWITCH_ID_PROD_NUM_6097	0x099
 #define PORT_SWITCH_ID_PROD_NUM_6131	0x106
 #define PORT_SWITCH_ID_PROD_NUM_6320	0x115
 #define PORT_SWITCH_ID_PROD_NUM_6123	0x121
@@ -353,6 +354,7 @@
 enum mv88e6xxx_model {
 	MV88E6085,
 	MV88E6095,
+	MV88E6097,
 	MV88E6123,
 	MV88E6131,
 	MV88E6161,
-- 
2.9.3
