From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Subject: [PATCH v6 2/4] Marvell phy: add field to get errors from fiber link.
Date: Tue, 19 Jul 2016 11:13:11 +0200
Message-ID: <1468919593-27602-3-git-send-email-charles-antoine.couret@nexvision.fr>
References: <1468919593-27602-1-git-send-email-charles-antoine.couret@nexvision.fr>
Cc: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 6.mo3.mail-out.ovh.net ([188.165.43.173]:55901 "EHLO
	6.mo3.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566AbcGSJOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 05:14:37 -0400
Received: from player734.ha.ovh.net (b7.ovh.net [213.186.33.57])
	by mo3.mail-out.ovh.net (Postfix) with ESMTP id 85B4510043FC
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:14:35 +0200 (CEST)
In-Reply-To: <1468919593-27602-1-git-send-email-charles-antoine.couret@nexvision.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the fiber receiver error counter in the
statistics. Rename the current counter which is for copper errors to
phy_receive_errors_copper, so it is easy to distinguish copper from
fiber.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
---
 drivers/net/phy/marvell.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 75b9211..0dde7ca 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -151,6 +151,7 @@
 #define ADVERTISE_PAUSE_ASYM_FIBER	0x100
 
 #define REGISTER_LINK_STATUS	0x400
+#define NB_FIBER_STATS	1
 
 MODULE_DESCRIPTION("Marvell PHY driver");
 MODULE_AUTHOR("Andy Fleming");
@@ -164,8 +165,9 @@ struct marvell_hw_stat {
 };
 
 static struct marvell_hw_stat marvell_hw_stats[] = {
-	{ "phy_receive_errors", 0, 21, 16},
+	{ "phy_receive_errors_copper", 0, 21, 16},
 	{ "phy_idle_errors", 0, 10, 8 },
+	{ "phy_receive_errors_fiber", 1, 21, 16},
 };
 
 struct marvell_priv {
@@ -1236,7 +1238,10 @@ static int m88e1318_set_wol(struct phy_device *phydev, struct ethtool_wolinfo *w
 
 static int marvell_get_sset_count(struct phy_device *phydev)
 {
-	return ARRAY_SIZE(marvell_hw_stats);
+	if (phydev->supported & SUPPORTED_FIBRE)
+		return ARRAY_SIZE(marvell_hw_stats);
+	else
+		return ARRAY_SIZE(marvell_hw_stats) - NB_FIBER_STATS;
 }
 
 static void marvell_get_strings(struct phy_device *phydev, u8 *data)
-- 
2.7.4
