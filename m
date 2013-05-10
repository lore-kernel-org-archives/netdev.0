From: Cong Wang <amwang@redhat.com>
Subject: [Patch net] xfrm6: release dev before returning error
Date: Fri, 10 May 2013 16:40:00 +0800
Message-ID: <1368175200-26877-1-git-send-email-amwang@redhat.com>
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17899 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751561Ab3EJIk1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 May 2013 04:40:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

We forget to call dev_put() on error path in xfrm6_fill_dst(),
its caller doesn't handle this.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 4ef7bdb..23ed03d 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -103,8 +103,10 @@ static int xfrm6_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 	dev_hold(dev);
 
 	xdst->u.rt6.rt6i_idev = in6_dev_get(dev);
-	if (!xdst->u.rt6.rt6i_idev)
+	if (!xdst->u.rt6.rt6i_idev) {
+		dev_put(dev);
 		return -ENODEV;
+	}
 
 	rt6_transfer_peer(&xdst->u.rt6, rt);
 
