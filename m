From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH net] ipv6: stop sending PTB packets for MTU < 1280
Date: Thu, 15 Jan 2015 22:34:25 +0100
Message-ID: <1421357665-2804-1-git-send-email-hagen@jauu.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hagen Paul Pfeifer <hagen@jauu.net>, stable@vger.kernel.org,
	Fernando Gont <fgont@si6networks.com>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reduce the attack vector and stop generating IPv6 Fragment Header for
paths with an MTU smaller than the minimum required IPv6 MTU
size (1280 byte) - called atomic fragments.

See IETF I-D "Deprecating the Generation of IPv6 Atomic Fragments" [1]
for more information and how this "feature" can be misused.

[1] https://tools.ietf.org/html/draft-ietf-6man-deprecate-atomfrag-generation-00

Cc: stable@vger.kernel.org
Signed-off-by: Fernando Gont <fgont@si6networks.com>
Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 net/ipv6/route.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 34dcbb5..d4603fb 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1160,12 +1160,9 @@ static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
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
2.1.4
