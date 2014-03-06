From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] inet: remove now unused flag DST_NOPEER
Date: Thu, 6 Mar 2014 09:11:07 +0100
Message-ID: <20140306081107.GD26307@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44711 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142AbaCFILJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 03:11:09 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e688a604807647 ("net: introduce DST_NOPEER dst flag") introduced
DST_NOPEER because because of crashes in ipv6_select_ident called from
udp6_ufo_fragment.

Since commit 916e4cf46d0204 ("ipv6: reuse ip6_frag_id from
ip6_ufo_append_data") we don't call ipv6_select_ident any more from
ip6_ufo_append_data, thus this flag lost its purpose and can be removed.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/dst.h         | 7 +++----
 net/bridge/br_netfilter.c | 2 +-
 net/ipv6/output_core.c    | 2 +-
 3 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 77eb53f..e01a826 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -54,10 +54,9 @@ struct dst_entry {
 #define DST_NOHASH		0x0008
 #define DST_NOCACHE		0x0010
 #define DST_NOCOUNT		0x0020
-#define DST_NOPEER		0x0040
-#define DST_FAKE_RTABLE		0x0080
-#define DST_XFRM_TUNNEL		0x0100
-#define DST_XFRM_QUEUE		0x0200
+#define DST_FAKE_RTABLE		0x0040
+#define DST_XFRM_TUNNEL		0x0080
+#define DST_XFRM_QUEUE		0x0100
 
 	unsigned short		pending_confirm;
 
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index df0f114..80e1b0f 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -167,7 +167,7 @@ void br_netfilter_rtable_init(struct net_bridge *br)
 	rt->dst.dev = br->dev;
 	rt->dst.path = &rt->dst;
 	dst_init_metrics(&rt->dst, br_dst_default_metrics, true);
-	rt->dst.flags	= DST_NOXFRM | DST_NOPEER | DST_FAKE_RTABLE;
+	rt->dst.flags	= DST_NOXFRM | DST_FAKE_RTABLE;
 	rt->dst.ops = &fake_dst_ops;
 }
 
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 827f795..d1b35d3 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -13,7 +13,7 @@ void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
 	int old, new;
 
 #if IS_ENABLED(CONFIG_IPV6)
-	if (rt && !(rt->dst.flags & DST_NOPEER)) {
+	if (rt) {
 		struct inet_peer *peer;
 		struct net *net;
 
-- 
1.8.5.3
