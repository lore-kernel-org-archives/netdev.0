From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 04/20] batman-adv: Rename batadv_neigh_node *_free_ref function to *_put
Date: Tue, 23 Feb 2016 14:08:07 +0800
Message-ID: <1456207703-903-5-git-send-email-a@unstable.cc>
References: <1456207703-903-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:24535 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757041AbcBWGLB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 01:11:01 -0500
In-Reply-To: <1456207703-903-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The batman-adv source code is the only place in the kernel which uses the
*_free_ref naming scheme for the *_put functions. Changing it to *_put
makes it more consistent and makes it easier to understand the connection
to the *_get functions.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/bat_iv_ogm.c            | 16 ++++++++--------
 net/batman-adv/distributed-arp-table.c |  2 +-
 net/batman-adv/fragmentation.c         |  2 +-
 net/batman-adv/gateway_client.c        | 14 +++++++-------
 net/batman-adv/icmp_socket.c           |  2 +-
 net/batman-adv/network-coding.c        |  4 ++--
 net/batman-adv/originator.c            | 16 ++++++++--------
 net/batman-adv/originator.h            |  2 +-
 net/batman-adv/routing.c               | 14 +++++++-------
 net/batman-adv/send.c                  |  2 +-
 net/batman-adv/translation-table.c     |  6 +++---
 11 files changed, 40 insertions(+), 40 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index f01ee23e35e6..0f8742b4bfaa 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1005,7 +1005,7 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 		    tmp_neigh_node->if_incoming == if_incoming &&
 		    kref_get_unless_zero(&tmp_neigh_node->refcount)) {
 			if (WARN(neigh_node, "too many matching neigh_nodes"))
-				batadv_neigh_node_free_ref(neigh_node);
+				batadv_neigh_node_put(neigh_node);
 			neigh_node = tmp_neigh_node;
 			continue;
 		}
@@ -1116,9 +1116,9 @@ unlock:
 	rcu_read_unlock();
 out:
 	if (neigh_node)
-		batadv_neigh_node_free_ref(neigh_node);
+		batadv_neigh_node_put(neigh_node);
 	if (router)
-		batadv_neigh_node_free_ref(router);
+		batadv_neigh_node_put(router);
 	if (neigh_ifinfo)
 		batadv_neigh_ifinfo_free_ref(neigh_ifinfo);
 	if (router_ifinfo)
@@ -1265,7 +1265,7 @@ static int batadv_iv_ogm_calc_tq(struct batadv_orig_node *orig_node,
 
 out:
 	if (neigh_node)
-		batadv_neigh_node_free_ref(neigh_node);
+		batadv_neigh_node_put(neigh_node);
 	return ret;
 }
 
@@ -1568,11 +1568,11 @@ out:
 	if (router_ifinfo)
 		batadv_neigh_ifinfo_free_ref(router_ifinfo);
 	if (router)
-		batadv_neigh_node_free_ref(router);
+		batadv_neigh_node_put(router);
 	if (router_router)
-		batadv_neigh_node_free_ref(router_router);
+		batadv_neigh_node_put(router_router);
 	if (orig_neigh_router)
-		batadv_neigh_node_free_ref(orig_neigh_router);
+		batadv_neigh_node_put(orig_neigh_router);
 	if (hardif_neigh)
 		batadv_hardif_neigh_free_ref(hardif_neigh);
 
@@ -1868,7 +1868,7 @@ static void batadv_iv_ogm_orig_print(struct batadv_priv *bat_priv,
 			batman_count++;
 
 next:
-			batadv_neigh_node_free_ref(neigh_node);
+			batadv_neigh_node_put(neigh_node);
 			if (n_ifinfo)
 				batadv_neigh_ifinfo_free_ref(n_ifinfo);
 		}
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 00408d6231b6..919f3445fff3 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -674,7 +674,7 @@ static bool batadv_dat_send_data(struct batadv_priv *bat_priv,
 			ret = true;
 		}
 free_neigh:
-		batadv_neigh_node_free_ref(neigh_node);
+		batadv_neigh_node_put(neigh_node);
 free_orig:
 		batadv_orig_node_put(cand[i].orig_node);
 	}
diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index d13c5b601b67..adb9c3989add 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -387,7 +387,7 @@ out:
 	if (orig_node_dst)
 		batadv_orig_node_put(orig_node_dst);
 	if (neigh_node)
-		batadv_neigh_node_free_ref(neigh_node);
+		batadv_neigh_node_put(neigh_node);
 	return ret;
 }
 
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 7bf84c136205..ea03c056a345 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -235,7 +235,7 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 		batadv_gw_node_free_ref(gw_node);
 
 next:
-		batadv_neigh_node_free_ref(router);
+		batadv_neigh_node_put(router);
 		if (router_ifinfo)
 			batadv_neigh_ifinfo_free_ref(router_ifinfo);
 	}
@@ -352,7 +352,7 @@ out:
 	if (next_gw)
 		batadv_gw_node_free_ref(next_gw);
 	if (router)
-		batadv_neigh_node_free_ref(router);
+		batadv_neigh_node_put(router);
 	if (router_ifinfo)
 		batadv_neigh_ifinfo_free_ref(router_ifinfo);
 }
@@ -417,9 +417,9 @@ out:
 	if (curr_gw_orig)
 		batadv_orig_node_put(curr_gw_orig);
 	if (router_gw)
-		batadv_neigh_node_free_ref(router_gw);
+		batadv_neigh_node_put(router_gw);
 	if (router_orig)
-		batadv_neigh_node_free_ref(router_orig);
+		batadv_neigh_node_put(router_orig);
 	if (router_gw_tq)
 		batadv_neigh_ifinfo_free_ref(router_gw_tq);
 	if (router_orig_tq)
@@ -626,7 +626,7 @@ out:
 	if (router_ifinfo)
 		batadv_neigh_ifinfo_free_ref(router_ifinfo);
 	if (router)
-		batadv_neigh_node_free_ref(router);
+		batadv_neigh_node_put(router);
 	return ret;
 }
 
@@ -885,8 +885,8 @@ out:
 	if (gw_node)
 		batadv_gw_node_free_ref(gw_node);
 	if (neigh_old)
-		batadv_neigh_node_free_ref(neigh_old);
+		batadv_neigh_node_put(neigh_old);
 	if (neigh_curr)
-		batadv_neigh_node_free_ref(neigh_curr);
+		batadv_neigh_node_put(neigh_curr);
 	return out_of_range;
 }
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 292a648c2f09..6268f08b7154 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -290,7 +290,7 @@ out:
 	if (primary_if)
 		batadv_hardif_put(primary_if);
 	if (neigh_node)
-		batadv_neigh_node_free_ref(neigh_node);
+		batadv_neigh_node_put(neigh_node);
 	if (orig_node)
 		batadv_orig_node_put(orig_node);
 	return len;
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 3a42e26b2240..e9409bad35e7 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -1228,9 +1228,9 @@ static bool batadv_nc_code_packets(struct batadv_priv *bat_priv,
 	res = true;
 out:
 	if (router_neigh)
-		batadv_neigh_node_free_ref(router_neigh);
+		batadv_neigh_node_put(router_neigh);
 	if (router_coding)
-		batadv_neigh_node_free_ref(router_coding);
+		batadv_neigh_node_put(router_coding);
 	if (router_neigh_ifinfo)
 		batadv_neigh_ifinfo_free_ref(router_neigh_ifinfo);
 	if (router_coding_ifinfo)
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 3e959f48f845..060f3a670d63 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -279,11 +279,11 @@ static void batadv_neigh_node_release(struct kref *ref)
 }
 
 /**
- * batadv_neigh_node_free_ref - decrement the neighbors refcounter and possibly
+ * batadv_neigh_node_put - decrement the neighbors refcounter and possibly
  *  release it
  * @neigh_node: neigh neighbor to free
  */
-void batadv_neigh_node_free_ref(struct batadv_neigh_node *neigh_node)
+void batadv_neigh_node_put(struct batadv_neigh_node *neigh_node)
 {
 	kref_put(&neigh_node->refcount, batadv_neigh_node_release);
 }
@@ -737,7 +737,7 @@ static void batadv_orig_ifinfo_release(struct kref *ref)
 	/* this is the last reference to this object */
 	router = rcu_dereference_protected(orig_ifinfo->router, true);
 	if (router)
-		batadv_neigh_node_free_ref(router);
+		batadv_neigh_node_put(router);
 
 	kfree_rcu(orig_ifinfo, rcu);
 }
@@ -793,7 +793,7 @@ static void batadv_orig_node_release(struct kref *ref)
 	hlist_for_each_entry_safe(neigh_node, node_tmp,
 				  &orig_node->neigh_list, list) {
 		hlist_del_rcu(&neigh_node->list);
-		batadv_neigh_node_free_ref(neigh_node);
+		batadv_neigh_node_put(neigh_node);
 	}
 
 	hlist_for_each_entry_safe(orig_ifinfo, node_tmp,
@@ -1069,7 +1069,7 @@ batadv_purge_orig_neighbors(struct batadv_priv *bat_priv,
 			neigh_purged = true;
 
 			hlist_del_rcu(&neigh_node->list);
-			batadv_neigh_node_free_ref(neigh_node);
+			batadv_neigh_node_put(neigh_node);
 		} else {
 			/* only necessary if not the whole neighbor is to be
 			 * deleted, but some interface has been removed.
@@ -1108,7 +1108,7 @@ batadv_find_best_neighbor(struct batadv_priv *bat_priv,
 			continue;
 
 		if (best)
-			batadv_neigh_node_free_ref(best);
+			batadv_neigh_node_put(best);
 
 		best = neigh;
 	}
@@ -1154,7 +1154,7 @@ static bool batadv_purge_orig_node(struct batadv_priv *bat_priv,
 	batadv_update_route(bat_priv, orig_node, BATADV_IF_DEFAULT,
 			    best_neigh_node);
 	if (best_neigh_node)
-		batadv_neigh_node_free_ref(best_neigh_node);
+		batadv_neigh_node_put(best_neigh_node);
 
 	/* ... then for all other interfaces. */
 	rcu_read_lock();
@@ -1171,7 +1171,7 @@ static bool batadv_purge_orig_node(struct batadv_priv *bat_priv,
 		batadv_update_route(bat_priv, orig_node, hard_iface,
 				    best_neigh_node);
 		if (best_neigh_node)
-			batadv_neigh_node_free_ref(best_neigh_node);
+			batadv_neigh_node_put(best_neigh_node);
 	}
 	rcu_read_unlock();
 
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index c151f6a8f5ec..78f409cf7fc3 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -49,7 +49,7 @@ struct batadv_neigh_node *
 batadv_neigh_node_new(struct batadv_orig_node *orig_node,
 		      struct batadv_hard_iface *hard_iface,
 		      const u8 *neigh_addr);
-void batadv_neigh_node_free_ref(struct batadv_neigh_node *neigh_node);
+void batadv_neigh_node_put(struct batadv_neigh_node *neigh_node);
 struct batadv_neigh_node *
 batadv_orig_router_get(struct batadv_orig_node *orig_node,
 		       const struct batadv_hard_iface *if_outgoing);
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index a14ca42e927e..9107f69873ea 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -98,7 +98,7 @@ static void _batadv_update_route(struct batadv_priv *bat_priv,
 	}
 
 	if (curr_router)
-		batadv_neigh_node_free_ref(curr_router);
+		batadv_neigh_node_put(curr_router);
 
 	/* increase refcount of new best neighbor */
 	if (neigh_node && !kref_get_unless_zero(&neigh_node->refcount))
@@ -111,7 +111,7 @@ static void _batadv_update_route(struct batadv_priv *bat_priv,
 
 	/* decrease refcount of previous best neighbor */
 	if (curr_router)
-		batadv_neigh_node_free_ref(curr_router);
+		batadv_neigh_node_put(curr_router);
 }
 
 /**
@@ -138,7 +138,7 @@ void batadv_update_route(struct batadv_priv *bat_priv,
 
 out:
 	if (router)
-		batadv_neigh_node_free_ref(router);
+		batadv_neigh_node_put(router);
 }
 
 /**
@@ -545,7 +545,7 @@ batadv_find_router(struct batadv_priv *bat_priv,
 next:
 		/* free references */
 		if (cand_router) {
-			batadv_neigh_node_free_ref(cand_router);
+			batadv_neigh_node_put(cand_router);
 			cand_router = NULL;
 		}
 		batadv_orig_ifinfo_free_ref(cand);
@@ -562,17 +562,17 @@ next:
 	 * 3) there is no candidate at all, return the default router
 	 */
 	if (next_candidate) {
-		batadv_neigh_node_free_ref(router);
+		batadv_neigh_node_put(router);
 
 		/* remove references to first candidate, we don't need it. */
 		if (first_candidate) {
-			batadv_neigh_node_free_ref(first_candidate_router);
+			batadv_neigh_node_put(first_candidate_router);
 			batadv_orig_ifinfo_free_ref(first_candidate);
 		}
 		router = next_candidate_router;
 		orig_node->last_bonding_candidate = next_candidate;
 	} else if (first_candidate) {
-		batadv_neigh_node_free_ref(router);
+		batadv_neigh_node_put(router);
 
 		/* refcounting has already been done in the loop above. */
 		router = first_candidate_router;
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index c9cafc0f2d1b..caff32cf6fe7 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -153,7 +153,7 @@ int batadv_send_skb_to_orig(struct sk_buff *skb,
 
 out:
 	if (neigh_node)
-		batadv_neigh_node_free_ref(neigh_node);
+		batadv_neigh_node_put(neigh_node);
 
 	return ret;
 }
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index c6c633828bc8..132635aa7b11 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1586,20 +1586,20 @@ batadv_transtable_best_orig(struct batadv_priv *bat_priv,
 		if (best_router &&
 		    bao->bat_neigh_cmp(router, BATADV_IF_DEFAULT,
 				       best_router, BATADV_IF_DEFAULT) <= 0) {
-			batadv_neigh_node_free_ref(router);
+			batadv_neigh_node_put(router);
 			continue;
 		}
 
 		/* release the refcount for the "old" best */
 		if (best_router)
-			batadv_neigh_node_free_ref(best_router);
+			batadv_neigh_node_put(best_router);
 
 		best_entry = orig_entry;
 		best_router = router;
 	}
 
 	if (best_router)
-		batadv_neigh_node_free_ref(best_router);
+		batadv_neigh_node_put(best_router);
 
 	return best_entry;
 }
-- 
2.7.1
