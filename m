From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/7] xfrm_user: fix info leak in copy_user_offload()
Date: Tue, 29 Aug 2017 12:31:31 +0200
Message-ID: <1504002694-1931-5-git-send-email-steffen.klassert@secunet.com>
References: <1504002694-1931-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:50664 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751935AbdH2Kbn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 06:31:43 -0400
In-Reply-To: <1504002694-1931-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <minipli@googlemail.com>

The memory reserved to dump the xfrm offload state includes padding
bytes of struct xfrm_user_offload added by the compiler for alignment.
Add an explicit memset(0) before filling the buffer to avoid the heap
info leak.

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Fixes: d77e38e612a0 ("xfrm: Add an IPsec hardware offloading API")
Signed-off-by: Mathias Krause <minipli@googlemail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 2be4c6a..3259555 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -796,7 +796,7 @@ static int copy_user_offload(struct xfrm_state_offload *xso, struct sk_buff *skb
 		return -EMSGSIZE;
 
 	xuo = nla_data(attr);
-
+	memset(xuo, 0, sizeof(*xuo));
 	xuo->ifindex = xso->dev->ifindex;
 	xuo->flags = xso->flags;
 
-- 
2.7.4
