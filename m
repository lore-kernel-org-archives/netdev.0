From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] xfrm: potential uninitialized variable num_xfrms
Date: Wed, 28 Apr 2010 15:20:22 +0800
Message-ID: <1272439222-2935-1-git-send-email-xiaosuo@gmail.com>
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, Timo Teras <timo.teras@iki.fi>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:40374 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864Ab0D1HrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 03:47:09 -0400
Received: by pvg6 with SMTP id 6so7866pvg.19
        for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 00:47:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

potential uninitialized variable num_xfrms

fix compiler warning: 'num_xfrms' may be used uninitialized in this function.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/xfrm/xfrm_policy.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 7430ac2..31f4ba4 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1732,7 +1732,7 @@ int __xfrm_lookup(struct net *net, struct dst_entry **dst_p, struct flowi *fl,
 	struct dst_entry *dst, *dst_orig = *dst_p, *route;
 	u16 family = dst_orig->ops->family;
 	u8 dir = policy_to_flow_dir(XFRM_POLICY_OUT);
-	int i, err, num_pols, num_xfrms, drop_pols = 0;
+	int i, err, num_pols, num_xfrms = 0, drop_pols = 0;
 
 restart:
 	dst = NULL;
