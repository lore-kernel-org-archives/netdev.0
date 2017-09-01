From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/2] xfrm: Fix return value check of copy_sec_ctx.
Date: Fri, 1 Sep 2017 09:30:46 +0200
Message-ID: <1504251046-17106-3-git-send-email-steffen.klassert@secunet.com>
References: <1504251046-17106-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:50296 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751413AbdIAHaw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 03:30:52 -0400
In-Reply-To: <1504251046-17106-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A recent commit added an output_mark. When copying
this output_mark, the return value of copy_sec_ctx
is overwitten without a check. Fix this by copying
the output_mark before the security context.

Fixes: 077fbac405bf ("net: xfrm: support setting an output mark.")
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index cc3268d..490132d 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -900,13 +900,13 @@ static int copy_to_user_state_extra(struct xfrm_state *x,
 		ret = copy_user_offload(&x->xso, skb);
 	if (ret)
 		goto out;
-	if (x->security)
-		ret = copy_sec_ctx(x->security, skb);
 	if (x->props.output_mark) {
 		ret = nla_put_u32(skb, XFRMA_OUTPUT_MARK, x->props.output_mark);
 		if (ret)
 			goto out;
 	}
+	if (x->security)
+		ret = copy_sec_ctx(x->security, skb);
 out:
 	return ret;
 }
-- 
2.7.4
