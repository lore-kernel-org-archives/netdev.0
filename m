From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net-next] ipv6: Initialize the neighbour pointer of
 rt6_info on allocation
Date: Thu, 5 Jul 2012 15:18:28 +0200
Message-ID: <20120705131828.GE1869@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:58086 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932869Ab2GENSl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2012 09:18:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

git commit 97cac082 (ipv6: Store route neighbour in rt6_info struct)
added a neighbour pointer to rt6_info. Currently we don't initialize
this pointer at allocation time. We assume this pointer to be valid
if it is not a null pointer, so initialize it on allocation.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/route.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ceff71d..6cc6c88 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -273,7 +273,7 @@ static inline struct rt6_info *ip6_dst_alloc(struct net *net,
 					0, 0, flags);
 
 	if (rt) {
-		memset(&rt->rt6i_table, 0,
+		memset(&rt->n, 0,
 		       sizeof(*rt) - sizeof(struct dst_entry));
 		rt6_init_peer(rt, table ? &table->tb6_peers : net->ipv6.peers);
 	}
-- 
1.7.0.4
