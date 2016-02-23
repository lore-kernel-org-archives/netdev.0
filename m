From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 05/20] batman-adv: Rename batadv_neigh_ifinfo *_free_ref function to *_put
Date: Tue, 23 Feb 2016 14:08:08 +0800
Message-ID: <1456207703-903-6-git-send-email-a@unstable.cc>
References: <1456207703-903-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:37788 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757041AbcBWGLE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 01:11:04 -0500
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
 net/batman-adv/bat_iv_ogm.c     | 24 ++++++++++++------------
 net/batman-adv/gateway_client.c | 14 +++++++-------
 net/batman-adv/network-coding.c |  4 ++--
 net/batman-adv/originator.c     |  8 ++++----
 net/batman-adv/originator.h     |  2 +-
 5 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 0f8742b4bfaa..7566cf6614f5 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1026,7 +1026,7 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 		neigh_ifinfo->bat_iv.tq_avg = tq_avg;
 		spin_unlock_bh(&tmp_neigh_node->ifinfo_lock);
 
-		batadv_neigh_ifinfo_free_ref(neigh_ifinfo);
+		batadv_neigh_ifinfo_put(neigh_ifinfo);
 		neigh_ifinfo = NULL;
 	}
 
@@ -1120,9 +1120,9 @@ out:
 	if (router)
 		batadv_neigh_node_put(router);
 	if (neigh_ifinfo)
-		batadv_neigh_ifinfo_free_ref(neigh_ifinfo);
+		batadv_neigh_ifinfo_put(neigh_ifinfo);
 	if (router_ifinfo)
-		batadv_neigh_ifinfo_free_ref(router_ifinfo);
+		batadv_neigh_ifinfo_put(router_ifinfo);
 }
 
 /**
@@ -1192,7 +1192,7 @@ static int batadv_iv_ogm_calc_tq(struct batadv_orig_node *orig_node,
 	neigh_ifinfo = batadv_neigh_ifinfo_new(neigh_node, if_outgoing);
 	if (neigh_ifinfo) {
 		neigh_rq_count = neigh_ifinfo->bat_iv.real_packet_count;
-		batadv_neigh_ifinfo_free_ref(neigh_ifinfo);
+		batadv_neigh_ifinfo_put(neigh_ifinfo);
 	} else {
 		neigh_rq_count = 0;
 	}
@@ -1353,7 +1353,7 @@ batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 		packet_count = bitmap_weight(bitmap,
 					     BATADV_TQ_LOCAL_WINDOW_SIZE);
 		neigh_ifinfo->bat_iv.real_packet_count = packet_count;
-		batadv_neigh_ifinfo_free_ref(neigh_ifinfo);
+		batadv_neigh_ifinfo_put(neigh_ifinfo);
 	}
 	rcu_read_unlock();
 
@@ -1566,7 +1566,7 @@ out_neigh:
 		batadv_orig_node_put(orig_neigh_node);
 out:
 	if (router_ifinfo)
-		batadv_neigh_ifinfo_free_ref(router_ifinfo);
+		batadv_neigh_ifinfo_put(router_ifinfo);
 	if (router)
 		batadv_neigh_node_put(router);
 	if (router_router)
@@ -1805,7 +1805,7 @@ batadv_iv_ogm_orig_print_neigh(struct batadv_orig_node *orig_node,
 			   neigh_node->addr,
 			   n_ifinfo->bat_iv.tq_avg);
 
-		batadv_neigh_ifinfo_free_ref(n_ifinfo);
+		batadv_neigh_ifinfo_put(n_ifinfo);
 	}
 }
 
@@ -1870,7 +1870,7 @@ static void batadv_iv_ogm_orig_print(struct batadv_priv *bat_priv,
 next:
 			batadv_neigh_node_put(neigh_node);
 			if (n_ifinfo)
-				batadv_neigh_ifinfo_free_ref(n_ifinfo);
+				batadv_neigh_ifinfo_put(n_ifinfo);
 		}
 		rcu_read_unlock();
 	}
@@ -1964,9 +1964,9 @@ static int batadv_iv_ogm_neigh_cmp(struct batadv_neigh_node *neigh1,
 
 out:
 	if (neigh1_ifinfo)
-		batadv_neigh_ifinfo_free_ref(neigh1_ifinfo);
+		batadv_neigh_ifinfo_put(neigh1_ifinfo);
 	if (neigh2_ifinfo)
-		batadv_neigh_ifinfo_free_ref(neigh2_ifinfo);
+		batadv_neigh_ifinfo_put(neigh2_ifinfo);
 
 	return diff;
 }
@@ -2007,9 +2007,9 @@ batadv_iv_ogm_neigh_is_sob(struct batadv_neigh_node *neigh1,
 
 out:
 	if (neigh1_ifinfo)
-		batadv_neigh_ifinfo_free_ref(neigh1_ifinfo);
+		batadv_neigh_ifinfo_put(neigh1_ifinfo);
 	if (neigh2_ifinfo)
-		batadv_neigh_ifinfo_free_ref(neigh2_ifinfo);
+		batadv_neigh_ifinfo_put(neigh2_ifinfo);
 
 	return ret;
 }
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index ea03c056a345..37972dfda400 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -237,7 +237,7 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 next:
 		batadv_neigh_node_put(router);
 		if (router_ifinfo)
-			batadv_neigh_ifinfo_free_ref(router_ifinfo);
+			batadv_neigh_ifinfo_put(router_ifinfo);
 	}
 	rcu_read_unlock();
 
@@ -354,7 +354,7 @@ out:
 	if (router)
 		batadv_neigh_node_put(router);
 	if (router_ifinfo)
-		batadv_neigh_ifinfo_free_ref(router_ifinfo);
+		batadv_neigh_ifinfo_put(router_ifinfo);
 }
 
 void batadv_gw_check_election(struct batadv_priv *bat_priv,
@@ -421,9 +421,9 @@ out:
 	if (router_orig)
 		batadv_neigh_node_put(router_orig);
 	if (router_gw_tq)
-		batadv_neigh_ifinfo_free_ref(router_gw_tq);
+		batadv_neigh_ifinfo_put(router_gw_tq);
 	if (router_orig_tq)
-		batadv_neigh_ifinfo_free_ref(router_orig_tq);
+		batadv_neigh_ifinfo_put(router_orig_tq);
 }
 
 /**
@@ -624,7 +624,7 @@ static int batadv_write_buffer_text(struct batadv_priv *bat_priv,
 		batadv_gw_node_free_ref(curr_gw);
 out:
 	if (router_ifinfo)
-		batadv_neigh_ifinfo_free_ref(router_ifinfo);
+		batadv_neigh_ifinfo_put(router_ifinfo);
 	if (router)
 		batadv_neigh_node_put(router);
 	return ret;
@@ -857,7 +857,7 @@ bool batadv_gw_out_of_range(struct batadv_priv *bat_priv,
 			goto out;
 
 		curr_tq_avg = curr_ifinfo->bat_iv.tq_avg;
-		batadv_neigh_ifinfo_free_ref(curr_ifinfo);
+		batadv_neigh_ifinfo_put(curr_ifinfo);
 
 		break;
 	case BATADV_GW_MODE_OFF:
@@ -875,7 +875,7 @@ bool batadv_gw_out_of_range(struct batadv_priv *bat_priv,
 
 	if ((curr_tq_avg - old_ifinfo->bat_iv.tq_avg) > BATADV_GW_THRESHOLD)
 		out_of_range = true;
-	batadv_neigh_ifinfo_free_ref(old_ifinfo);
+	batadv_neigh_ifinfo_put(old_ifinfo);
 
 out:
 	if (orig_dst_node)
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index e9409bad35e7..8b367659f1ae 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -1232,9 +1232,9 @@ out:
 	if (router_coding)
 		batadv_neigh_node_put(router_coding);
 	if (router_neigh_ifinfo)
-		batadv_neigh_ifinfo_free_ref(router_neigh_ifinfo);
+		batadv_neigh_ifinfo_put(router_neigh_ifinfo);
 	if (router_coding_ifinfo)
-		batadv_neigh_ifinfo_free_ref(router_coding_ifinfo);
+		batadv_neigh_ifinfo_put(router_coding_ifinfo);
 	return res;
 }
 
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 060f3a670d63..7965fe5947fb 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -202,11 +202,11 @@ static void batadv_neigh_ifinfo_release(struct kref *ref)
 }
 
 /**
- * batadv_neigh_ifinfo_free_ref - decrement the refcounter and possibly release
+ * batadv_neigh_ifinfo_put - decrement the refcounter and possibly release
  *  the neigh_ifinfo
  * @neigh_ifinfo: the neigh_ifinfo object to release
  */
-void batadv_neigh_ifinfo_free_ref(struct batadv_neigh_ifinfo *neigh_ifinfo)
+void batadv_neigh_ifinfo_put(struct batadv_neigh_ifinfo *neigh_ifinfo)
 {
 	kref_put(&neigh_ifinfo->refcount, batadv_neigh_ifinfo_release);
 }
@@ -259,7 +259,7 @@ static void batadv_neigh_node_release(struct kref *ref)
 
 	hlist_for_each_entry_safe(neigh_ifinfo, node_tmp,
 				  &neigh_node->ifinfo_list, list) {
-		batadv_neigh_ifinfo_free_ref(neigh_ifinfo);
+		batadv_neigh_ifinfo_put(neigh_ifinfo);
 	}
 
 	hardif_neigh = batadv_hardif_neigh_get(neigh_node->if_incoming,
@@ -966,7 +966,7 @@ batadv_purge_neigh_ifinfo(struct batadv_priv *bat_priv,
 			   neigh->addr, if_outgoing->net_dev->name);
 
 		hlist_del_rcu(&neigh_ifinfo->list);
-		batadv_neigh_ifinfo_free_ref(neigh_ifinfo);
+		batadv_neigh_ifinfo_put(neigh_ifinfo);
 	}
 
 	spin_unlock_bh(&neigh->ifinfo_lock);
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 78f409cf7fc3..b4fe82804fc4 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -59,7 +59,7 @@ batadv_neigh_ifinfo_new(struct batadv_neigh_node *neigh,
 struct batadv_neigh_ifinfo *
 batadv_neigh_ifinfo_get(struct batadv_neigh_node *neigh,
 			struct batadv_hard_iface *if_outgoing);
-void batadv_neigh_ifinfo_free_ref(struct batadv_neigh_ifinfo *neigh_ifinfo);
+void batadv_neigh_ifinfo_put(struct batadv_neigh_ifinfo *neigh_ifinfo);
 
 int batadv_hardif_neigh_seq_print_text(struct seq_file *seq, void *offset);
 
-- 
2.7.1
