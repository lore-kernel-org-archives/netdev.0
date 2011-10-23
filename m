From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: [PATCH] ipv4: fix ipsec forward performance regression
Date: Sun, 23 Oct 2011 15:58:20 +0800
Message-ID: <4EA3C91C.3090801@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Kim Phillips <kim.phillips@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:19774 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754715Ab1JWH6W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Oct 2011 03:58:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is bug in commit 5e2b61f(ipv4: Remove flowi from struct rtable).
It makes xfrm4_fill_dst() modify wrong data structure.

Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
---
 net/ipv4/xfrm4_policy.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index fc5368a..a0b4c5d 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -79,13 +79,13 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 	struct rtable *rt = (struct rtable *)xdst->route;
 	const struct flowi4 *fl4 = &fl->u.ip4;
 
-	rt->rt_key_dst = fl4->daddr;
-	rt->rt_key_src = fl4->saddr;
-	rt->rt_key_tos = fl4->flowi4_tos;
-	rt->rt_route_iif = fl4->flowi4_iif;
-	rt->rt_iif = fl4->flowi4_iif;
-	rt->rt_oif = fl4->flowi4_oif;
-	rt->rt_mark = fl4->flowi4_mark;
+	xdst->u.rt.rt_key_dst = fl4->daddr;
+	xdst->u.rt.rt_key_src = fl4->saddr;
+	xdst->u.rt.rt_key_tos = fl4->flowi4_tos;
+	xdst->u.rt.rt_route_iif = fl4->flowi4_iif;
+	xdst->u.rt.rt_iif = fl4->flowi4_iif;
+	xdst->u.rt.rt_oif = fl4->flowi4_oif;
+	xdst->u.rt.rt_mark = fl4->flowi4_mark;
 
 	xdst->u.dst.dev = dev;
 	dev_hold(dev);
-- 
1.7.4.4
