From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH 6/13] [IPV6] Always copy rt->u.dst.error when copying a rt6_info.
Date: Tue, 17 Oct 2006 03:10:49 +0300
Message-ID: <45341F89.2040908@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Thomas Graf <tgraf@suug.ch>, kim.nordlund@nokia.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:64273 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1422970AbWJQAKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 20:10:51 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
---
 net/ipv6/route.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 263c057..aa96be8 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -618,8 +618,6 @@ static struct rt6_info *rt6_alloc_clone(
 		ipv6_addr_copy(&rt->rt6i_dst.addr, daddr);
 		rt->rt6i_dst.plen = 128;
 		rt->rt6i_flags |= RTF_CACHE;
-		if (rt->rt6i_flags & RTF_REJECT)
-			rt->u.dst.error = ort->u.dst.error;
 		rt->u.dst.flags |= DST_HOST;
 		rt->rt6i_nexthop = neigh_clone(ort->rt6i_nexthop);
 	}
@@ -1540,6 +1538,7 @@ static struct rt6_info * ip6_rt_copy(str
 		rt->u.dst.output = ort->u.dst.output;

 		memcpy(rt->u.dst.metrics, ort->u.dst.metrics, RTAX_MAX*sizeof(u32));
+		rt->u.dst.error = ort->u.dst.error;
 		rt->u.dst.dev = ort->u.dst.dev;
 		if (rt->u.dst.dev)
 			dev_hold(rt->u.dst.dev);
-- 
1.4.2.3
