From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] bridge: remove dev_put() in add_del_if()
Date: Wed, 04 Nov 2009 20:09:07 +0100
Message-ID: <4AF1D153.5040309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59795 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755714AbZKDTJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 14:09:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add_del_if() is called with RTNL, we can use __dev_get_by_index()
instead of [dev_get_by_index() + dev_put()]

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/bridge/br_ioctl.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
index 6a6433d..2af6e4a 100644
--- a/net/bridge/br_ioctl.c
+++ b/net/bridge/br_ioctl.c
@@ -81,6 +81,7 @@ static int get_fdb_entries(struct net_bridge *br, void __user *userbuf,
 	return num;
 }
 
+/* called with RTNL */
 static int add_del_if(struct net_bridge *br, int ifindex, int isadd)
 {
 	struct net_device *dev;
@@ -89,7 +90,7 @@ static int add_del_if(struct net_bridge *br, int ifindex, int isadd)
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	dev = dev_get_by_index(dev_net(br->dev), ifindex);
+	dev = __dev_get_by_index(dev_net(br->dev), ifindex);
 	if (dev == NULL)
 		return -EINVAL;
 
@@ -98,7 +99,6 @@ static int add_del_if(struct net_bridge *br, int ifindex, int isadd)
 	else
 		ret = br_del_if(br, dev);
 
-	dev_put(dev);
 	return ret;
 }
 
