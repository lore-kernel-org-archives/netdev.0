From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 3/4] appletalk: convert printks to pr_<level>
Date: Fri, 14 Feb 2014 15:43:45 +0800
Message-ID: <1392363826-8256-4-git-send-email-wangweidong1@huawei.com>
References: <1392363826-8256-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <acme@ghostprotocols.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:18559 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742AbaBNHoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 02:44:10 -0500
In-Reply-To: <1392363826-8256-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prefer pr_<level> then printk(LEVEL).

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/appletalk/aarp.c |  2 +-
 net/appletalk/ddp.c  | 13 ++++++-------
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/appletalk/aarp.c b/net/appletalk/aarp.c
index d1c55d8..9ec36ed 100644
--- a/net/appletalk/aarp.c
+++ b/net/appletalk/aarp.c
@@ -883,7 +883,7 @@ void __init aarp_proto_init(void)
 {
 	aarp_dl = register_snap_client(aarp_snap_id, aarp_rcv);
 	if (!aarp_dl)
-		printk(KERN_CRIT "Unable to register AARP with SNAP.\n");
+		pr_crit("Unable to register AARP with SNAP.\n");
 	setup_timer(&aarp_timer, aarp_expire_timeout, 0);
 	aarp_timer.expires  = jiffies + sysctl_aarp_expiry_time;
 	add_timer(&aarp_timer);
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 06e0d19..9189d3c 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -704,9 +704,9 @@ static int atif_ioctl(int cmd, void __user *arg)
 		if ((dev->flags & IFF_POINTOPOINT) &&
 		    atalk_find_interface(sa->sat_addr.s_net,
 					 sa->sat_addr.s_node)) {
-			printk(KERN_DEBUG "AppleTalk: point-to-point "
-			       "interface added with "
-			       "existing address\n");
+			pr_debug("AppleTalk: point-to-point "
+				 "interface added with "
+				 "existing address\n");
 			add_route = 0;
 		}
 
@@ -768,8 +768,7 @@ static int atif_ioctl(int cmd, void __user *arg)
 		} else {
 			limit = ntohs(nr->nr_lastnet);
 			if (limit - ntohs(nr->nr_firstnet) > 4096) {
-				printk(KERN_WARNING "Too many routes/"
-				       "iface.\n");
+				pr_warn("Too many routes/iface.\n");
 				return -EINVAL;
 			}
 			if (add_route)
@@ -1329,8 +1328,8 @@ static int atalk_route_packet(struct sk_buff *skb, struct net_device *dev,
 		 * needs to be broadcast onto the default network?
 		 */
 		if (dev->type == ARPHRD_PPP)
-			printk(KERN_DEBUG "AppleTalk: didn't forward broadcast "
-					  "packet received from PPP iface\n");
+			pr_debug("AppleTalk: didn't forward broadcast "
+				 "packet received from PPP iface\n");
 		goto free_it;
 	}
 
-- 
1.7.12
