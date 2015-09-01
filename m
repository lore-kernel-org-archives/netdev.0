From: Ahmed Amamou <ahmed@gandi.net>
Subject: [PATCH RFC v2 11/21] net: rbridge: clean up rbr_node on rbridge stop
Date: Tue,  1 Sep 2015 17:43:06 +0200
Message-ID: <1441122196-11662-12-git-send-email-ahmed@gandi.net>
References: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Cc: William Dauchy <william@gandi.net>, Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:50752 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752657AbbIAPxl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 11:53:41 -0400
In-Reply-To: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to avoid memleak need to clean all rbr_node once rbridge is
stopped

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
Signed-off-by: William Dauchy <william@gandi.net>
---
 net/bridge/rbr.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/bridge/rbr.c b/net/bridge/rbr.c
index 718deb3..67842fe 100644
--- a/net/bridge/rbr.c
+++ b/net/bridge/rbr.c
@@ -13,6 +13,7 @@
  */
 #include "br_private.h"
 #include "rbr_private.h"
+static void rbr_del_all(struct rbr *rbr);
 
 static struct rbr *add_rbr(struct net_bridge *br)
 {
@@ -55,8 +56,10 @@ static void br_trill_stop(struct net_bridge *br)
 	spin_unlock_bh(&br->lock);
 	old = br->rbr;
 	br->rbr = NULL;
-	if (likely(old))
+	if (likely(old)) {
+		rbr_del_all(old);
 		kfree(old);
+	}
 }
 
 void br_trill_set_enabled(struct net_bridge *br, unsigned long val)
-- 
2.1.4
