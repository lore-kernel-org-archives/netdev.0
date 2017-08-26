From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH net 4/4] xfrm_user: fix info leak in build_aevent()
Date: Sat, 26 Aug 2017 17:09:00 +0200
Message-ID: <1503760140-9095-5-git-send-email-minipli@googlemail.com>
References: <1503760140-9095-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
        "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:38389 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751063AbdHZPJb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Aug 2017 11:09:31 -0400
Received: by mail-wr0-f194.google.com with SMTP id o76so1498626wrb.5
        for <netdev@vger.kernel.org>; Sat, 26 Aug 2017 08:09:31 -0700 (PDT)
In-Reply-To: <1503760140-9095-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The memory reserved to dump the ID of the xfrm state includes a padding
byte in struct xfrm_usersa_id added by the compiler for alignment. To
prevent the heap info leak, memset(0) the sa_id before filling it.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Fixes: d51d081d6504 ("[IPSEC]: Sync series - user")
Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/xfrm/xfrm_user.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 2cbdc81610c6..9391ced05259 100644
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
1.7.10.4
