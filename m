From: Sean Nyekjaer <sean.nyekjaer@prevas.dk>
Subject: [PATCH v2] net: phy: micrel: add support for KSZ8795
Date: Fri, 27 Jan 2017 08:46:23 +0100
Message-ID: <20170127074623.9200-1-sean.nyekjaer@prevas.dk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sean Nyekjaer <sean.nyekjaer@prevas.dk>, <andrew@lunn.ch>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail02.prevas.se ([62.95.78.10]:29610 "EHLO mail02.prevas.se"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754214AbdA0HtX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Jan 2017 02:49:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is adds support for the PHYs in the KSZ8795 5port managed switch.

It will allow to detect the link between the switch and the soc
and uses the same read_status functions as the KSZ8873MLL switch.

Signed-off-by: Sean Nyekjaer <sean.nyekjaer@prevas.dk>
---
Changes in v2:
 - Removed "switch" name

 drivers/net/phy/micrel.c   | 14 ++++++++++++++
 include/linux/micrel_phy.h |  2 ++
 2 files changed, 16 insertions(+)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index ea92d524d5a8..fab56c9350cf 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -1014,6 +1014,20 @@ static struct phy_driver ksphy_driver[] = {
 	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
+}, {
+	.phy_id		= PHY_ID_KSZ8795,
+	.phy_id_mask	= MICREL_PHY_ID_MASK,
+	.name		= "Micrel KSZ8795",
+	.features	= (SUPPORTED_Pause | SUPPORTED_Asym_Pause),
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= kszphy_config_init,
+	.config_aneg	= ksz8873mll_config_aneg,
+	.read_status	= ksz8873mll_read_status,
+	.get_sset_count = kszphy_get_sset_count,
+	.get_strings	= kszphy_get_strings,
+	.get_stats	= kszphy_get_stats,
+	.suspend	= genphy_suspend,
+	.resume		= genphy_resume,
 } };
 
 module_phy_driver(ksphy_driver);
diff --git a/include/linux/micrel_phy.h b/include/linux/micrel_phy.h
index 257173e0095e..f541da68d1e7 100644
--- a/include/linux/micrel_phy.h
+++ b/include/linux/micrel_phy.h
@@ -35,6 +35,8 @@
 #define PHY_ID_KSZ886X		0x00221430
 #define PHY_ID_KSZ8863		0x00221435
 
+#define PHY_ID_KSZ8795		0x00221550
+
 /* struct phy_device dev_flags definitions */
 #define MICREL_PHY_50MHZ_CLK	0x00000001
 #define MICREL_PHY_FXEN		0x00000002
-- 
2.11.0
