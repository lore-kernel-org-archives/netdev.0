From: Ahmed Amamou <ahmed@gandi.net>
Subject: [RFC PATCH 12/24] net: rbridge: Clean up rbr_node on rbridge stop
Date: Wed, 24 Sep 2014 17:52:08 +0200
Message-ID: <1411573940-14079-13-git-send-email-ahmed@gandi.net>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:39379 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752942AbaIXP6J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 11:58:09 -0400
In-Reply-To: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in order to avoid memleak need to clean all rbr_node once rbridge is stopped

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
Signed-off-by: William Dauchy <william@gandi.net>
---
 net/bridge/rbridge/rbr.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bridge/rbridge/rbr.c b/net/bridge/rbridge/rbr.c
index 1df8f8d..edd1e7c 100644
--- a/net/bridge/rbridge/rbr.c
+++ b/net/bridge/rbridge/rbr.c
@@ -13,6 +13,7 @@
  */
 #include "br_private.h"
 #include "rbr_private.h"
+static void rbr_del_all(struct rbr *rbr);
 
 static struct rbr *add_rbr(struct net_bridge *br)
 {
@@ -61,6 +62,7 @@ static void br_trill_stop(struct net_bridge *br)
 	br->rbr = NULL;
 	if (likely(old)) {
 		spin_lock_bh(&br->lock);
+		rbr_del_all(old);
 		kfree(old);
 		spin_unlock_bh(&br->lock);
 	}
-- 
1.9.1
