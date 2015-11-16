From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next] phy: marvell: Add support for 88E1540 PHY
Date: Mon, 16 Nov 2015 23:34:41 +0100
Message-ID: <1447713281-26069-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34751 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751627AbbKPWes (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Nov 2015 17:34:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 88E1540 can be found embedded in the Marvell 88E6352 switch.  It
is compatible with the 88E1510, so add support for it, using the
88E1510 specific functions.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/marvell.c   | 16 ++++++++++++++++
 include/linux/marvell_phy.h |  1 +
 2 files changed, 17 insertions(+)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 5de8d5827536..0240552b50f3 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -1154,6 +1154,21 @@ static struct phy_driver marvell_drivers[] = {
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
+		.phy_id = MARVELL_PHY_ID_88E1540,
+		.phy_id_mask = MARVELL_PHY_ID_MASK,
+		.name = "Marvell 88E1540",
+		.features = PHY_GBIT_FEATURES,
+		.flags = PHY_HAS_INTERRUPT,
+		.config_aneg = &m88e1510_config_aneg,
+		.read_status = &marvell_read_status,
+		.ack_interrupt = &marvell_ack_interrupt,
+		.config_intr = &marvell_config_intr,
+		.did_interrupt = &m88e1121_did_interrupt,
+		.resume = &genphy_resume,
+		.suspend = &genphy_suspend,
+		.driver = { .owner = THIS_MODULE },
+	},
+	{
 		.phy_id = MARVELL_PHY_ID_88E3016,
 		.phy_id_mask = MARVELL_PHY_ID_MASK,
 		.name = "Marvell 88E3016",
@@ -1186,6 +1201,7 @@ static struct mdio_device_id __maybe_unused marvell_tbl[] = {
 	{ MARVELL_PHY_ID_88E1318S, MARVELL_PHY_ID_MASK },
 	{ MARVELL_PHY_ID_88E1116R, MARVELL_PHY_ID_MASK },
 	{ MARVELL_PHY_ID_88E1510, MARVELL_PHY_ID_MASK },
+	{ MARVELL_PHY_ID_88E1540, MARVELL_PHY_ID_MASK },
 	{ MARVELL_PHY_ID_88E3016, MARVELL_PHY_ID_MASK },
 	{ }
 };
diff --git a/include/linux/marvell_phy.h b/include/linux/marvell_phy.h
index e6982ac3200d..a57f0dfb6db7 100644
--- a/include/linux/marvell_phy.h
+++ b/include/linux/marvell_phy.h
@@ -16,6 +16,7 @@
 #define MARVELL_PHY_ID_88E1318S		0x01410e90
 #define MARVELL_PHY_ID_88E1116R		0x01410e40
 #define MARVELL_PHY_ID_88E1510		0x01410dd0
+#define MARVELL_PHY_ID_88E1540		0x01410eb0
 #define MARVELL_PHY_ID_88E3016		0x01410e60
 
 /* struct phy_device dev_flags definitions */
-- 
2.6.2
