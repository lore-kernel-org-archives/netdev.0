From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 6/9] batman-adv: Remove declaration of batman_skb_recv
Date: Mon, 31 Jan 2011 16:20:48 +0100
Message-ID: <1296487251-12552-7-git-send-email-sven@narfation.org>
References: <1296487251-12552-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:42659 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755996Ab1AaPVW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 10:21:22 -0500
In-Reply-To: <1296487251-12552-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

batman_skb_recv can be defined in hard-interface.c as static because it is
never used outside of that file.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/hard-interface.c |   11 +++++++++--
 net/batman-adv/hard-interface.h |    4 ----
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 4f95777..8a9cf7a 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -34,6 +34,12 @@
 /* protect update critical side of if_list - but not the content */
 static DEFINE_SPINLOCK(if_list_lock);
 
+
+static int batman_skb_recv(struct sk_buff *skb,
+			   struct net_device *dev,
+			   struct packet_type *ptype,
+			   struct net_device *orig_dev);
+
 static void hardif_free_rcu(struct rcu_head *rcu)
 {
 	struct batman_if *batman_if;
@@ -549,8 +555,9 @@ out:
 
 /* receive a packet with the batman ethertype coming on a hard
  * interface */
-int batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
-	struct packet_type *ptype, struct net_device *orig_dev)
+static int batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
+			   struct packet_type *ptype,
+			   struct net_device *orig_dev)
 {
 	struct bat_priv *bat_priv;
 	struct batman_packet *batman_packet;
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
index 30ec3b8..a42f5a4 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -35,10 +35,6 @@ struct batman_if *get_batman_if_by_netdev(struct net_device *net_dev);
 int hardif_enable_interface(struct batman_if *batman_if, char *iface_name);
 void hardif_disable_interface(struct batman_if *batman_if);
 void hardif_remove_interfaces(void);
-int batman_skb_recv(struct sk_buff *skb,
-				struct net_device *dev,
-				struct packet_type *ptype,
-				struct net_device *orig_dev);
 int hardif_min_mtu(struct net_device *soft_iface);
 void update_min_mtu(struct net_device *soft_iface);
 
-- 
1.7.2.3

