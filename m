From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v4] netpoll: fix some sparse warnings in various places
Date: Sat, 16 Feb 2013 16:37:53 +0800
Message-ID: <1361003873-20622-1-git-send-email-amwang@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38879 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751425Ab3BPIiG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Feb 2013 03:38:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

This fixes sparse warnings like the one below:

drivers/net/team/team.c:953:25: warning: incorrect type in return expression (different address spaces)
drivers/net/team/team.c:953:25:    expected struct netpoll_info *
drivers/net/team/team.c:953:25:    got struct netpoll_info [noderef] <asn:4>*npinfo

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: Vlad Yasevich <vyasevic@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 94c1534..71ad0f2 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1302,7 +1302,7 @@ static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni, g
 
 static struct netpoll_info *bond_netpoll_info(struct bonding *bond)
 {
-	return bond->dev->npinfo;
+	return rcu_access_pointer(bond->dev->npinfo);
 }
 
 #else
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 05c5efe..03e5949 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -950,7 +950,7 @@ static void team_port_disable_netpoll(struct team_port *port)
 
 static struct netpoll_info *team_netpoll_info(struct team *team)
 {
-	return team->dev->npinfo;
+	return rcu_access_pointer(team->dev->npinfo);
 }
 
 #else
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 6d314c4..699d5c4 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -330,7 +330,7 @@ extern netdev_tx_t br_dev_xmit(struct sk_buff *skb,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static inline struct netpoll_info *br_netpoll_info(struct net_bridge *br)
 {
-	return br->dev->npinfo;
+	return rcu_access_pointer(br->dev->npinfo);
 }
 
 static inline void br_netpoll_send_skb(const struct net_bridge_port *p,
