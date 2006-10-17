From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH 8/13] [RFC] [IPV6] Get rid of ipv6_get_saddr() in xfrm6_get_saddr().
Date: Tue, 17 Oct 2006 03:16:23 +0300
Message-ID: <453420D7.3050604@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Thomas Graf <tgraf@suug.ch>, kim.nordlund@nokia.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:4882 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1422969AbWJQAQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 20:16:25 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


As the source address is already selected in ip6_pol_route_output()
there is no need to do the source address lookup a second time.

Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
---
 net/ipv6/xfrm6_policy.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index db2d55c..954c9ac 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -48,8 +48,7 @@ static int xfrm6_get_saddr(xfrm_address_
 	};

 	if (!xfrm6_dst_lookup((struct xfrm_dst **)&rt, &fl_tunnel)) {
-		ipv6_get_saddr(&rt->u.dst, (struct in6_addr *)&daddr->a6,
-			       (struct in6_addr *)&saddr->a6);
+		ipv6_addr_copy((struct in6_addr *)saddr, &fl_tunnel.fl6_src);
 		dst_release(&rt->u.dst);
 		return 0;
 	}
-- 
1.4.2.3

