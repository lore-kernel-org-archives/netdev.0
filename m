From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH net 2/4] xfrm_user: fix info leak in xfrm_notify_sa()
Date: Sat, 26 Aug 2017 17:08:58 +0200
Message-ID: <1503760140-9095-3-git-send-email-minipli@googlemail.com>
References: <1503760140-9095-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
        "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36449 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751085AbdHZPJ3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Aug 2017 11:09:29 -0400
Received: by mail-wm0-f65.google.com with SMTP id j72so2586583wmi.3
        for <netdev@vger.kernel.org>; Sat, 26 Aug 2017 08:09:28 -0700 (PDT)
In-Reply-To: <1503760140-9095-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The memory reserved to dump the ID of the xfrm state includes a padding
byte in struct xfrm_usersa_id added by the compiler for alignment. To
prevent the heap info leak, memset(0) the whole struct before filling
it.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Fixes: 0603eac0d6b7 ("[IPSEC]: Add XFRMA_SA/XFRMA_POLICY for delete notification")
Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/xfrm/xfrm_user.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 3259555ae7d7..c33516ef52f2 100644
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
1.7.10.4
