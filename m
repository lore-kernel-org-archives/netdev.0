From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH v2 1/7] alx: treat flow control correctly in alx_set_pauseparam()
Date: Tue, 25 Jun 2013 20:38:17 +0200
Message-ID: <1372185503-24705-2-git-send-email-johannes@sipsolutions.net>
References: <1372185503-24705-1-git-send-email-johannes@sipsolutions.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:41271 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751581Ab3FYSi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 14:38:28 -0400
Received: by sipsolutions.net with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <johannes@sipsolutions.net>)
	id 1UrY8J-0003om-RQ
	for netdev@vger.kernel.org; Tue, 25 Jun 2013 20:38:27 +0200
In-Reply-To: <1372185503-24705-1-git-send-email-johannes@sipsolutions.net>
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
