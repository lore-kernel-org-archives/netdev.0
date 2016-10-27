From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 13/17] batman-adv: Remove needless init of variables on stack
Date: Thu, 27 Oct 2016 21:01:46 +0200
Message-ID: <20161027190150.7880-14-sw@simonwunderlich.de>
References: <20161027190150.7880-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:38354 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942661AbcJ0TB7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 15:01:59 -0400
In-Reply-To: <20161027190150.7880-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Some variables are overwritten immediatelly in a functions. These don't
have to be initialized to a specific value on the stack because the value
will be overwritten before they will be used anywhere.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/bat_v.c          | 2 +-
 net/batman-adv/bat_v_ogm.c      | 4 ++--
 net/batman-adv/fragmentation.c  | 4 ++--
 net/batman-adv/gateway_client.c | 2 +-
 net/batman-adv/originator.c     | 8 ++++----
 net/batman-adv/send.c           | 2 +-
 6 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/batman-adv/bat_v.c b/net/batman-adv/bat_v.c
index e79f6f0..57c795c 100644
--- a/net/batman-adv/bat_v.c
+++ b/net/batman-adv/bat_v.c
@@ -787,7 +787,7 @@ static bool batadv_v_gw_is_eligible(struct batadv_priv *bat_priv,
 				    struct batadv_orig_node *curr_gw_orig,
 				    struct batadv_orig_node *orig_node)
 {
-	struct batadv_gw_node *curr_gw = NULL, *orig_gw = NULL;
+	struct batadv_gw_node *curr_gw, *orig_gw = NULL;
 	u32 gw_throughput, orig_throughput, threshold;
 	bool ret = false;
 
diff --git a/net/batman-adv/bat_v_ogm.c b/net/batman-adv/bat_v_ogm.c
index 1aeeadc..61ff5f8 100644
--- a/net/batman-adv/bat_v_ogm.c
+++ b/net/batman-adv/bat_v_ogm.c
@@ -401,7 +401,7 @@ static int batadv_v_ogm_metric_update(struct batadv_priv *bat_priv,
 				      struct batadv_hard_iface *if_incoming,
 				      struct batadv_hard_iface *if_outgoing)
 {
-	struct batadv_orig_ifinfo *orig_ifinfo = NULL;
+	struct batadv_orig_ifinfo *orig_ifinfo;
 	struct batadv_neigh_ifinfo *neigh_ifinfo = NULL;
 	bool protection_started = false;
 	int ret = -EINVAL;
@@ -486,7 +486,7 @@ static bool batadv_v_ogm_route_update(struct batadv_priv *bat_priv,
 				      struct batadv_hard_iface *if_outgoing)
 {
 	struct batadv_neigh_node *router = NULL;
-	struct batadv_orig_node *orig_neigh_node = NULL;
+	struct batadv_orig_node *orig_neigh_node;
 	struct batadv_neigh_node *orig_neigh_router = NULL;
 	struct batadv_neigh_ifinfo *router_ifinfo = NULL, *neigh_ifinfo = NULL;
 	u32 router_throughput, neigh_throughput;
diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index 0934730..1b2f5b9 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -252,7 +252,7 @@ batadv_frag_merge_packets(struct hlist_head *chain)
 {
 	struct batadv_frag_packet *packet;
 	struct batadv_frag_list_entry *entry;
-	struct sk_buff *skb_out = NULL;
+	struct sk_buff *skb_out;
 	int size, hdr_size = sizeof(struct batadv_frag_packet);
 
 	/* Remove first entry, as this is the destination for the rest of the
@@ -352,7 +352,7 @@ bool batadv_frag_skb_fwd(struct sk_buff *skb,
 			 struct batadv_orig_node *orig_node_src)
 {
 	struct batadv_priv *bat_priv = netdev_priv(recv_if->soft_iface);
-	struct batadv_orig_node *orig_node_dst = NULL;
+	struct batadv_orig_node *orig_node_dst;
 	struct batadv_neigh_node *neigh_node = NULL;
 	struct batadv_frag_packet *packet;
 	u16 total_size;
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index de055d6..69bfe98 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -704,7 +704,7 @@ bool batadv_gw_out_of_range(struct batadv_priv *bat_priv,
 {
 	struct batadv_neigh_node *neigh_curr = NULL;
 	struct batadv_neigh_node *neigh_old = NULL;
-	struct batadv_orig_node *orig_dst_node = NULL;
+	struct batadv_orig_node *orig_dst_node;
 	struct batadv_gw_node *gw_node = NULL;
 	struct batadv_gw_node *curr_gw = NULL;
 	struct batadv_neigh_ifinfo *curr_ifinfo, *old_ifinfo;
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 5f3bfc4..6af87c9 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -364,7 +364,7 @@ struct batadv_orig_ifinfo *
 batadv_orig_ifinfo_new(struct batadv_orig_node *orig_node,
 		       struct batadv_hard_iface *if_outgoing)
 {
-	struct batadv_orig_ifinfo *orig_ifinfo = NULL;
+	struct batadv_orig_ifinfo *orig_ifinfo;
 	unsigned long reset_time;
 
 	spin_lock_bh(&orig_node->neigh_list_lock);
@@ -520,7 +520,7 @@ batadv_hardif_neigh_create(struct batadv_hard_iface *hard_iface,
 			   const u8 *neigh_addr)
 {
 	struct batadv_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
-	struct batadv_hardif_neigh_node *hardif_neigh = NULL;
+	struct batadv_hardif_neigh_node *hardif_neigh;
 
 	spin_lock_bh(&hard_iface->neigh_list_lock);
 
@@ -563,7 +563,7 @@ static struct batadv_hardif_neigh_node *
 batadv_hardif_neigh_get_or_create(struct batadv_hard_iface *hard_iface,
 				  const u8 *neigh_addr)
 {
-	struct batadv_hardif_neigh_node *hardif_neigh = NULL;
+	struct batadv_hardif_neigh_node *hardif_neigh;
 
 	/* first check without locking to avoid the overhead */
 	hardif_neigh = batadv_hardif_neigh_get(hard_iface, neigh_addr);
@@ -683,7 +683,7 @@ batadv_neigh_node_get_or_create(struct batadv_orig_node *orig_node,
 				struct batadv_hard_iface *hard_iface,
 				const u8 *neigh_addr)
 {
-	struct batadv_neigh_node *neigh_node = NULL;
+	struct batadv_neigh_node *neigh_node;
 
 	/* first check without locking to avoid the overhead */
 	neigh_node = batadv_neigh_node_get(orig_node, hard_iface, neigh_addr);
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 8d4e1f5..e1e9136 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -562,7 +562,7 @@ int batadv_add_bcast_packet_to_list(struct batadv_priv *bat_priv,
 				    const struct sk_buff *skb,
 				    unsigned long delay)
 {
-	struct batadv_hard_iface *primary_if = NULL;
+	struct batadv_hard_iface *primary_if;
 	struct batadv_forw_packet *forw_packet;
 	struct batadv_bcast_packet *bcast_packet;
 	struct sk_buff *newskb;
-- 
2.10.1
