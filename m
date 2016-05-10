From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 01/17] batman-adv: Remove unused parameter recv_if of batadv_interface_rx
Date: Wed, 11 May 2016 03:29:49 +0800
Message-ID: <1462908605-27412-2-git-send-email-a@unstable.cc>
References: <1462908605-27412-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:31343 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751874AbcEJTaz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 15:30:55 -0400
In-Reply-To: <1462908605-27412-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/routing.c        | 5 ++---
 net/batman-adv/soft-interface.c | 5 ++---
 net/batman-adv/soft-interface.h | 4 ++--
 3 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index b781bf753250..2ecfca246be4 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -912,7 +912,7 @@ int batadv_recv_unicast_packet(struct sk_buff *skb,
 							hdr_size))
 			goto rx_success;
 
-		batadv_interface_rx(recv_if->soft_iface, skb, recv_if, hdr_size,
+		batadv_interface_rx(recv_if->soft_iface, skb, hdr_size,
 				    orig_node);
 
 rx_success:
@@ -1122,8 +1122,7 @@ int batadv_recv_bcast_packet(struct sk_buff *skb,
 		goto rx_success;
 
 	/* broadcast for me */
-	batadv_interface_rx(recv_if->soft_iface, skb, recv_if, hdr_size,
-			    orig_node);
+	batadv_interface_rx(recv_if->soft_iface, skb, hdr_size, orig_node);
 
 rx_success:
 	ret = NET_RX_SUCCESS;
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index dfb4d56120b6..dc9a61a5122d 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -385,7 +385,6 @@ end:
  * batadv_interface_rx - receive ethernet frame on local batman-adv interface
  * @soft_iface: local interface which will receive the ethernet frame
  * @skb: ethernet frame for @soft_iface
- * @recv_if: interface on which the batman-adv packet was received
  * @hdr_size: size of already parsed batman-adv header
  * @orig_node: originator from which the batman-adv packet was sent
  *
@@ -400,8 +399,8 @@ end:
  * isolated clients.
  */
 void batadv_interface_rx(struct net_device *soft_iface,
-			 struct sk_buff *skb, struct batadv_hard_iface *recv_if,
-			 int hdr_size, struct batadv_orig_node *orig_node)
+			 struct sk_buff *skb, int hdr_size,
+			 struct batadv_orig_node *orig_node)
 {
 	struct batadv_bcast_packet *batadv_bcast_packet;
 	struct batadv_priv *bat_priv = netdev_priv(soft_iface);
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-interface.h
index 9ae265703d23..5942da3d03d5 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -27,8 +27,8 @@ struct sk_buff;
 
 int batadv_skb_head_push(struct sk_buff *skb, unsigned int len);
 void batadv_interface_rx(struct net_device *soft_iface,
-			 struct sk_buff *skb, struct batadv_hard_iface *recv_if,
-			 int hdr_size, struct batadv_orig_node *orig_node);
+			 struct sk_buff *skb, int hdr_size,
+			 struct batadv_orig_node *orig_node);
 struct net_device *batadv_softif_create(const char *name);
 void batadv_softif_destroy_sysfs(struct net_device *soft_iface);
 int batadv_softif_is_valid(const struct net_device *net_dev);
-- 
2.8.2
