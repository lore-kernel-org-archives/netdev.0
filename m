From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 03/20] batman-adv: Rename batadv_hardif *_free_ref function to *_put
Date: Tue, 23 Feb 2016 14:08:06 +0800
Message-ID: <1456207703-903-4-git-send-email-a@unstable.cc>
References: <1456207703-903-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:37151 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757041AbcBWGK5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 01:10:57 -0500
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
 net/batman-adv/bat_iv_ogm.c            | 10 +++++-----
 net/batman-adv/bridge_loop_avoidance.c | 18 +++++++++---------
 net/batman-adv/distributed-arp-table.c |  2 +-
 net/batman-adv/fragmentation.c         |  2 +-
 net/batman-adv/gateway_client.c        |  2 +-
 net/batman-adv/hard-interface.c        | 20 ++++++++++----------
 net/batman-adv/hard-interface.h        |  4 ++--
 net/batman-adv/icmp_socket.c           |  2 +-
 net/batman-adv/main.c                  |  2 +-
 net/batman-adv/network-coding.c        |  2 +-
 net/batman-adv/originator.c            | 16 ++++++++--------
 net/batman-adv/routing.c               |  8 ++++----
 net/batman-adv/send.c                  |  8 ++++----
 net/batman-adv/soft-interface.c        |  6 +++---
 net/batman-adv/sysfs.c                 |  8 ++++----
 net/batman-adv/translation-table.c     | 10 +++++-----
 16 files changed, 60 insertions(+), 60 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 32df38bfff25..f01ee23e35e6 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -515,7 +515,7 @@ static void batadv_iv_ogm_emit(struct batadv_forw_packet *forw_packet)
 
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 }
 
 /**
@@ -617,7 +617,7 @@ batadv_iv_ogm_can_aggregate(const struct batadv_ogm_packet *new_bat_ogm_packet,
 
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 	return res;
 }
 
@@ -711,9 +711,9 @@ out_nomem:
 	if (!own_packet)
 		atomic_inc(&bat_priv->batman_queue_left);
 out_free_outgoing:
-	batadv_hardif_free_ref(if_outgoing);
+	batadv_hardif_put(if_outgoing);
 out_free_incoming:
-	batadv_hardif_free_ref(if_incoming);
+	batadv_hardif_put(if_incoming);
 }
 
 /* aggregate a new packet into the existing ogm packet */
@@ -958,7 +958,7 @@ static void batadv_iv_ogm_schedule(struct batadv_hard_iface *hard_iface)
 
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 }
 
 /**
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 49008d98a8aa..b7167cf3e907 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -424,7 +424,7 @@ static void batadv_bla_send_claim(struct batadv_priv *bat_priv, u8 *mac,
 	netif_rx(skb);
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 }
 
 /**
@@ -1282,7 +1282,7 @@ void batadv_bla_status_update(struct net_device *net_dev)
 	 * so just call that one.
 	 */
 	batadv_bla_update_orig_address(bat_priv, primary_if, primary_if);
-	batadv_hardif_free_ref(primary_if);
+	batadv_hardif_put(primary_if);
 }
 
 /**
@@ -1356,7 +1356,7 @@ static void batadv_bla_periodic_work(struct work_struct *work)
 	}
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 
 	queue_delayed_work(batadv_event_workqueue, &bat_priv->bla.work,
 			   msecs_to_jiffies(BATADV_BLA_PERIOD_LENGTH));
@@ -1395,7 +1395,7 @@ int batadv_bla_init(struct batadv_priv *bat_priv)
 	if (primary_if) {
 		crc = crc16(0, primary_if->net_dev->dev_addr, ETH_ALEN);
 		bat_priv->bla.claim_dest.group = htons(crc);
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 	} else {
 		bat_priv->bla.claim_dest.group = 0; /* will be set later */
 	}
@@ -1599,7 +1599,7 @@ void batadv_bla_free(struct batadv_priv *bat_priv)
 		bat_priv->bla.backbone_hash = NULL;
 	}
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 }
 
 /**
@@ -1692,7 +1692,7 @@ handled:
 
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 	if (claim)
 		batadv_claim_free_ref(claim);
 	return ret;
@@ -1781,7 +1781,7 @@ handled:
 	ret = 1;
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 	if (claim)
 		batadv_claim_free_ref(claim);
 	return ret;
@@ -1839,7 +1839,7 @@ int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset)
 	}
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 	return 0;
 }
 
@@ -1904,6 +1904,6 @@ int batadv_bla_backbone_table_seq_print_text(struct seq_file *seq, void *offset)
 	}
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 	return 0;
 }
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 8f466e782bc7..00408d6231b6 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -840,7 +840,7 @@ int batadv_dat_cache_seq_print_text(struct seq_file *seq, void *offset)
 
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 	return 0;
 }
 
diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index 67cb224981fb..d13c5b601b67 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -512,7 +512,7 @@ bool batadv_frag_send_packet(struct sk_buff *skb,
 
 out_err:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 
 	return ret;
 }
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 9cb098f79155..7bf84c136205 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -663,7 +663,7 @@ int batadv_gw_client_seq_print_text(struct seq_file *seq, void *offset)
 
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 	return 0;
 }
 
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index e2aaa4cc39a7..b22b2775a0a5 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -226,7 +226,7 @@ static void batadv_primary_if_update_addr(struct batadv_priv *bat_priv,
 	batadv_bla_update_orig_address(bat_priv, primary_if, oldif);
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 }
 
 static void batadv_primary_if_select(struct batadv_priv *bat_priv,
@@ -250,7 +250,7 @@ static void batadv_primary_if_select(struct batadv_priv *bat_priv,
 
 out:
 	if (curr_hard_iface)
-		batadv_hardif_free_ref(curr_hard_iface);
+		batadv_hardif_put(curr_hard_iface);
 }
 
 static bool
@@ -409,7 +409,7 @@ batadv_hardif_activate_interface(struct batadv_hard_iface *hard_iface)
 
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 }
 
 static void
@@ -562,7 +562,7 @@ err_dev:
 	hard_iface->soft_iface = NULL;
 	dev_put(soft_iface);
 err:
-	batadv_hardif_free_ref(hard_iface);
+	batadv_hardif_put(hard_iface);
 	return ret;
 }
 
@@ -593,7 +593,7 @@ void batadv_hardif_disable_interface(struct batadv_hard_iface *hard_iface,
 		batadv_primary_if_select(bat_priv, new_if);
 
 		if (new_if)
-			batadv_hardif_free_ref(new_if);
+			batadv_hardif_put(new_if);
 	}
 
 	bat_priv->bat_algo_ops->bat_iface_disable(hard_iface);
@@ -616,11 +616,11 @@ void batadv_hardif_disable_interface(struct batadv_hard_iface *hard_iface,
 	}
 
 	hard_iface->soft_iface = NULL;
-	batadv_hardif_free_ref(hard_iface);
+	batadv_hardif_put(hard_iface);
 
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 }
 
 /**
@@ -639,7 +639,7 @@ static void batadv_hardif_remove_interface_finish(struct work_struct *work)
 
 	batadv_debugfs_del_hardif(hard_iface);
 	batadv_sysfs_del_hardif(&hard_iface->hardif_obj);
-	batadv_hardif_free_ref(hard_iface);
+	batadv_hardif_put(hard_iface);
 }
 
 static struct batadv_hard_iface *
@@ -794,10 +794,10 @@ static int batadv_hard_if_event(struct notifier_block *this,
 	}
 
 hardif_put:
-	batadv_hardif_free_ref(hard_iface);
+	batadv_hardif_put(hard_iface);
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 	return NOTIFY_DONE;
 }
 
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
index 5cecc6bc1b1e..d74f1983f33e 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -64,11 +64,11 @@ void batadv_update_min_mtu(struct net_device *soft_iface);
 void batadv_hardif_release(struct kref *ref);
 
 /**
- * batadv_hardif_free_ref - decrement the hard interface refcounter and possibly
+ * batadv_hardif_put - decrement the hard interface refcounter and possibly
  *  release it
  * @hard_iface: the hard interface to free
  */
-static inline void batadv_hardif_free_ref(struct batadv_hard_iface *hard_iface)
+static inline void batadv_hardif_put(struct batadv_hard_iface *hard_iface)
 {
 	kref_put(&hard_iface->refcount, batadv_hardif_release);
 }
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 7d944af59ef0..292a648c2f09 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -288,7 +288,7 @@ free_skb:
 	kfree_skb(skb);
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 	if (neigh_node)
 		batadv_neigh_node_free_ref(neigh_node);
 	if (orig_node)
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 5b573d1c8fcc..476554b3adce 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -287,7 +287,7 @@ batadv_seq_print_text_primary_if_get(struct seq_file *seq)
 	seq_printf(seq,
 		   "BATMAN mesh %s disabled - primary interface not active\n",
 		   net_dev->name);
-	batadv_hardif_free_ref(primary_if);
+	batadv_hardif_put(primary_if);
 	primary_if = NULL;
 
 out:
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 00f74d40d81a..3a42e26b2240 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -1950,7 +1950,7 @@ int batadv_nc_nodes_seq_print_text(struct seq_file *seq, void *offset)
 
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 	return 0;
 }
 
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 4df9be423583..3e959f48f845 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -196,7 +196,7 @@ static void batadv_neigh_ifinfo_release(struct kref *ref)
 	neigh_ifinfo = container_of(ref, struct batadv_neigh_ifinfo, refcount);
 
 	if (neigh_ifinfo->if_outgoing != BATADV_IF_DEFAULT)
-		batadv_hardif_free_ref(neigh_ifinfo->if_outgoing);
+		batadv_hardif_put(neigh_ifinfo->if_outgoing);
 
 	kfree_rcu(neigh_ifinfo, rcu);
 }
@@ -227,7 +227,7 @@ static void batadv_hardif_neigh_release(struct kref *ref)
 	hlist_del_init_rcu(&hardif_neigh->list);
 	spin_unlock_bh(&hardif_neigh->if_incoming->neigh_list_lock);
 
-	batadv_hardif_free_ref(hardif_neigh->if_incoming);
+	batadv_hardif_put(hardif_neigh->if_incoming);
 	kfree_rcu(hardif_neigh, rcu);
 }
 
@@ -273,7 +273,7 @@ static void batadv_neigh_node_release(struct kref *ref)
 	if (bao->bat_neigh_free)
 		bao->bat_neigh_free(neigh_node);
 
-	batadv_hardif_free_ref(neigh_node->if_incoming);
+	batadv_hardif_put(neigh_node->if_incoming);
 
 	kfree_rcu(neigh_node, rcu);
 }
@@ -544,7 +544,7 @@ batadv_hardif_neigh_create(struct batadv_hard_iface *hard_iface,
 
 	hardif_neigh = kzalloc(sizeof(*hardif_neigh), GFP_ATOMIC);
 	if (!hardif_neigh) {
-		batadv_hardif_free_ref(hard_iface);
+		batadv_hardif_put(hard_iface);
 		goto out;
 	}
 
@@ -707,7 +707,7 @@ int batadv_hardif_neigh_seq_print_text(struct seq_file *seq, void *offset)
 		   primary_if->net_dev->dev_addr, net_dev->name,
 		   bat_priv->bat_algo_ops->name);
 
-	batadv_hardif_free_ref(primary_if);
+	batadv_hardif_put(primary_if);
 
 	if (!bat_priv->bat_algo_ops->bat_neigh_print) {
 		seq_puts(seq,
@@ -732,7 +732,7 @@ static void batadv_orig_ifinfo_release(struct kref *ref)
 	orig_ifinfo = container_of(ref, struct batadv_orig_ifinfo, refcount);
 
 	if (orig_ifinfo->if_outgoing != BATADV_IF_DEFAULT)
-		batadv_hardif_free_ref(orig_ifinfo->if_outgoing);
+		batadv_hardif_put(orig_ifinfo->if_outgoing);
 
 	/* this is the last reference to this object */
 	router = rcu_dereference_protected(orig_ifinfo->router, true);
@@ -1250,7 +1250,7 @@ int batadv_orig_seq_print_text(struct seq_file *seq, void *offset)
 		   primary_if->net_dev->dev_addr, net_dev->name,
 		   bat_priv->bat_algo_ops->name);
 
-	batadv_hardif_free_ref(primary_if);
+	batadv_hardif_put(primary_if);
 
 	if (!bat_priv->bat_algo_ops->bat_orig_print) {
 		seq_puts(seq,
@@ -1306,7 +1306,7 @@ int batadv_orig_hardif_seq_print_text(struct seq_file *seq, void *offset)
 
 out:
 	if (hard_iface)
-		batadv_hardif_free_ref(hard_iface);
+		batadv_hardif_put(hard_iface);
 	return 0;
 }
 
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index d2c490df963b..a14ca42e927e 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -269,7 +269,7 @@ static int batadv_recv_my_icmp_packet(struct batadv_priv *bat_priv,
 	}
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 	if (orig_node)
 		batadv_orig_node_put(orig_node);
 	return ret;
@@ -317,7 +317,7 @@ static int batadv_recv_icmp_ttl_exceeded(struct batadv_priv *bat_priv,
 
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 	if (orig_node)
 		batadv_orig_node_put(orig_node);
 	return ret;
@@ -702,7 +702,7 @@ batadv_reroute_unicast_packet(struct batadv_priv *bat_priv,
 	ret = true;
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 	if (orig_node)
 		batadv_orig_node_put(orig_node);
 
@@ -808,7 +808,7 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 
 	ether_addr_copy(unicast_packet->dest, primary_if->net_dev->dev_addr);
 
-	batadv_hardif_free_ref(primary_if);
+	batadv_hardif_put(primary_if);
 
 	unicast_packet->ttvn = curr_ttvn;
 
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 261309ea5fec..c9cafc0f2d1b 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -246,7 +246,7 @@ bool batadv_send_skb_prepare_unicast_4addr(struct batadv_priv *bat_priv,
 	ret = true;
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 	return ret;
 }
 
@@ -409,9 +409,9 @@ static void batadv_forw_packet_free(struct batadv_forw_packet *forw_packet)
 {
 	kfree_skb(forw_packet->skb);
 	if (forw_packet->if_incoming)
-		batadv_hardif_free_ref(forw_packet->if_incoming);
+		batadv_hardif_put(forw_packet->if_incoming);
 	if (forw_packet->if_outgoing)
-		batadv_hardif_free_ref(forw_packet->if_outgoing);
+		batadv_hardif_put(forw_packet->if_outgoing);
 	kfree(forw_packet);
 }
 
@@ -497,7 +497,7 @@ out_and_inc:
 	atomic_inc(&bat_priv->bcast_queue_left);
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 	return NETDEV_TX_BUSY;
 }
 
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index d4490ff75edd..ca8fa4e28d4f 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -377,7 +377,7 @@ dropped_freed:
 	batadv_inc_counter(bat_priv, BATADV_CNT_TX_DROPPED);
 end:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 	return NETDEV_TX_OK;
 }
 
@@ -878,7 +878,7 @@ static int batadv_softif_slave_add(struct net_device *dev,
 
 out:
 	if (hard_iface)
-		batadv_hardif_free_ref(hard_iface);
+		batadv_hardif_put(hard_iface);
 	return ret;
 }
 
@@ -905,7 +905,7 @@ static int batadv_softif_slave_del(struct net_device *dev,
 
 out:
 	if (hard_iface)
-		batadv_hardif_free_ref(hard_iface);
+		batadv_hardif_put(hard_iface);
 	return ret;
 }
 
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index ab4382ba3855..0db7591a000f 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -771,7 +771,7 @@ static ssize_t batadv_show_mesh_iface(struct kobject *kobj,
 
 	length = sprintf(buff, "%s\n", ifname);
 
-	batadv_hardif_free_ref(hard_iface);
+	batadv_hardif_put(hard_iface);
 
 	return length;
 }
@@ -795,7 +795,7 @@ static ssize_t batadv_store_mesh_iface(struct kobject *kobj,
 	if (strlen(buff) >= IFNAMSIZ) {
 		pr_err("Invalid parameter for 'mesh_iface' setting received: interface name too long '%s'\n",
 		       buff);
-		batadv_hardif_free_ref(hard_iface);
+		batadv_hardif_put(hard_iface);
 		return -EINVAL;
 	}
 
@@ -829,7 +829,7 @@ static ssize_t batadv_store_mesh_iface(struct kobject *kobj,
 unlock:
 	rtnl_unlock();
 out:
-	batadv_hardif_free_ref(hard_iface);
+	batadv_hardif_put(hard_iface);
 	return ret;
 }
 
@@ -863,7 +863,7 @@ static ssize_t batadv_show_iface_status(struct kobject *kobj,
 		break;
 	}
 
-	batadv_hardif_free_ref(hard_iface);
+	batadv_hardif_put(hard_iface);
 
 	return length;
 }
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 107532c32c57..c6c633828bc8 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1060,7 +1060,7 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 	}
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 	return 0;
 }
 
@@ -1725,7 +1725,7 @@ int batadv_tt_global_seq_print_text(struct seq_file *seq, void *offset)
 	}
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 	return 0;
 }
 
@@ -2638,7 +2638,7 @@ static int batadv_send_tt_request(struct batadv_priv *bat_priv,
 
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 	if (ret && tt_req_node) {
 		spin_lock_bh(&bat_priv->tt.req_list_lock);
 		/* hlist_del_init() verifies tt_req_node still is in the list */
@@ -2895,7 +2895,7 @@ out:
 	if (orig_node)
 		batadv_orig_node_put(orig_node);
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 	kfree(tvlv_tt_data);
 	/* The packet was for this host, so it doesn't need to be re-routed */
 	return true;
@@ -3218,7 +3218,7 @@ static void batadv_send_roam_adv(struct batadv_priv *bat_priv, u8 *client,
 
 out:
 	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
+		batadv_hardif_put(primary_if);
 }
 
 static void batadv_tt_purge(struct work_struct *work)
-- 
2.7.1
