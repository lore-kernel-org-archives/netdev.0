From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/3] xfrm: Remove family arg from xfrm_bundle_ok
Date: Thu, 30 Jun 2011 11:18:20 +0200
Message-ID: <20110630091820.GB13201@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51289 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751299Ab1F3JRn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2011 05:17:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The family arg is not used any more, so remove it.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 9bec2e8..5ce74a3 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -50,7 +50,7 @@ static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short family);
 static void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo);
 static void xfrm_init_pmtu(struct dst_entry *dst);
 static int stale_bundle(struct dst_entry *dst);
-static int xfrm_bundle_ok(struct xfrm_dst *xdst, int family);
+static int xfrm_bundle_ok(struct xfrm_dst *xdst);
 
 
 static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
@@ -2241,7 +2241,7 @@ static struct dst_entry *xfrm_dst_check(struct dst_entry *dst, u32 cookie)
 
 static int stale_bundle(struct dst_entry *dst)
 {
-	return !xfrm_bundle_ok((struct xfrm_dst *)dst, AF_UNSPEC);
+	return !xfrm_bundle_ok((struct xfrm_dst *)dst);
 }
 
 void xfrm_dst_ifdown(struct dst_entry *dst, struct net_device *dev)
@@ -2313,7 +2313,7 @@ static void xfrm_init_pmtu(struct dst_entry *dst)
  * still valid.
  */
 
-static int xfrm_bundle_ok(struct xfrm_dst *first, int family)
+static int xfrm_bundle_ok(struct xfrm_dst *first)
 {
 	struct dst_entry *dst = &first->u.dst;
 	struct xfrm_dst *last;
-- 
1.7.0.4

