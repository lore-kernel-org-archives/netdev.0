From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 8/9] ipv6: drop unused variables in seg6_genl_dumphac
Date: Fri, 19 May 2017 09:55:55 -0700
Message-ID: <20170519165556.483-9-sthemmin@microsoft.com>
References: <20170519165556.483-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:36294 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755022AbdESQ4N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 12:56:13 -0400
Received: by mail-pg0-f52.google.com with SMTP id x64so40682813pgd.3
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 09:56:13 -0700 (PDT)
In-Reply-To: <20170519165556.483-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

THe seg6_pernet_data variable was set but never used.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/ipv6/seg6.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/ipv6/seg6.c b/net/ipv6/seg6.c
index 5f44ffed2576..15fba55e3da8 100644
--- a/net/ipv6/seg6.c
+++ b/net/ipv6/seg6.c
@@ -303,13 +303,9 @@ static int seg6_genl_dumphmac_done(struct netlink_callback *cb)
 static int seg6_genl_dumphmac(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct rhashtable_iter *iter = (struct rhashtable_iter *)cb->args[0];
-	struct net *net = sock_net(skb->sk);
-	struct seg6_pernet_data *sdata;
 	struct seg6_hmac_info *hinfo;
 	int ret;
 
-	sdata = seg6_pernet(net);
-
 	ret = rhashtable_walk_start(iter);
 	if (ret && ret != -EAGAIN)
 		goto done;
-- 
2.11.0
