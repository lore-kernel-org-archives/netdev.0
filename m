From: Alexander Stein <alexander.stein@systec-electronic.com>
Subject: [PATCH 6/6] pch_gbe: remove shutdown and restart of interface after PHY settings change
Date: Mon, 26 May 2014 15:40:39 +0200
Message-ID: <1401111639-11507-6-git-send-email-alexander.stein@systec-electronic.com>
References: <1401111639-11507-1-git-send-email-alexander.stein@systec-electronic.com>
Cc: Daniel Krueger <daniel.krueger@systec-electronic.com>,
	netdev@vger.kernel.org,
	Alexander Stein <alexander.stein@systec-electronic.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webbox1416.server-home.net ([77.236.96.61]:58899 "EHLO
	webbox1416.server-home.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752508AbaEZNm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2014 09:42:29 -0400
In-Reply-To: <1401111639-11507-1-git-send-email-alexander.stein@systec-electronic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Krueger <daniel.krueger@systec-electronic.com>

This is not necessary. mii_ethtool_sset retriggers the autonegociation if
necessary automatically.

Signed-off-by: Daniel Krueger <daniel.krueger@systec-electronic.com>
Signed-off-by: Alexander Stein <alexander.stein@systec-electronic.com>
---
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
index fbfac98..2284042 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
@@ -128,13 +128,6 @@ static int pch_gbe_set_settings(struct net_device *netdev,
 	hw->phy.autoneg_advertised = ecmd->advertising;
 	hw->mac.autoneg = ecmd->autoneg;
 
-	/* reset the link */
-	if (netif_running(adapter->netdev)) {
-		pch_gbe_down(adapter);
-		ret = pch_gbe_up(adapter);
-	} else {
-		pch_gbe_reset(adapter);
-	}
 	return ret;
 }
 
-- 
1.8.5.5
