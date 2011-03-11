From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2] ipv4: Remove unnecessary test from ip_mkroute_input()
Date: Thu, 10 Mar 2011 17:05:25 -0800 (PST)
Message-ID: <20110310.170525.102566864.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48119
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754408Ab1CKBEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 20:04:48 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 33EE624C08B
	for <netdev@vger.kernel.org>; Thu, 10 Mar 2011 17:05:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


fl->oif will always be zero on the input path, so there is no reason
to test for that.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f6730d9..a7ac90c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2047,7 +2047,7 @@ static int ip_mkroute_input(struct sk_buff *skb,
 	unsigned hash;
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-	if (res->fi && res->fi->fib_nhs > 1 && fl->oif == 0)
+	if (res->fi && res->fi->fib_nhs > 1)
 		fib_select_multipath(fl, res);
 #endif
 
-- 
1.7.4.1

