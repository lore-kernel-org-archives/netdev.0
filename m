From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 7/7] xfrm_user: fix info leak in build_aevent()
Date: Tue, 29 Aug 2017 12:31:34 +0200
Message-ID: <1504002694-1931-8-git-send-email-steffen.klassert@secunet.com>
References: <1504002694-1931-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:50686 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751238AbdH2Kbp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 06:31:45 -0400
In-Reply-To: <1504002694-1931-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <minipli@googlemail.com>

The memory reserved to dump the ID of the xfrm state includes a padding
byte in struct xfrm_usersa_id added by the compiler for alignment. To
prevent the heap info leak, memset(0) the sa_id before filling it.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Fixes: d51d081d6504 ("[IPSEC]: Sync series - user")
Signed-off-by: Mathias Krause <minipli@googlemail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 2cbdc81..9391ced 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1869,6 +1869,7 @@ static int build_aevent(struct sk_buff *skb, struct xfrm_state *x, const struct
 		return -EMSGSIZE;
 
 	id = nlmsg_data(nlh);
+	memset(&id->sa_id, 0, sizeof(id->sa_id));
 	memcpy(&id->sa_id.daddr, &x->id.daddr, sizeof(x->id.daddr));
 	id->sa_id.spi = x->id.spi;
 	id->sa_id.family = x->props.family;
-- 
2.7.4
