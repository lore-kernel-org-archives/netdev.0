From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 07/17] batman-adv: remove unused callback
	from batadv_algo_ops struct
Date: Fri,  1 Jul 2016 15:08:59 +0200
Message-ID: <1467378549-9646-8-git-send-email-sw@simonwunderlich.de>
References: <1467378549-9646-1-git-send-email-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1467378549-9646-1-git-send-email-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>

Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 net/batman-adv/originator.c | 5 -----
 net/batman-adv/types.h      | 3 ---
 2 files changed, 8 deletions(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index b0bad57..076d258 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -251,10 +251,8 @@ static void batadv_neigh_node_release(struct kref *ref)
 	struct hlist_node *node_tmp;
 	struct batadv_neigh_node *neigh_node;
 	struct batadv_neigh_ifinfo *neigh_ifinfo;
-	struct batadv_algo_ops *bao;
 
 	neigh_node = container_of(ref, struct batadv_neigh_node, refcount);
-	bao = neigh_node->orig_node->bat_priv->bat_algo_ops;
 
 	hlist_for_each_entry_safe(neigh_ifinfo, node_tmp,
 				  &neigh_node->ifinfo_list, list) {
@@ -263,9 +261,6 @@ static void batadv_neigh_node_release(struct kref *ref)
 
 	batadv_hardif_neigh_put(neigh_node->hardif_neigh);
 
-	if (bao->bat_neigh_free)
-		bao->bat_neigh_free(neigh_node);
-
 	batadv_hardif_put(neigh_node->if_incoming);
 
 	kfree_rcu(neigh_node, rcu);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 6a577f4..114d150 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1278,8 +1278,6 @@ struct batadv_forw_packet {
  *  better than neigh2 for their respective outgoing interface from the metric
  *  prospective
  * @bat_neigh_print: print the single hop neighbor list (optional)
- * @bat_neigh_free: free the resources allocated by the routing algorithm for a
- *  neigh_node object
  * @bat_orig_print: print the originator table (optional)
  * @bat_orig_free: free the resources allocated by the routing algorithm for an
  *  orig_node object
@@ -1310,7 +1308,6 @@ struct batadv_algo_ops {
 		 struct batadv_neigh_node *neigh2,
 		 struct batadv_hard_iface *if_outgoing2);
 	void (*bat_neigh_print)(struct batadv_priv *priv, struct seq_file *seq);
-	void (*bat_neigh_free)(struct batadv_neigh_node *neigh);
 	/* orig_node handling API */
 	void (*bat_orig_print)(struct batadv_priv *priv, struct seq_file *seq,
 			       struct batadv_hard_iface *hard_iface);
-- 
2.8.1
