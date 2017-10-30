From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/8] xfrm: make aead_len() return unsigned int
Date: Mon, 30 Oct 2017 09:39:28 +0100
Message-ID: <1509352775-9563-2-git-send-email-steffen.klassert@secunet.com>
References: <1509352775-9563-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:41218 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752524AbdJ3Ijn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Oct 2017 04:39:43 -0400
In-Reply-To: <1509352775-9563-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>

Key lengths can't be negative.

Comparison with nla_len() is left signed just in case negative value
can sneak in there.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h   | 2 +-
 net/xfrm/xfrm_user.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index f002a2c..0be4c54 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1764,7 +1764,7 @@ static inline int xfrm_acquire_is_on(struct net *net)
 }
 #endif
 
-static inline int aead_len(struct xfrm_algo_aead *alg)
+static inline unsigned int aead_len(struct xfrm_algo_aead *alg)
 {
 	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
 }
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 2bfbd91..32c67b8 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -84,7 +84,7 @@ static int verify_aead(struct nlattr **attrs)
 		return 0;
 
 	algp = nla_data(rt);
-	if (nla_len(rt) < aead_len(algp))
+	if (nla_len(rt) < (int)aead_len(algp))
 		return -EINVAL;
 
 	algp->alg_name[sizeof(algp->alg_name) - 1] = '\0';
-- 
2.7.4
