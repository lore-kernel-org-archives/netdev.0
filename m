From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 17/20] batman-adv: Prefix unicast non-static
	functions with batadv_
Date: Thu, 21 Jun 2012 18:57:53 +0200
Message-ID: <1340297876-29923-18-git-send-email-ordex@autistici.org>
References: <1340297876-29923-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1340297876-29923-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>

batman-adv can be compiled as part of the kernel instead of an module. In that
case the linker will see all non-static symbols of batman-adv and all other
non-static symbols of the kernel. This could lead to symbol collisions. A
prefix for the batman-adv symbols that defines their private namespace avoids
such a problem.

Reported-by: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/originator.c     |    4 ++--
 net/batman-adv/routing.c        |    9 +++++----
 net/batman-adv/soft-interface.c |    2 +-
 net/batman-adv/unicast.c        |   19 ++++++++++---------
 net/batman-adv/unicast.h        |   13 +++++++------
 5 files changed, 25 insertions(+), 22 deletions(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 030666c..9d77ede 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -138,7 +138,7 @@ static void orig_node_free_rcu(struct rcu_head *rcu)
 
 	spin_unlock_bh(&orig_node->neigh_list_lock);
 
-	frag_list_free(&orig_node->frag_list);
+	batadv_frag_list_free(&orig_node->frag_list);
 	batadv_tt_global_del_orig(orig_node->bat_priv, orig_node,
 				  "originator timed out");
 
@@ -372,7 +372,7 @@ static void _purge_orig(struct bat_priv *bat_priv)
 
 			if (has_timed_out(orig_node->last_frag_packet,
 					  FRAG_TIMEOUT))
-				frag_list_free(&orig_node->frag_list);
+				batadv_frag_list_free(&orig_node->frag_list);
 		}
 		spin_unlock_bh(list_lock);
 	}
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 8fb5ae3..4103f68 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -850,15 +850,16 @@ static int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	if (unicast_packet->header.packet_type == BAT_UNICAST &&
 	    atomic_read(&bat_priv->fragmentation) &&
 	    skb->len > neigh_node->if_incoming->net_dev->mtu) {
-		ret = frag_send_skb(skb, bat_priv,
-				    neigh_node->if_incoming, neigh_node->addr);
+		ret = batadv_frag_send_skb(skb, bat_priv,
+					   neigh_node->if_incoming,
+					   neigh_node->addr);
 		goto out;
 	}
 
 	if (unicast_packet->header.packet_type == BAT_UNICAST_FRAG &&
 	    frag_can_reassemble(skb, neigh_node->if_incoming->net_dev->mtu)) {
 
-		ret = frag_reassemble_skb(skb, bat_priv, &new_skb);
+		ret = batadv_frag_reassemble_skb(skb, bat_priv, &new_skb);
 
 		if (ret == NET_RX_DROP)
 			goto out;
@@ -1013,7 +1014,7 @@ int batadv_recv_ucast_frag_packet(struct sk_buff *skb,
 	/* packet for me */
 	if (is_my_mac(unicast_packet->dest)) {
 
-		ret = frag_reassemble_skb(skb, bat_priv, &new_skb);
+		ret = batadv_frag_reassemble_skb(skb, bat_priv, &new_skb);
 
 		if (ret == NET_RX_DROP)
 			return NET_RX_DROP;
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index a4b5e64..9fd19257 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -237,7 +237,7 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 				goto dropped;
 		}
 
-		ret = unicast_send_skb(skb, bat_priv);
+		ret = batadv_unicast_send_skb(skb, bat_priv);
 		if (ret != 0)
 			goto dropped_freed;
 	}
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 5e699db..e9d3bdd 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -101,7 +101,7 @@ static int frag_create_buffer(struct list_head *head)
 	for (i = 0; i < FRAG_BUFFER_SIZE; i++) {
 		tfp = kmalloc(sizeof(*tfp), GFP_ATOMIC);
 		if (!tfp) {
-			frag_list_free(head);
+			batadv_frag_list_free(head);
 			return -ENOMEM;
 		}
 		tfp->skb = NULL;
@@ -151,7 +151,7 @@ mov_tail:
 	return NULL;
 }
 
-void frag_list_free(struct list_head *head)
+void batadv_frag_list_free(struct list_head *head)
 {
 	struct frag_packet_list_entry *pf, *tmp_pf;
 
@@ -172,8 +172,8 @@ void frag_list_free(struct list_head *head)
  * or the skb could be reassembled (skb_new will point to the new packet and
  * skb was freed)
  */
-int frag_reassemble_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
-			struct sk_buff **new_skb)
+int batadv_frag_reassemble_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
+			       struct sk_buff **new_skb)
 {
 	struct orig_node *orig_node;
 	struct frag_packet_list_entry *tmp_frag_entry;
@@ -216,8 +216,8 @@ out:
 	return ret;
 }
 
-int frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
-		  struct hard_iface *hard_iface, const uint8_t dstaddr[])
+int batadv_frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
+			 struct hard_iface *hard_iface, const uint8_t dstaddr[])
 {
 	struct unicast_packet tmp_uc, *unicast_packet;
 	struct hard_iface *primary_if;
@@ -283,7 +283,7 @@ out:
 	return ret;
 }
 
-int unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv)
+int batadv_unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv)
 {
 	struct ethhdr *ethhdr = (struct ethhdr *)skb->data;
 	struct unicast_packet *unicast_packet;
@@ -342,8 +342,9 @@ find_router:
 				neigh_node->if_incoming->net_dev->mtu) {
 		/* send frag skb decreases ttl */
 		unicast_packet->header.ttl++;
-		ret = frag_send_skb(skb, bat_priv,
-				    neigh_node->if_incoming, neigh_node->addr);
+		ret = batadv_frag_send_skb(skb, bat_priv,
+					   neigh_node->if_incoming,
+					   neigh_node->addr);
 		goto out;
 	}
 
diff --git a/net/batman-adv/unicast.h b/net/batman-adv/unicast.h
index a9faf6b..657fe73 100644
--- a/net/batman-adv/unicast.h
+++ b/net/batman-adv/unicast.h
@@ -27,12 +27,13 @@
 #define FRAG_TIMEOUT 10000	/* purge frag list entries after time in ms */
 #define FRAG_BUFFER_SIZE 6	/* number of list elements in buffer */
 
-int frag_reassemble_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
-			struct sk_buff **new_skb);
-void frag_list_free(struct list_head *head);
-int unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv);
-int frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
-		  struct hard_iface *hard_iface, const uint8_t dstaddr[]);
+int batadv_frag_reassemble_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
+			       struct sk_buff **new_skb);
+void batadv_frag_list_free(struct list_head *head);
+int batadv_unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv);
+int batadv_frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
+			 struct hard_iface *hard_iface,
+			 const uint8_t dstaddr[]);
 
 static inline int frag_can_reassemble(const struct sk_buff *skb, int mtu)
 {
-- 
1.7.9.4
