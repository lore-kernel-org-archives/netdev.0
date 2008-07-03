From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH] xfrm: Fix possible error pointer dereference
Date: Thu, 3 Jul 2008 10:48:36 +0200
Message-ID: <20080703084836.GI9549@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:48284 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756233AbYGCMBi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jul 2008 08:01:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check for error befor dereferencing xdst in xfrm_bundle_create.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index cae9fd8..9fab591 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1384,6 +1384,7 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 	struct net_device *dev;
 	struct dst_entry *dst_prev = NULL;
 	struct dst_entry *dst0 = NULL;
+	struct dst_entry *dst1 = NULL;
 	int i = 0;
 	int err;
 	int header_len = 0;
@@ -1404,7 +1405,6 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 
 	for (; i < nx; i++) {
 		struct xfrm_dst *xdst = xfrm_alloc_dst(family);
-		struct dst_entry *dst1 = &xdst->u.dst;
 
 		err = PTR_ERR(xdst);
 		if (IS_ERR(xdst)) {
@@ -1412,6 +1412,8 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 			goto put_states;
 		}
 
+		dst1 = &xdst->u.dst;
+
 		if (!dst_prev)
 			dst0 = dst1;
 		else {
-- 
1.5.3

