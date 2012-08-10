From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 08/14] bridge: use list_for_each_entry() in netpoll functions
Date: Fri, 10 Aug 2012 15:10:31 +0800
Message-ID: <1344582637-18261-9-git-send-email-amwang@redhat.com>
References: <1344582637-18261-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>, David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9644 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756134Ab2HJHLO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2012 03:11:14 -0400
In-Reply-To: <1344582637-18261-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't delete 'p' from the list in the loop,
so we can just use list_for_each_entry().

Cc: David Miller <davem@davemloft.net>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/bridge/br_device.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index f41ba40..32211fa 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -206,21 +206,20 @@ static void br_poll_controller(struct net_device *br_dev)
 static void br_netpoll_cleanup(struct net_device *dev)
 {
 	struct net_bridge *br = netdev_priv(dev);
-	struct net_bridge_port *p, *n;
+	struct net_bridge_port *p;
 
-	list_for_each_entry_safe(p, n, &br->port_list, list) {
+	list_for_each_entry(p, &br->port_list, list)
 		br_netpoll_disable(p);
-	}
 }
 
 static int br_netpoll_setup(struct net_device *dev, struct netpoll_info *ni,
 			    gfp_t gfp)
 {
 	struct net_bridge *br = netdev_priv(dev);
-	struct net_bridge_port *p, *n;
+	struct net_bridge_port *p;
 	int err = 0;
 
-	list_for_each_entry_safe(p, n, &br->port_list, list) {
+	list_for_each_entry(p, &br->port_list, list) {
 		if (!p->dev)
 			continue;
 		err = br_netpoll_enable(p, gfp);
-- 
1.7.7.6
