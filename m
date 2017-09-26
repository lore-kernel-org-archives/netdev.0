From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] ipv6: Remove redundant unlikely()
Date: Tue, 26 Sep 2017 11:22:31 +0200
Message-ID: <20170926092231.21289-1-tklauser@distanz.ch>
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:46302 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966927AbdIZJWg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 05:22:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IS_ERR() already implies unlikely(), so it can be omitted.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 net/ipv6/addrconf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 96861c702c06..13c3b697f8c0 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3297,7 +3297,7 @@ static int fixup_permanent_addr(struct inet6_dev *idev,
 		struct rt6_info *rt, *prev;
 
 		rt = addrconf_dst_alloc(idev, &ifp->addr, false);
-		if (unlikely(IS_ERR(rt)))
+		if (IS_ERR(rt))
 			return PTR_ERR(rt);
 
 		/* ifp->rt can be accessed outside of rtnl */
-- 
2.13.0
