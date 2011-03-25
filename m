From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH] route: Take the right src and dst addresses in
 ip_route_newports
Date: Fri, 25 Mar 2011 07:42:03 +0100
Message-ID: <20110325064203.GF1290@secunet.com>
References: <20110325064116.GE1290@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:45947 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754203Ab1CYGmF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Mar 2011 02:42:05 -0400
Content-Disposition: inline
In-Reply-To: <20110325064116.GE1290@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we set up the flow informations in ip_route_newports(),  we take the
address informations from the the rt_key_src and rt_key_dst fields of the
rtable. They appear to be empty. So take the address informations from
rt_src and rt_dst instead. This issue was introduced by
commit 5e2b61f78411be25f0b84f97d5b5d312f184dfd1

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/route.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index dc10244..f88429c 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -270,8 +270,8 @@ static inline struct rtable *ip_route_newports(struct rtable *rt,
 		struct flowi4 fl4 = {
 			.flowi4_oif = rt->rt_oif,
 			.flowi4_mark = rt->rt_mark,
-			.daddr = rt->rt_key_dst,
-			.saddr = rt->rt_key_src,
+			.daddr = rt->rt_dst,
+			.saddr = rt->rt_src,
 			.flowi4_tos = rt->rt_tos,
 			.flowi4_proto = protocol,
 			.fl4_sport = sport,
-- 
1.7.0.4

