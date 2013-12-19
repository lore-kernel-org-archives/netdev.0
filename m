From: Tan Xiaojun <tanxiaojun@huawei.com>
Subject: [PATCH 1/5] bridge: remove unnecessary condition judgment
Date: Thu, 19 Dec 2013 13:28:10 +0800
Message-ID: <1387430894-11220-2-git-send-email-tanxiaojun@huawei.com>
References: <1387430894-11220-1-git-send-email-tanxiaojun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bridge@lists.linux-foundation.org>, <netdev@vger.kernel.org>
To: <stephen@networkplumber.org>, <davem@davemloft.net>,
	<bart.de.schuymer@pandora.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:44505 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843Ab3LSF2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 00:28:47 -0500
In-Reply-To: <1387430894-11220-1-git-send-email-tanxiaojun@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because err is always negative, remove unnecessary condition
judgment.

Signed-off-by: Tan Xiaojun <tanxiaojun@huawei.com>
---
 net/bridge/br_fdb.c     | 3 +--
 net/bridge/br_netlink.c | 3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 33e8f23..c5f5a4a 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -570,8 +570,7 @@ static void fdb_notify(struct net_bridge *br,
 	rtnl_notify(skb, net, 0, RTNLGRP_NEIGH, NULL, GFP_ATOMIC);
 	return;
 errout:
-	if (err < 0)
-		rtnl_set_sk_err(net, RTNLGRP_NEIGH, err);
+	rtnl_set_sk_err(net, RTNLGRP_NEIGH, err);
 }
 
 /* Dump information about entries, in response to GETNEIGH */
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index c2fd6bc..6526ac8 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -195,8 +195,7 @@ void br_ifinfo_notify(int event, struct net_bridge_port *port)
 	rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, GFP_ATOMIC);
 	return;
 errout:
-	if (err < 0)
-		rtnl_set_sk_err(net, RTNLGRP_LINK, err);
+	rtnl_set_sk_err(net, RTNLGRP_LINK, err);
 }
 
 
-- 
1.8.0
