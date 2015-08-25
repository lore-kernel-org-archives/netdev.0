From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 05/15] batman-adv: rename batadv_new_tt_req_node to batadv_tt_req_node_new
Date: Tue, 25 Aug 2015 13:02:29 +0200
Message-ID: <1440500559-28368-6-git-send-email-antonio@meshcoding.com>
References: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:23255 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755227AbbHYLD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 07:03:56 -0400
In-Reply-To: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <mareklindner@neomailbox.ch>

Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/translation-table.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 6b5f718..3932df2 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -2272,11 +2272,16 @@ static void batadv_tt_req_purge(struct batadv_priv *bat_priv)
 	spin_unlock_bh(&bat_priv->tt.req_list_lock);
 }
 
-/* returns the pointer to the new tt_req_node struct if no request
- * has already been issued for this orig_node, NULL otherwise
+/**
+ * batadv_tt_req_node_new - search and possibly create a tt_req_node object
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig_node: orig node this request is being issued for
+ *
+ * Returns the pointer to the new tt_req_node struct if no request
+ * has already been issued for this orig_node, NULL otherwise.
  */
 static struct batadv_tt_req_node *
-batadv_new_tt_req_node(struct batadv_priv *bat_priv,
+batadv_tt_req_node_new(struct batadv_priv *bat_priv,
 		       struct batadv_orig_node *orig_node)
 {
 	struct batadv_tt_req_node *tt_req_node_tmp, *tt_req_node = NULL;
@@ -2505,7 +2510,7 @@ static int batadv_send_tt_request(struct batadv_priv *bat_priv,
 	/* The new tt_req will be issued only if I'm not waiting for a
 	 * reply from the same orig_node yet
 	 */
-	tt_req_node = batadv_new_tt_req_node(bat_priv, dst_orig_node);
+	tt_req_node = batadv_tt_req_node_new(bat_priv, dst_orig_node);
 	if (!tt_req_node)
 		goto out;
 
-- 
2.5.0
