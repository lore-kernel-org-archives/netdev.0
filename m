From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [PATCH 2/2] net: check return value for dst_alloc
Date: Mon, 26 Sep 2011 20:04:56 +0300
Message-ID: <1317056696-23611-1-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<timo.teras@iki.fi>, Madalin Bucur <madalin.bucur@freescale.com>
To: <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe005.messaging.microsoft.com ([213.199.154.143]:20971
	"EHLO DB3EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751506Ab1IZREn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 13:04:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

return value of dst_alloc must be checked before use

Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
---
 net/ipv6/route.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 1250f90..fb545ed 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -244,7 +244,9 @@ static inline struct rt6_info *ip6_dst_alloc(struct dst_ops *ops,
 {
 	struct rt6_info *rt = dst_alloc(ops, dev, 0, 0, flags);
 
-	memset(&rt->rt6i_table, 0, sizeof(*rt) - sizeof(struct dst_entry));
+	if (rt != NULL)
+		memset(&rt->rt6i_table, 0,
+			sizeof(*rt) - sizeof(struct dst_entry));
 
 	return rt;
 }
-- 
1.7.0.1
