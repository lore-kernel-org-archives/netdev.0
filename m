From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 10/13] batman-adv: Remove declaration of
	batman_skb_recv
Date: Sat, 29 Jan 2011 22:47:37 +0100
Message-ID: <1296337660-12376-11-git-send-email-sven@narfation.org>
References: <1296337660-12376-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
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

batman_skb_recv can be defined in hard-interface.c as static because it is
never used outside of that file.

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
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
