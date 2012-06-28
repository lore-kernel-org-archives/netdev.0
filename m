From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 01/18] batman-adv: Prefix unicast local static functions with batadv_
Date: Thu, 28 Jun 2012 11:34:10 +0200
Message-ID: <1340876067-28333-2-git-send-email-ordex@autistici.org>
References: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:30169 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932651Ab2F1Je0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 05:34:26 -0400
In-Reply-To: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

All non-static symbols of batman-adv were prefixed with batadv_ to avoid
collisions with other symbols of the kernel. Other symbols of batman-adv
should use the same prefix to keep the naming scheme consistent.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/unicast.c |   29 ++++++++++++++++-------------
 1 file changed, 16 insertions(+), 13 deletions(-)

diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index d021055..472436a 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -29,9 +29,10 @@
 #include "hard-interface.h"
 
 
-static struct sk_buff *frag_merge_packet(struct list_head *head,
-					 struct frag_packet_list_entry *tfp,
-					 struct sk_buff *skb)
+static struct sk_buff *
+batadv_frag_merge_packet(struct list_head *head,
+			 struct frag_packet_list_entry *tfp,
+			 struct sk_buff *skb)
 {
 	struct unicast_frag_packet *up =
 		(struct unicast_frag_packet *)skb->data;
@@ -75,7 +76,8 @@ err:
 	return NULL;
 }
 
-static void frag_create_entry(struct list_head *head, struct sk_buff *skb)
+static void batadv_frag_create_entry(struct list_head *head,
+				     struct sk_buff *skb)
 {
 	struct frag_packet_list_entry *tfp;
 	struct unicast_frag_packet *up =
@@ -91,7 +93,7 @@ static void frag_create_entry(struct list_head *head, struct sk_buff *skb)
 	return;
 }
 
-static int frag_create_buffer(struct list_head *head)
+static int batadv_frag_create_buffer(struct list_head *head)
 {
 	int i;
 	struct frag_packet_list_entry *tfp;
@@ -111,8 +113,9 @@ static int frag_create_buffer(struct list_head *head)
 	return 0;
 }
 
-static struct frag_packet_list_entry *frag_search_packet(struct list_head *head,
-					   const struct unicast_frag_packet *up)
+static struct frag_packet_list_entry *
+batadv_frag_search_packet(struct list_head *head,
+			  const struct unicast_frag_packet *up)
 {
 	struct frag_packet_list_entry *tfp;
 	struct unicast_frag_packet *tmp_up = NULL;
@@ -188,22 +191,22 @@ int batadv_frag_reassemble_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 	orig_node->last_frag_packet = jiffies;
 
 	if (list_empty(&orig_node->frag_list) &&
-	    frag_create_buffer(&orig_node->frag_list)) {
+	    batadv_frag_create_buffer(&orig_node->frag_list)) {
 		pr_debug("couldn't create frag buffer\n");
 		goto out;
 	}
 
-	tmp_frag_entry = frag_search_packet(&orig_node->frag_list,
-					    unicast_packet);
+	tmp_frag_entry = batadv_frag_search_packet(&orig_node->frag_list,
+						   unicast_packet);
 
 	if (!tmp_frag_entry) {
-		frag_create_entry(&orig_node->frag_list, skb);
+		batadv_frag_create_entry(&orig_node->frag_list, skb);
 		ret = NET_RX_SUCCESS;
 		goto out;
 	}
 
-	*new_skb = frag_merge_packet(&orig_node->frag_list, tmp_frag_entry,
-				     skb);
+	*new_skb = batadv_frag_merge_packet(&orig_node->frag_list,
+					    tmp_frag_entry, skb);
 	/* if not, merge failed */
 	if (*new_skb)
 		ret = NET_RX_SUCCESS;
-- 
1.7.9.4
