From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next v4 4/4] rtnetlink: rtnl_have_link_slave_info doesn't need rtnl
Date: Tue, 26 Sep 2017 13:58:43 +0200
Message-ID: <20170926115843.12013-5-fw@strlen.de>
References: <20170926115843.12013-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:58794 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S964827AbdIZL6j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 07:58:39 -0400
In-Reply-To: <20170926115843.12013-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

it can be switched to rcu.

Reviewed-by: David Ahern <dsahern@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 No changes in v4.

 net/core/rtnetlink.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d524609c587c..e6955da0d58d 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -522,11 +522,15 @@ static size_t rtnl_link_get_af_size(const struct net_device *dev,
 static bool rtnl_have_link_slave_info(const struct net_device *dev)
 {
 	struct net_device *master_dev;
+	bool ret = false;
 
-	master_dev = netdev_master_upper_dev_get((struct net_device *) dev);
+	rcu_read_lock();
+
+	master_dev = netdev_master_upper_dev_get_rcu((struct net_device *)dev);
 	if (master_dev && master_dev->rtnl_link_ops)
-		return true;
-	return false;
+		ret = true;
+	rcu_read_unlock();
+	return ret;
 }
 
 static int rtnl_link_slave_info_fill(struct sk_buff *skb,
-- 
2.13.5
