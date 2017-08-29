From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 5/7] xfrm_user: fix info leak in xfrm_notify_sa()
Date: Tue, 29 Aug 2017 12:31:32 +0200
Message-ID: <1504002694-1931-6-git-send-email-steffen.klassert@secunet.com>
References: <1504002694-1931-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:50688 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752246AbdH2Kbo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 06:31:44 -0400
In-Reply-To: <1504002694-1931-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <minipli@googlemail.com>

The memory reserved to dump the ID of the xfrm state includes a padding
byte in struct xfrm_usersa_id added by the compiler for alignment. To
prevent the heap info leak, memset(0) the whole struct before filling
it.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Fixes: 0603eac0d6b7 ("[IPSEC]: Add XFRMA_SA/XFRMA_POLICY for delete notification")
Signed-off-by: Mathias Krause <minipli@googlemail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 3259555..c33516e 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2715,6 +2715,7 @@ static int xfrm_notify_sa(struct xfrm_state *x, const struct km_event *c)
 		struct nlattr *attr;
 
 		id = nlmsg_data(nlh);
+		memset(id, 0, sizeof(*id));
 		memcpy(&id->daddr, &x->id.daddr, sizeof(id->daddr));
 		id->spi = x->id.spi;
 		id->family = x->props.family;
-- 
2.7.4
