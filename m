From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH v2 4/4] neigh: don't leak default parms to uninitial netns
Date: Fri, 14 Jun 2013 10:06:47 +0800
Message-ID: <1371175607-1405-4-git-send-email-gaofeng@cn.fujitsu.com>
References: <1371175607-1405-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55822 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750970Ab3FNCFO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jun 2013 22:05:14 -0400
In-Reply-To: <1371175607-1405-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only allow initial net namespace to get default parms
through netlink.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/core/neighbour.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 5e0fe89..3bb6115 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2094,7 +2094,8 @@ static int neightbl_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 		if (tidx < tbl_skip || (family && tbl->family != family))
 			continue;
 
-		if (neightbl_fill_info(skb, tbl, NETLINK_CB(cb->skb).portid,
+		if (net_eq(net, &init_net) &&
+		    neightbl_fill_info(skb, tbl, NETLINK_CB(cb->skb).portid,
 				       cb->nlh->nlmsg_seq, RTM_NEWNEIGHTBL,
 				       NLM_F_MULTI) <= 0)
 			break;
-- 
1.8.1.4
