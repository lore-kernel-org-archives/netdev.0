From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 13/15] batman-adv: rename last_valid to last_seen
Date: Sun, 29 Apr 2012 10:57:45 +0200
Message-ID: <1335689867-8017-14-git-send-email-ordex@autistici.org>
References: <1335689867-8017-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:58191 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753757Ab2D2I47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2012 04:56:59 -0400
In-Reply-To: <1335689867-8017-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Acked-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c |    8 ++++----
 net/batman-adv/originator.c |   16 ++++++++--------
 net/batman-adv/types.h      |    8 ++++----
 3 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index e0aaf8c..8652a75 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -651,7 +651,7 @@ static void bat_iv_ogm_orig_update(struct bat_priv *bat_priv,
 	rcu_read_unlock();
 
 	orig_node->flags = batman_ogm_packet->flags;
-	neigh_node->last_valid = jiffies;
+	neigh_node->last_seen = jiffies;
 
 	spin_lock_bh(&neigh_node->tq_lock);
 	ring_buffer_set(neigh_node->tq_recv,
@@ -772,11 +772,11 @@ static int bat_iv_ogm_calc_tq(struct orig_node *orig_node,
 	if (!neigh_node)
 		goto out;
 
-	/* if orig_node is direct neighbor update neigh_node last_valid */
+	/* if orig_node is direct neighbor update neigh_node last_seen */
 	if (orig_node == orig_neigh_node)
-		neigh_node->last_valid = jiffies;
+		neigh_node->last_seen = jiffies;
 
-	orig_node->last_valid = jiffies;
+	orig_node->last_seen = jiffies;
 
 	/* find packet count of corresponding one hop neighbor */
 	spin_lock_bh(&orig_node->ogm_cnt_lock);
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 31d7b58..936b2e6 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -285,7 +285,7 @@ static bool purge_orig_neighbors(struct bat_priv *bat_priv,
 	hlist_for_each_entry_safe(neigh_node, node, node_tmp,
 				  &orig_node->neigh_list, list) {
 
-		if ((has_timed_out(neigh_node->last_valid, PURGE_TIMEOUT)) ||
+		if ((has_timed_out(neigh_node->last_seen, PURGE_TIMEOUT)) ||
 		    (neigh_node->if_incoming->if_status == IF_INACTIVE) ||
 		    (neigh_node->if_incoming->if_status == IF_NOT_IN_USE) ||
 		    (neigh_node->if_incoming->if_status == IF_TO_BE_REMOVED)) {
@@ -302,9 +302,9 @@ static bool purge_orig_neighbors(struct bat_priv *bat_priv,
 					neigh_node->if_incoming->net_dev->name);
 			else
 				bat_dbg(DBG_BATMAN, bat_priv,
-					"neighbor timeout: originator %pM, neighbor: %pM, last_valid: %lu\n",
+					"neighbor timeout: originator %pM, neighbor: %pM, last_seen: %lu\n",
 					orig_node->orig, neigh_node->addr,
-					(neigh_node->last_valid / HZ));
+					(neigh_node->last_seen / HZ));
 
 			neigh_purged = true;
 
@@ -327,10 +327,10 @@ static bool purge_orig_node(struct bat_priv *bat_priv,
 {
 	struct neigh_node *best_neigh_node;
 
-	if (has_timed_out(orig_node->last_valid, 2 * PURGE_TIMEOUT)) {
+	if (has_timed_out(orig_node->last_seen, 2 * PURGE_TIMEOUT)) {
 		bat_dbg(DBG_BATMAN, bat_priv,
-			"Originator timeout: originator %pM, last_valid %lu\n",
-			orig_node->orig, (orig_node->last_valid / HZ));
+			"Originator timeout: originator %pM, last_seen %lu\n",
+			orig_node->orig, (orig_node->last_seen / HZ));
 		return true;
 	} else {
 		if (purge_orig_neighbors(bat_priv, orig_node,
@@ -448,9 +448,9 @@ int orig_seq_print_text(struct seq_file *seq, void *offset)
 				goto next;
 
 			last_seen_secs = jiffies_to_msecs(jiffies -
-						orig_node->last_valid) / 1000;
+						orig_node->last_seen) / 1000;
 			last_seen_msecs = jiffies_to_msecs(jiffies -
-						orig_node->last_valid) % 1000;
+						orig_node->last_seen) % 1000;
 
 			seq_printf(seq, "%pM %4i.%03is   (%3i) %pM [%10s]:",
 				   orig_node->orig, last_seen_secs,
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index ed6db5c..5ca9b58 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -63,7 +63,7 @@ struct hard_iface {
 /**
  *	orig_node - structure for orig_list maintaining nodes of mesh
  *	@primary_addr: hosts primary interface address
- *	@last_valid: when last packet from this node was received
+ *	@last_seen: when last packet from this node was received
  *	@bcast_seqno_reset: time when the broadcast seqno window was reset
  *	@batman_seqno_reset: time when the batman seqno window was reset
  *	@gw_flags: flags related to gateway class
@@ -84,7 +84,7 @@ struct orig_node {
 	struct neigh_node __rcu *router; /* rcu protected pointer */
 	unsigned long *bcast_own;
 	uint8_t *bcast_own_sum;
-	unsigned long last_valid;
+	unsigned long last_seen;
 	unsigned long bcast_seqno_reset;
 	unsigned long batman_seqno_reset;
 	uint8_t gw_flags;
@@ -134,7 +134,7 @@ struct gw_node {
 
 /**
  *	neigh_node
- *	@last_valid: when last packet via this neighbor was received
+ *	@last_seen: when last packet via this neighbor was received
  */
 struct neigh_node {
 	struct hlist_node list;
@@ -145,7 +145,7 @@ struct neigh_node {
 	uint8_t tq_avg;
 	uint8_t last_ttl;
 	struct list_head bonding_list;
-	unsigned long last_valid;
+	unsigned long last_seen;
 	DECLARE_BITMAP(real_bits, TQ_LOCAL_WINDOW_SIZE);
 	atomic_t refcount;
 	struct rcu_head rcu;
-- 
1.7.9.4
