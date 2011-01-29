From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 07/13] batman-adv: remove unused parameters
Date: Sat, 29 Jan 2011 22:47:34 +0100
Message-ID: <1296337660-12376-8-git-send-email-sven@narfation.org>
References: <1296337660-12376-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1296337660-12376-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
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

From: Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>

Some function parameters are obsolete now and can be removed.

Reported-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/originator.c |    2 +-
 net/batman-adv/routing.c    |   15 ++++++---------
 net/batman-adv/routing.h    |    3 +--
 net/batman-adv/send.c       |    4 ++--
 4 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 6b7fb6b..3c5c889 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -247,7 +247,7 @@ static bool purge_orig_node(struct bat_priv *bat_priv,
 				      orig_node->hna_buff_len);
 			/* update bonding candidates, we could have lost
 			 * some candidates. */
-			update_bonding_candidates(bat_priv, orig_node);
+			update_bonding_candidates(orig_node);
 		}
 	}
 
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index a8cd389..e946dc9 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -433,8 +433,7 @@ static char count_real_packets(struct ethhdr *ethhdr,
 }
 
 /* copy primary address for bonding */
-static void mark_bonding_address(struct bat_priv *bat_priv,
-				 struct orig_node *orig_node,
+static void mark_bonding_address(struct orig_node *orig_node,
 				 struct orig_node *orig_neigh_node,
 				 struct batman_packet *batman_packet)
 
@@ -447,8 +446,7 @@ static void mark_bonding_address(struct bat_priv *bat_priv,
 }
 
 /* mark possible bond.candidates in the neighbor list */
-void update_bonding_candidates(struct bat_priv *bat_priv,
-			       struct orig_node *orig_node)
+void update_bonding_candidates(struct orig_node *orig_node)
 {
 	int candidates;
 	int interference_candidate;
@@ -730,9 +728,8 @@ void receive_bat_packet(struct ethhdr *ethhdr,
 		update_orig(bat_priv, orig_node, ethhdr, batman_packet,
 			    if_incoming, hna_buff, hna_buff_len, is_duplicate);
 
-	mark_bonding_address(bat_priv, orig_node,
-			     orig_neigh_node, batman_packet);
-	update_bonding_candidates(bat_priv, orig_node);
+	mark_bonding_address(orig_node, orig_neigh_node, batman_packet);
+	update_bonding_candidates(orig_node);
 
 	/* is single hop (direct) neighbor */
 	if (is_single_hop_neigh) {
@@ -866,7 +863,7 @@ static int recv_my_icmp_packet(struct bat_priv *bat_priv,
 }
 
 static int recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
-				  struct sk_buff *skb, size_t icmp_len)
+				  struct sk_buff *skb)
 {
 	struct orig_node *orig_node;
 	struct icmp_packet *icmp_packet;
@@ -978,7 +975,7 @@ int recv_icmp_packet(struct sk_buff *skb, struct batman_if *recv_if)
 
 	/* TTL exceeded */
 	if (icmp_packet->ttl < 2)
-		return recv_icmp_ttl_exceeded(bat_priv, skb, hdr_size);
+		return recv_icmp_ttl_exceeded(bat_priv, skb);
 
 	ret = NET_RX_DROP;
 
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index f108f23..725cc38 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -42,7 +42,6 @@ int recv_vis_packet(struct sk_buff *skb, struct batman_if *recv_if);
 int recv_bat_packet(struct sk_buff *skb, struct batman_if *recv_if);
 struct neigh_node *find_router(struct bat_priv *bat_priv,
 		struct orig_node *orig_node, struct batman_if *recv_if);
-void update_bonding_candidates(struct bat_priv *bat_priv,
-			       struct orig_node *orig_node);
+void update_bonding_candidates(struct orig_node *orig_node);
 
 #endif /* _NET_BATMAN_ADV_ROUTING_H_ */
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index b89b9f7..77f8297 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -49,7 +49,7 @@ static unsigned long own_send_time(struct bat_priv *bat_priv)
 }
 
 /* when do we schedule a forwarded packet to be sent */
-static unsigned long forward_send_time(struct bat_priv *bat_priv)
+static unsigned long forward_send_time(void)
 {
 	return jiffies + msecs_to_jiffies(random32() % (JITTER/2));
 }
@@ -356,7 +356,7 @@ void schedule_forward_packet(struct orig_node *orig_node,
 	else
 		batman_packet->flags &= ~DIRECTLINK;
 
-	send_time = forward_send_time(bat_priv);
+	send_time = forward_send_time();
 	add_bat_packet_to_list(bat_priv,
 			       (unsigned char *)batman_packet,
 			       sizeof(struct batman_packet) + hna_buff_len,
-- 
1.7.2.3
