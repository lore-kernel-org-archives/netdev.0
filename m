From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 3/4] netns: Initialize fl_net in structures allocated with
	dst_alloc
Date: Tue, 4 Dec 2007 12:55:03 +0300
Message-ID: <20071204095503.GA6059@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@openvz.org, netdev@vger.kernel.org, containers@lists.osdl.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:56277 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751804AbXLDJyA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 04:54:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

net: Initialize fl_net in structures allocated with dst_alloc

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/decnet/dn_route.c |    2 ++
 net/ipv4/route.c      |    4 ++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index c353de0..1b5b9ce 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1093,6 +1093,7 @@ make_route:
 	atomic_set(&rt->u.dst.__refcnt, 1);
 	rt->u.dst.flags   = DST_HOST;
 
+	rt->fl.fl_net     = &init_net;
 	rt->fl.fld_src    = oldflp->fld_src;
 	rt->fl.fld_dst    = oldflp->fld_dst;
 	rt->fl.oif        = oldflp->oif;
@@ -1363,6 +1364,7 @@ make_route:
 	rt->rt_dst_map    = fl.fld_dst;
 	rt->rt_src_map    = fl.fld_src;
 
+	rt->fl.fl_net     = &init_net;
 	rt->fl.fld_src    = cb->src;
 	rt->fl.fld_dst    = cb->dst;
 	rt->fl.oif        = 0;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index dae1290..84a7f32 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1567,6 +1567,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->u.dst.flags= DST_HOST;
 	if (IN_DEV_CONF_GET(in_dev, NOPOLICY))
 		rth->u.dst.flags |= DST_NOPOLICY;
+	rth->fl.fl_net	= &init_net;
 	rth->fl.fl4_dst	= daddr;
 	rth->rt_dst	= daddr;
 	rth->fl.fl4_tos	= tos;
@@ -1707,6 +1708,7 @@ static inline int __mkroute_input(struct sk_buff *skb,
 		rth->u.dst.flags |= DST_NOPOLICY;
 	if (IN_DEV_CONF_GET(out_dev, NOXFRM))
 		rth->u.dst.flags |= DST_NOXFRM;
+	rth->fl.fl_net	= &init_net;
 	rth->fl.fl4_dst	= daddr;
 	rth->rt_dst	= daddr;
 	rth->fl.fl4_tos	= tos;
@@ -1887,6 +1889,7 @@ local_input:
 	rth->u.dst.flags= DST_HOST;
 	if (IN_DEV_CONF_GET(in_dev, NOPOLICY))
 		rth->u.dst.flags |= DST_NOPOLICY;
+	rth->fl.fl_net	= &init_net;
 	rth->fl.fl4_dst	= daddr;
 	rth->rt_dst	= daddr;
 	rth->fl.fl4_tos	= tos;
@@ -2078,6 +2081,7 @@ static inline int __mkroute_output(struct rtable **result,
 	if (IN_DEV_CONF_GET(in_dev, NOPOLICY))
 		rth->u.dst.flags |= DST_NOPOLICY;
 
+	rth->fl.fl_net	= &init_net;
 	rth->fl.fl4_dst	= oldflp->fl4_dst;
 	rth->fl.fl4_tos	= tos;
 	rth->fl.fl4_src	= oldflp->fl4_src;
-- 
1.5.3.rc5

