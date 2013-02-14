From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v2] netpoll: add some missing __rcu marks in several places
Date: Thu, 14 Feb 2013 16:37:19 +0800
Message-ID: <1360831039-11418-1-git-send-email-amwang@redhat.com>
References: <20130213223935.122d035b@nehalam.linuxnetplumber.net>
Cc: Jiri Pirko <jiri@resnulli.us>, Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43576 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756353Ab3BNIhj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 03:37:39 -0500
In-Reply-To: <20130213223935.122d035b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

This fixes sparse warnings like the one below:

drivers/net/team/team.c:953:25: warning: incorrect type in return expression (different address spaces)
drivers/net/team/team.c:953:25:    expected struct netpoll_info *
drivers/net/team/team.c:953:25:    got struct netpoll_info [noderef] <asn:4>*npinfo

Cc: Jiri Pirko <jiri@resnulli.us>
Cc: Vlad Yasevich <vyasevic@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 94c1534..cc35a3e 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1300,7 +1300,7 @@ static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni, g
 	return err;
 }
 
-static struct netpoll_info *bond_netpoll_info(struct bonding *bond)
+static struct netpoll_info __rcu *bond_netpoll_info(struct bonding *bond)
 {
 	return bond->dev->npinfo;
 }
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 05c5efe..004fdd9 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -948,7 +948,7 @@ static void team_port_disable_netpoll(struct team_port *port)
 	kfree(np);
 }
 
-static struct netpoll_info *team_netpoll_info(struct team *team)
+static struct netpoll_info __rcu *team_netpoll_info(struct team *team)
 {
 	return team->dev->npinfo;
 }
@@ -962,7 +962,7 @@ static int team_port_enable_netpoll(struct team *team, struct team_port *port,
 static void team_port_disable_netpoll(struct team_port *port)
 {
 }
-static struct netpoll_info *team_netpoll_info(struct team *team)
+static struct netpoll_info __rcu *team_netpoll_info(struct team *team)
 {
 	return NULL;
 }
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
