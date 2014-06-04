From: Andrew Ruder <andrew.ruder@elecsyscorp.com>
Subject: [PATCH 5/6] dm9000: handle initial link status
Date: Wed,  4 Jun 2014 17:28:48 -0500
Message-ID: <d785fb5ebfd4e6e9f0dc293452914f172dfe061c.1401920694.git.andrew.ruder@elecsyscorp.com>
References: <cover.1401920320.git.andrew.ruder@elecsyscorp.com>
Cc: Andrew Ruder <andrew.ruder@elecsyscorp.com>,
	Joseph CHANG <josright123@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from new1-smtp.messagingengine.com ([66.111.4.221]:59704 "EHLO
	new1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751919AbaFDWh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 18:37:57 -0400
Received: from compute3.internal (compute3.nyi.mail.srv.osa [10.202.2.43])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id C78F643F
	for <netdev@vger.kernel.org>; Wed,  4 Jun 2014 18:29:15 -0400 (EDT)
In-Reply-To: <cover.1401920320.git.andrew.ruder@elecsyscorp.com>
In-Reply-To: <cover.1401920694.git.andrew.ruder@elecsyscorp.com>
References: <cover.1401920694.git.andrew.ruder@elecsyscorp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On the DM9000A/DM9000B force the initial check of the link status.  The
DM9000A/B has a link status changed event and this interrupt bit isn't
always set out of reset when a cable is plugged in.  This results in the
driver not seeing the cable attached link status until the cable is
removed and plugged in again.

Signed-off-by: Andrew Ruder <andrew.ruder@elecsyscorp.com>
---
 drivers/net/ethernet/davicom/dm9000.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index d1a5b2f..eb9b704 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1326,7 +1326,8 @@ dm9000_open(struct net_device *dev)
 	mii_check_media(&db->mii, netif_msg_link(db), 1);
 	netif_start_queue(dev);
 
-	dm9000_schedule_poll(db);
+	/* Poll initial link status */
+	schedule_delayed_work(&db->phy_poll, 1);
 
 	return 0;
 }
-- 
1.9.0.rc3.12.gbc97e2d
