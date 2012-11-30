From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next] rtnelink: remove unused parameter from rtnl_create_link().
Date: Fri, 30 Nov 2012 13:08:47 +0200
Message-ID: <1354273727-6336-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, jiri@resnulli.us,
	Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:48799 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757785Ab2K3LJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 06:09:39 -0500
Received: by mail-we0-f174.google.com with SMTP id x10so102936wey.19
        for <netdev@vger.kernel.org>; Fri, 30 Nov 2012 03:09:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes an unused parameter (src_net) from rtnl_create_link() 
method and from the method single invocation, in veth. 
This parameter was used in the past when calling 
ops->get_tx_queues(src_net, tb) in rtnl_create_link().  
The get_tx_queues() member of rtnl_link_ops was replaced by two methods, 
get_num_tx_queues() and get_num_rx_queues(), which do not get any 
parameter. This was done in commit d40156aa5ecbd51fed932ed4813df82b56e5ff4d by 
Jiri Pirko ("rtnl: allow to specify different num for rx and tx queue count").

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 drivers/net/veth.c      | 2 +-
 include/net/rtnetlink.h | 2 +-
 net/core/rtnetlink.c    | 4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 24f6b27..95814d9 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -340,7 +340,7 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 	if (IS_ERR(net))
 		return PTR_ERR(net);
 
-	peer = rtnl_create_link(src_net, net, ifname, &veth_link_ops, tbp);
+	peer = rtnl_create_link(net, ifname, &veth_link_ops, tbp);
 	if (IS_ERR(peer)) {
 		put_net(net);
 		return PTR_ERR(peer);
diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 6b00c4f..5a15fab 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -125,7 +125,7 @@ extern void	rtnl_af_unregister(struct rtnl_af_ops *ops);
 
 
 extern struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[]);
-extern struct net_device *rtnl_create_link(struct net *src_net, struct net *net,
+extern struct net_device *rtnl_create_link(struct net *net,
 	char *ifname, const struct rtnl_link_ops *ops, struct nlattr *tb[]);
 extern int rtnl_configure_link(struct net_device *dev,
 			       const struct ifinfomsg *ifm);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 575a6ee..1868625 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1642,7 +1642,7 @@ int rtnl_configure_link(struct net_device *dev, const struct ifinfomsg *ifm)
 }
 EXPORT_SYMBOL(rtnl_configure_link);
 
-struct net_device *rtnl_create_link(struct net *src_net, struct net *net,
+struct net_device *rtnl_create_link(struct net *net,
 	char *ifname, const struct rtnl_link_ops *ops, struct nlattr *tb[])
 {
 	int err;
@@ -1840,7 +1840,7 @@ replay:
 		if (IS_ERR(dest_net))
 			return PTR_ERR(dest_net);
 
-		dev = rtnl_create_link(net, dest_net, ifname, ops, tb);
+		dev = rtnl_create_link(dest_net, ifname, ops, tb);
 		if (IS_ERR(dev)) {
 			err = PTR_ERR(dev);
 			goto out;
-- 
1.7.11.7
