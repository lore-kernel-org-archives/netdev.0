From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 2/4] rtnl: use the new API to align IFLA_STATS*
Date: Thu, 21 Apr 2016 18:58:25 +0200
Message-ID: <1461257907-4458-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1461142655-5067-1-git-send-email-nicolas.dichtel@6wind.com>
 <1461257907-4458-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, roopa@cumulusnetworks.com,
	eric.dumazet@gmail.com, tgraf@suug.ch, jhs@mojatatu.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:52641 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753423AbcDUQ66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 12:58:58 -0400
In-Reply-To: <1461257907-4458-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/rtnetlink.c | 22 +++++-----------------
 1 file changed, 5 insertions(+), 17 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 4a47a9aceb1d..5ec059d52823 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1051,14 +1051,9 @@ static noinline_for_stack int rtnl_fill_stats(struct sk_buff *skb,
 {
 	struct rtnl_link_stats64 *sp;
 	struct nlattr *attr;
-	int err;
-
-	err = nla_align_64bit(skb, IFLA_PAD);
-	if (err)
-		return err;
 
-	attr = nla_reserve(skb, IFLA_STATS64,
-			   sizeof(struct rtnl_link_stats64));
+	attr = nla_reserve_64bit(skb, IFLA_STATS64,
+				 sizeof(struct rtnl_link_stats64), IFLA_PAD);
 	if (!attr)
 		return -EMSGSIZE;
 
@@ -3469,17 +3464,10 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
 
 	if (filter_mask & IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK_64)) {
 		struct rtnl_link_stats64 *sp;
-		int err;
-
-		/* if necessary, add a zero length NOP attribute so that
-		 * IFLA_STATS_LINK_64 will be 64-bit aligned
-		 */
-		err = nla_align_64bit(skb, IFLA_STATS_UNSPEC);
-		if (err)
-			goto nla_put_failure;
 
-		attr = nla_reserve(skb, IFLA_STATS_LINK_64,
-				   sizeof(struct rtnl_link_stats64));
+		attr = nla_reserve_64bit(skb, IFLA_STATS_LINK_64,
+					 sizeof(struct rtnl_link_stats64),
+					 IFLA_STATS_UNSPEC);
 		if (!attr)
 			goto nla_put_failure;
 
-- 
2.4.2
