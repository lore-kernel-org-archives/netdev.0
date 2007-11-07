From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 7/24] [IPSEC]: Set dst->input to dst_discard
Date: Wed, 07 Nov 2007 22:08:23 +0800
Message-ID: <E1IplZv-0001Go-00@gondolin.me.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3785 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758139AbXKGO0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:26:54 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Set dst->input to dst_discard

The input function should never be invoked on IPsec dst objects.  This is
because we don't apply IPsec on input until after we've made the routing
decision.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/xfrm4_policy.c |    3 ++-
 net/ipv6/xfrm6_policy.c |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 7d250a1..c40a71b 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -10,6 +10,7 @@
 
 #include <linux/compiler.h>
 #include <linux/inetdevice.h>
+#include <net/dst.h>
 #include <net/xfrm.h>
 #include <net/ip.h>
 
@@ -167,7 +168,7 @@ __xfrm4_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 		dst_prev->trailer_len	= trailer_len;
 		memcpy(&dst_prev->metrics, &x->route->metrics, sizeof(dst_prev->metrics));
 
-		dst_prev->input		= rt->u.dst.input;
+		dst_prev->input = dst_discard;
 		dst_prev->output = dst_prev->xfrm->outer_mode->afinfo->output;
 		if (rt0->peer)
 			atomic_inc(&rt0->peer->refcnt);
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 15747f3..a1c6b7c 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -14,6 +14,7 @@
 #include <linux/compiler.h>
 #include <linux/netdevice.h>
 #include <net/addrconf.h>
+#include <net/dst.h>
 #include <net/xfrm.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
@@ -214,7 +215,7 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 		dst_prev->trailer_len	= trailer_len;
 		memcpy(&dst_prev->metrics, &x->route->metrics, sizeof(dst_prev->metrics));
 
-		dst_prev->input		= rt->u.dst.input;
+		dst_prev->input = dst_discard;
 		dst_prev->output = dst_prev->xfrm->outer_mode->afinfo->output;
 		/* Sheit... I remember I did this right. Apparently,
 		 * it was magically lost, so this code needs audit */
