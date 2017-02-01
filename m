From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next] net: phy: marvell: Add support for 88e1545 PHY
Date: Thu,  2 Feb 2017 00:35:03 +0100
Message-ID: <1485992103-23331-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52933 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750726AbdBAXfX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Feb 2017 18:35:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 88e1545 PHYs are discrete Marvell PHYs, found in a quad package on
the zii-devel-b board. Add support for it to the Marvell PHY driver.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---

NOTE: To apply cleanly, the "Work around missing PHY product ID in mv88e6390"
patches need to be applied first.

drivers/net/phy/marvell.c   | 21 +++++++++++++++++++++
 include/linux/marvell_phy.h |  1 +
 2 files changed, 22 insertions(+)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 1a0ac48cbc50..f9d0fa315a47 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -2123,6 +2123,26 @@ static struct phy_driver marvell_drivers[] = {
 		.get_stats = marvell_get_stats,
 	},
 	{
+		.phy_id = MARVELL_PHY_ID_88E1545,
+		.phy_id_mask = MARVELL_PHY_ID_MASK,
+		.name = "Marvell 88E1545",
+		.probe = m88e1510_probe,
+		.remove = &marvell_remove,
+		.features = PHY_GBIT_FEATURES,
+		.flags = PHY_HAS_INTERRUPT,
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
+	{
 		.phy_id = MARVELL_PHY_ID_88E3016,
 		.phy_id_mask = MARVELL_PHY_ID_MASK,
 		.name = "Marvell 88E3016",
@@ -2178,6 +2198,7 @@ static struct mdio_device_id __maybe_unused marvell_tbl[] = {
 	{ MARVELL_PHY_ID_88E1116R, MARVELL_PHY_ID_MASK },
 	{ MARVELL_PHY_ID_88E1510, MARVELL_PHY_ID_MASK },
 	{ MARVELL_PHY_ID_88E1540, MARVELL_PHY_ID_MASK },
+	{ MARVELL_PHY_ID_88E1545, MARVELL_PHY_ID_MASK },
 	{ MARVELL_PHY_ID_88E3016, MARVELL_PHY_ID_MASK },
 	{ MARVELL_PHY_ID_88E6390, MARVELL_PHY_ID_MASK },
 	{ }
diff --git a/include/linux/marvell_phy.h b/include/linux/marvell_phy.h
index 3d616d7f65bf..4055cf8cc978 100644
--- a/include/linux/marvell_phy.h
+++ b/include/linux/marvell_phy.h
@@ -17,6 +17,7 @@
 #define MARVELL_PHY_ID_88E1116R		0x01410e40
 #define MARVELL_PHY_ID_88E1510		0x01410dd0
 #define MARVELL_PHY_ID_88E1540		0x01410eb0
+#define MARVELL_PHY_ID_88E1545		0x01410ea0
 #define MARVELL_PHY_ID_88E3016		0x01410e60
 
 /* The MV88e6390 Ethernet switch contains embedded PHYs. These PHYs do
-- 
2.11.0
