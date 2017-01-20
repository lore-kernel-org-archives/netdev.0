From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 6/8] net: phy: Marvell: Add mv88e6390 internal PHY
Date: Sat, 21 Jan 2017 00:31:00 +0100
Message-ID: <1484955062-26718-7-git-send-email-andrew@lunn.ch>
References: <1484955062-26718-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40321 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752330AbdATXbk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Jan 2017 18:31:40 -0500
In-Reply-To: <1484955062-26718-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6390 Ethernet switch has internal PHYs. These PHYs don't have
an model ID in the ID2 register. So the MDIO driver in the switch
intercepts reads to this register, and returns the switch family ID.
Extend the Marvell PHY driver by including this ID, and tread the PHY
as a 88E1540.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/marvell.c   | 20 ++++++++++++++++++++
 include/linux/marvell_phy.h |  6 ++++++
 2 files changed, 26 insertions(+)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 64229976ace1..d02bb58a8c99 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -2141,6 +2141,25 @@ static struct phy_driver marvell_drivers[] = {
 		.get_strings = marvell_get_strings,
 		.get_stats = marvell_get_stats,
 	},
+	{
+		.phy_id = MARVELL_PHY_ID_88E6390,
+		.phy_id_mask = MARVELL_PHY_ID_MASK,
+		.name = "Marvell 88E6390",
+		.features = PHY_GBIT_FEATURES,
+		.flags = PHY_HAS_INTERRUPT,
+		.probe = marvell_probe,
+		.config_init = &marvell_config_init,
+		.config_aneg = &m88e1510_config_aneg,
+		.read_status = &marvell_read_status,
+		.ack_interrupt = &marvell_ack_interrupt,
+		.config_intr = &marvell_config_intr,
+		.did_interrupt = &m88e1121_did_interrupt,
+		.resume = &genphy_resume,
+		.suspend = &genphy_suspend,
+		.get_sset_count = marvell_get_sset_count,
+		.get_strings = marvell_get_strings,
+		.get_stats = marvell_get_stats,
+	},
 };
 
 module_phy_driver(marvell_drivers);
@@ -2159,6 +2178,7 @@ static struct mdio_device_id __maybe_unused marvell_tbl[] = {
 	{ MARVELL_PHY_ID_88E1510, MARVELL_PHY_ID_MASK },
 	{ MARVELL_PHY_ID_88E1540, MARVELL_PHY_ID_MASK },
 	{ MARVELL_PHY_ID_88E3016, MARVELL_PHY_ID_MASK },
+	{ MARVELL_PHY_ID_88E6390, MARVELL_PHY_ID_MASK },
 	{ }
 };
 
diff --git a/include/linux/marvell_phy.h b/include/linux/marvell_phy.h
index a57f0dfb6db7..3d616d7f65bf 100644
--- a/include/linux/marvell_phy.h
+++ b/include/linux/marvell_phy.h
@@ -19,6 +19,12 @@
 #define MARVELL_PHY_ID_88E1540		0x01410eb0
 #define MARVELL_PHY_ID_88E3016		0x01410e60
 
+/* The MV88e6390 Ethernet switch contains embedded PHYs. These PHYs do
+ * not have a model ID. So the switch driver traps reads to the ID2
+ * register and returns the switch family ID
+ */
+#define MARVELL_PHY_ID_88E6390		0x01410f90
+
 /* struct phy_device dev_flags definitions */
 #define MARVELL_PHY_M1145_FLAGS_RESISTANCE	0x00000001
 #define MARVELL_PHY_M1118_DNS323_LEDS		0x00000002
-- 
2.11.0
