From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 06/20] batman-adv: Prefix unicast static inline functions with batadv_
Date: Mon, 25 Jun 2012 08:54:30 +0200
Message-ID: <1340607284-29950-7-git-send-email-ordex@autistici.org>
References: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:30444 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754656Ab2FYGyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 02:54:44 -0400
In-Reply-To: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

All non-static symbols of batman-adv were prefixed with batadv_ to avoid
collisions with other symbols of the kernel. Other symbols of batman-adv
should use the same prefix to keep the naming scheme consistent.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/routing.c |    3 ++-
 net/batman-adv/unicast.h |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 0888f1e..3eb4a2e 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -869,7 +869,8 @@ static int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	}
 
 	if (unicast_packet->header.packet_type == BAT_UNICAST_FRAG &&
-	    frag_can_reassemble(skb, neigh_node->if_incoming->net_dev->mtu)) {
+	    batadv_frag_can_reassemble(skb,
+				       neigh_node->if_incoming->net_dev->mtu)) {
 
 		ret = batadv_frag_reassemble_skb(skb, bat_priv, &new_skb);
 
diff --git a/net/batman-adv/unicast.h b/net/batman-adv/unicast.h
index 87f8f89..9257b83 100644
--- a/net/batman-adv/unicast.h
+++ b/net/batman-adv/unicast.h
@@ -33,7 +33,7 @@ int batadv_frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 			 struct hard_iface *hard_iface,
 			 const uint8_t dstaddr[]);
 
-static inline int frag_can_reassemble(const struct sk_buff *skb, int mtu)
+static inline int batadv_frag_can_reassemble(const struct sk_buff *skb, int mtu)
 {
 	const struct unicast_frag_packet *unicast_packet;
 	int uneven_correction = 0;
-- 
1.7.9.4
