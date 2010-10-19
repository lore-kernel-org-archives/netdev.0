From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next-2.6 2/5] jme: Add comment in jme_set_settings
Date: Tue, 19 Oct 2010 08:10:41 +0800
Message-ID: <1287447044-24471-2-git-send-email-cooldavid@cooldavid.org>
References: <1287447044-24471-1-git-send-email-cooldavid@cooldavid.org>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"linux-netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:49736 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754621Ab0JSAU5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 20:20:57 -0400
In-Reply-To: <1287447044-24471-1-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guo-Fu Tseng <cooldavid@cooldavid.org>

Explains what `fdc` variable is for.

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index e04f180..0ea0da3 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -2394,6 +2394,10 @@ jme_set_settings(struct net_device *netdev,
 	if (ecmd->speed == SPEED_1000 && ecmd->autoneg != AUTONEG_ENABLE)
 		return -EINVAL;
 
+	/*
+	 * Check If user changed duplex only while force_media.
+	 * Hardware would not generate link change interrupt.
+	 */
 	if (jme->mii_if.force_media &&
 	ecmd->autoneg != AUTONEG_ENABLE &&
 	(jme->mii_if.full_duplex != ecmd->duplex))
@@ -2403,10 +2407,9 @@ jme_set_settings(struct net_device *netdev,
 	rc = mii_ethtool_sset(&(jme->mii_if), ecmd);
 	spin_unlock_bh(&jme->phy_lock);
 
-	if (!rc && fdc)
-		jme_reset_link(jme);
-
 	if (!rc) {
+		if (fdc)
+			jme_reset_link(jme);
 		set_bit(JME_FLAG_SSET, &jme->flags);
 		jme->old_ecmd = *ecmd;
 	}
-- 
1.7.2.2

