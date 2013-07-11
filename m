From: Fan Du <fan.du@windriver.com>
Subject: [RFC PATCH net-next] net ipv6: Remove rebundant rt6i_nsiblings initialization
Date: Thu, 11 Jul 2013 08:27:22 +0800
Message-ID: <1373502442-32403-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yoshfuji@linux-ipv6.org>, <jmorris@namei.org>,
	<kuznet@ms2.inr.ac.ru>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:60814 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754365Ab3GKA2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 20:28:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Seting rt->rt6i_nsiblings to zero is rebundant, because above memset
has zeroed the rest of rt excluding the first dst memember.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/ipv6/route.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 7ca87b3..b88f99f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -278,7 +278,6 @@ static inline struct rt6_info *ip6_dst_alloc(struct net *net,
 		rt6_init_peer(rt, table ? &table->tb6_peers : net->ipv6.peers);
 		rt->rt6i_genid = rt_genid(net);
 		INIT_LIST_HEAD(&rt->rt6i_siblings);
-		rt->rt6i_nsiblings = 0;
 	}
 	return rt;
 }
-- 
1.7.1
