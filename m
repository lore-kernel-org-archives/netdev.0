From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH net 1/4] xfrm_user: fix info leak in copy_user_offload()
Date: Sat, 26 Aug 2017 17:08:57 +0200
Message-ID: <1503760140-9095-2-git-send-email-minipli@googlemail.com>
References: <1503760140-9095-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
        "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:38803 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751063AbdHZPJ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Aug 2017 11:09:28 -0400
Received: by mail-wm0-f68.google.com with SMTP id z132so2558393wmg.5
        for <netdev@vger.kernel.org>; Sat, 26 Aug 2017 08:09:27 -0700 (PDT)
In-Reply-To: <1503760140-9095-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The memory reserved to dump the xfrm offload state includes padding
bytes of struct xfrm_user_offload added by the compiler for alignment.
Add an explicit memset(0) before filling the buffer to avoid the heap
info leak.

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Fixes: d77e38e612a0 ("xfrm: Add an IPsec hardware offloading API")
Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/xfrm/xfrm_user.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 2be4c6af008a..3259555ae7d7 100644
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
1.7.10.4
