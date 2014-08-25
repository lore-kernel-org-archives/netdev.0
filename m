From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [RFC PATCH net-next] ipv6: stop sending PTB packets for MTU < 1280
Date: Tue, 26 Aug 2014 00:25:45 +0200
Message-ID: <1409005545-24910-2-git-send-email-hagen@jauu.net>
References: <53F39E50.1020209@gont.com.ar>
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	Fernando Gont <fgont@si6networks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:42525 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751780AbaHYW0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 18:26:50 -0400
Received: by mail-wi0-f174.google.com with SMTP id d1so3272523wiv.13
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 15:26:49 -0700 (PDT)
In-Reply-To: <53F39E50.1020209@gont.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce the attack vector and stop generating ICMPv6 packet to big for
packets smaller then the minimal required IPv6 MTU.

See
http://tools.ietf.org/html/draft-gont-6man-deprecate-atomfrag-generation-00

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 net/ipv6/route.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f74b041..84ebacd 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1154,12 +1154,9 @@ static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 		struct net *net = dev_net(dst->dev);
 
 		rt6->rt6i_flags |= RTF_MODIFIED;
-		if (mtu < IPV6_MIN_MTU) {
-			u32 features = dst_metric(dst, RTAX_FEATURES);
+		if (mtu < IPV6_MIN_MTU)
 			mtu = IPV6_MIN_MTU;
-			features |= RTAX_FEATURE_ALLFRAG;
-			dst_metric_set(dst, RTAX_FEATURES, features);
-		}
+
 		dst_metric_set(dst, RTAX_MTU, mtu);
 		rt6_update_expires(rt6, net->ipv6.sysctl.ip6_rt_mtu_expires);
 	}
-- 
2.1.0
