From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] bridge: add some missing __rcu marks
Date: Thu, 14 Feb 2013 14:12:30 +0800
Message-ID: <1360822350-26882-1-git-send-email-amwang@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13026 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752445Ab3BNGMp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 01:12:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>


Cc: Vlad Yasevich <vyasevic@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 6d314c4..0f115ba 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -328,7 +328,7 @@ extern void br_dev_delete(struct net_device *dev, struct list_head *list);
 extern netdev_tx_t br_dev_xmit(struct sk_buff *skb,
 			       struct net_device *dev);
 #ifdef CONFIG_NET_POLL_CONTROLLER
-static inline struct netpoll_info *br_netpoll_info(struct net_bridge *br)
+static inline struct netpoll_info __rcu *br_netpoll_info(struct net_bridge *br)
 {
 	return br->dev->npinfo;
 }
@@ -345,7 +345,7 @@ static inline void br_netpoll_send_skb(const struct net_bridge_port *p,
 extern int br_netpoll_enable(struct net_bridge_port *p, gfp_t gfp);
 extern void br_netpoll_disable(struct net_bridge_port *p);
 #else
-static inline struct netpoll_info *br_netpoll_info(struct net_bridge *br)
+static inline struct netpoll_info __rcu *br_netpoll_info(struct net_bridge *br)
 {
 	return NULL;
 }
@@ -469,7 +469,7 @@ extern void br_multicast_free_pg(struct rcu_head *head);
 extern struct net_bridge_port_group *br_multicast_new_port_group(
 				struct net_bridge_port *port,
 				struct br_ip *group,
-				struct net_bridge_port_group *next,
+				struct net_bridge_port_group __rcu *next,
 				unsigned char state);
 extern void br_mdb_init(void);
 extern void br_mdb_uninit(void);
