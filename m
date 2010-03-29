From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/3] sky2: avoid duplicate link up on Optima chip
Date: Mon, 29 Mar 2010 10:36:20 -0700
Message-ID: <20100329173712.815043115@vyatta.com>
References: <20100329173617.765470658@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:44277 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755176Ab0C2Rkv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Mar 2010 13:40:51 -0400
Content-Disposition: inline; filename=sky2-ul-link-up.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Optima version has feature to detect link quickly without PHY interrupt,
but it causes duplicate link up events.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2010-03-29 10:29:17.530956219 -0700
+++ b/drivers/net/sky2.c	2010-03-29 10:29:18.261894374 -0700
@@ -2146,7 +2146,8 @@ static void sky2_phy_intr(struct sky2_hw
 		   istatus, phystat);
 
 	if (istatus & PHY_M_IS_AN_COMPL) {
-		if (sky2_autoneg_done(sky2, phystat) == 0)
+		if (sky2_autoneg_done(sky2, phystat) == 0 &&
+		    !netif_carrier_ok(dev))
 			sky2_link_up(sky2);
 		goto out;
 	}

-- 

