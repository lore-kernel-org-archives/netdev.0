From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next] rtnetlink: remove slave_validate callback
Date: Wed,  4 Oct 2017 15:55:29 +0200
Message-ID: <20171004135529.3967-1-fw@strlen.de>
Cc: jiri@resnulli.us, Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:53244 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752105AbdJDNzM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 09:55:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

no users in the tree.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/rtnetlink.h | 3 ---
 net/core/rtnetlink.c    | 6 ------
 2 files changed, 9 deletions(-)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 21837ca68ecc..6520993ff449 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -93,9 +93,6 @@ struct rtnl_link_ops {
 
 	int			slave_maxtype;
 	const struct nla_policy	*slave_policy;
-	int			(*slave_validate)(struct nlattr *tb[],
-						  struct nlattr *data[],
-						  struct netlink_ext_ack *extack);
 	int			(*slave_changelink)(struct net_device *dev,
 						    struct net_device *slave_dev,
 						    struct nlattr *tb[],
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 3961f87cdc76..b63c5759641f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2631,12 +2631,6 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 					return err;
 				slave_data = slave_attr;
 			}
-			if (m_ops->slave_validate) {
-				err = m_ops->slave_validate(tb, slave_data,
-							    extack);
-				if (err < 0)
-					return err;
-			}
 		}
 
 		if (dev) {
-- 
2.13.6
