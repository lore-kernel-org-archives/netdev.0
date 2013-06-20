From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 1/6] alx: treat flow control correctly in alx_set_pauseparam()
Date: Fri, 21 Jun 2013 00:14:49 +0200
Message-ID: <1371766494-18979-2-git-send-email-johannes@sipsolutions.net>
References: <1371766494-18979-1-git-send-email-johannes@sipsolutions.net>
Cc: ben@decadent.org.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:49178 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030315Ab3FTWPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 18:15:01 -0400
In-Reply-To: <1371766494-18979-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even when alx_setup_speed_duplex() is called, we still
need to call alx_cfg_mac_flowcontrol() and set hw->flowctrl
if flow control changed.

This was a bug I accidentally introduced while simplifying
the original driver.

Reported-by: Ben Hutchings <ben@decadent.org.uk>
Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 drivers/net/ethernet/atheros/alx/ethtool.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/atheros/alx/ethtool.c b/drivers/net/ethernet/atheros/alx/ethtool.c
index 6fa2aec..50a91d0 100644
--- a/drivers/net/ethernet/atheros/alx/ethtool.c
+++ b/drivers/net/ethernet/atheros/alx/ethtool.c
@@ -187,7 +187,8 @@ static int alx_set_pauseparam(struct net_device *netdev,
 
 	if (reconfig_phy) {
 		err = alx_setup_speed_duplex(hw, hw->adv_cfg, fc);
-		return err;
+		if (err)
+			return err;
 	}
 
 	/* flow control on mac */
-- 
1.8.0
