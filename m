From: Horia Geanta <horia.geanta@freescale.com>
Subject: [PATCH] xfrm: fix potential incorrect pointer dereference in xfrm_bundle_create
Date: Sat, 25 Jan 2014 20:47:53 +0200
Message-ID: <1390675673-20682-1-git-send-email-horia.geanta@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe004.messaging.microsoft.com ([207.46.163.27]:35537
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751320AbaAYStk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jan 2014 13:49:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return value of xfrm_alloc_dst might be an error code.
Need to check this before using the pointer safely.

Signed-off-by: Horia Geanta <horia.geanta@freescale.com>
---
 net/xfrm/xfrm_policy.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 9a91f74..f230f2a 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1541,7 +1541,7 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 
 	for (; i < nx; i++) {
 		struct xfrm_dst *xdst = xfrm_alloc_dst(net, family);
-		struct dst_entry *dst1 = &xdst->u.dst;
+		struct dst_entry *dst1;
 
 		err = PTR_ERR(xdst);
 		if (IS_ERR(xdst)) {
@@ -1560,6 +1560,8 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 		} else
 			inner_mode = xfrm[i]->inner_mode;
 
+		dst1 = &xdst->u.dst;
+
 		if (!dst_prev)
 			dst0 = dst1;
 		else {
-- 
1.8.3.1
