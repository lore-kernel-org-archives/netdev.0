From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/1 net-2.6.26] [XFRM]: Compilation warnings in xfrm_user.c.
Date: Mon, 14 Apr 2008 17:03:39 +0400
Message-ID: <1208178219-18754-1-git-send-email-den@openvz.org>
Cc: herbert@gondor.apana.org.au, paul.moore@hp.com,
	netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:11285 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751876AbYDNNDu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 09:03:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_SECURITY_NETWORK_XFRM is undefined the following warnings appears:
net/xfrm/xfrm_user.c: In function 'xfrm_add_pol_expire':
net/xfrm/xfrm_user.c:1576: warning: 'ctx' may be used uninitialized in this function
net/xfrm/xfrm_user.c: In function 'xfrm_get_policy':
net/xfrm/xfrm_user.c:1340: warning: 'ctx' may be used uninitialized in this function
(security_xfrm_policy_alloc is noop for the case).

It seems that they are result of the commit
03e1ad7b5d871d4189b1da3125c2f12d1b5f7d0b

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/xfrm/xfrm_user.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index b822b56..1810f56 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1343,14 +1343,14 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 		if (err)
 			return err;
 
+		ctx = NULL;
 		if (rt) {
 			struct xfrm_user_sec_ctx *uctx = nla_data(rt);
 
 			err = security_xfrm_policy_alloc(&ctx, uctx);
 			if (err)
 				return err;
-		} else
-			ctx = NULL;
+		}
 		xp = xfrm_policy_bysel_ctx(type, p->dir, &p->sel, ctx,
 					   delete, &err);
 		security_xfrm_policy_free(ctx);
@@ -1579,14 +1579,14 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 		if (err)
 			return err;
 
+		ctx = NULL;
 		if (rt) {
 			struct xfrm_user_sec_ctx *uctx = nla_data(rt);
 
 			err = security_xfrm_policy_alloc(&ctx, uctx);
 			if (err)
 				return err;
-		} else
-			ctx = NULL;
+		}
 		xp = xfrm_policy_bysel_ctx(type, p->dir, &p->sel, ctx, 0, &err);
 		security_xfrm_policy_free(ctx);
 	}
-- 
1.5.3.rc5

