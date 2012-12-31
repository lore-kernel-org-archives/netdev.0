From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH RFC 10/15] via-rhine: WOL: remove duplication into a helper.
Date: Mon, 31 Dec 2012 16:25:44 +0100
Message-ID: <1356967549-5056-11-git-send-email-andi@lisas.de>
References: <1356967549-5056-1-git-send-email-andi@lisas.de>
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: andim2@users.sf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:54068 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928Ab2LaPen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 10:34:43 -0500
In-Reply-To: <1356967549-5056-1-git-send-email-andi@lisas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Mohr <andim2@users.sf.net>

Signed-off-by: Andreas Mohr <andim2@users.sf.net>
---
 drivers/net/ethernet/via/via-rhine.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index ca788c0..7e13d50 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -2168,6 +2168,14 @@ static void netdev_set_msglevel(struct net_device *dev, u32 value)
 	rp->msg_enable = value;
 }
 
+/* Indicates the set of WOL features supported by this card rev. */
+static inline u32
+rhine_wol_support_bits_get(struct rhine_private *rp)
+{
+	return	WAKE_PHY | WAKE_MAGIC |
+		WAKE_UCAST | WAKE_MCAST | WAKE_BCAST;	/* Untested */
+}
+
 static void
 rhine_ethop_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
@@ -2177,8 +2185,7 @@ rhine_ethop_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 		return;
 
 	spin_lock_irq(&rp->lock);
-	wol->supported = WAKE_PHY | WAKE_MAGIC |
-			 WAKE_UCAST | WAKE_MCAST | WAKE_BCAST;	/* Untested */
+	wol->supported = rhine_wol_support_bits_get(rp);
 	wol->wolopts = rp->wolopts;
 	spin_unlock_irq(&rp->lock);
 }
@@ -2187,13 +2194,11 @@ static int
 rhine_ethop_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct rhine_private *rp = netdev_priv(dev);
-	u32 support = WAKE_PHY | WAKE_MAGIC |
-		      WAKE_UCAST | WAKE_MCAST | WAKE_BCAST;	/* Untested */
 
 	if (!(rp->quirks & rqHaveWOL))
 		return -EINVAL;
 
-	if (wol->wolopts & ~support)
+	if (wol->wolopts & ~(rhine_wol_support_bits_get(rp)))
 		return -EINVAL;
 
 	spin_lock_irq(&rp->lock);
-- 
1.7.2.5
