From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 17/17] batman-adv: Ensure that we really have route changes in update_route
Date: Mon, 30 May 2011 09:23:02 +0200
Message-ID: <1306740182-2665-18-git-send-email-sven@narfation.org>
References: <1306740182-2665-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:60280 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755187Ab1E3HXY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 May 2011 03:23:24 -0400
In-Reply-To: <1306740182-2665-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The debug output of update_route has tests for "route deleted" and "route
added". All other situations are handled as "route changed". This is not
true because neigh_node and curr_router could be both NULL.

The function is not called in this situation, but the code might be
interpreted wrong when reading it without this test.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/routing.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 90ae6f0..368ceeb 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -108,7 +108,7 @@ static void update_route(struct bat_priv *bat_priv, struct orig_node *orig_node,
 				    tt_buff, tt_buff_len);
 
 	/* route changed */
-	} else {
+	} else if (neigh_node && curr_router) {
 		bat_dbg(DBG_ROUTES, bat_priv,
 			"Changing route towards: %pM "
 			"(now via %pM - was via %pM)\n",
-- 
1.7.5.3

