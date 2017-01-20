From: Sean Nyekjaer <sean.nyekjaer@prevas.dk>
Subject: [PATCH] net: phy: micrel: add KSZ8795 ethernet switch
Date: Fri, 20 Jan 2017 13:50:49 +0100
Message-ID: <20170120125049.121307-1-sean.nyekjaer@prevas.dk>
Cc: Sean Nyekjaer <sean.nyekjaer@prevas.dk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail02.prevas.se ([62.95.78.10]:62035 "EHLO mail02.prevas.se"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751996AbdATNFB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Jan 2017 08:05:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This ethernet switch have unfortunately the same phy id as KSZ8051.

Signed-off-by: Sean Nyekjaer <sean.nyekjaer@prevas.dk>
---
 drivers/net/phy/micrel.c   | 14 ++++++++++++++
 include/linux/micrel_phy.h |  2 ++
 2 files changed, 16 insertions(+)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index ea92d524d5a8..d47026c18974 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -1014,6 +1014,20 @@ static struct phy_driver ksphy_driver[] = {
 	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
+}, {
+	.phy_id		= PHY_ID_KSZ8795,
+	.phy_id_mask	= MICREL_PHY_ID_MASK,
+	.name		= "Micrel KSZ8795 Switch",
+	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= kszphy_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
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
