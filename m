From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/8] xfrm: make xfrm_alg_auth_len() return unsigned int
Date: Mon, 30 Oct 2017 09:39:30 +0100
Message-ID: <1509352775-9563-4-git-send-email-steffen.klassert@secunet.com>
References: <1509352775-9563-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:41256 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752528AbdJ3Ijn (ORCPT <rfc822;netdev@vger.kernel.org>);
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
index 2abc0e1..5d5e11b 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1774,7 +1774,7 @@ static inline unsigned int xfrm_alg_len(const struct xfrm_algo *alg)
 	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
 }
 
-static inline int xfrm_alg_auth_len(const struct xfrm_algo_auth *alg)
+static inline unsigned int xfrm_alg_auth_len(const struct xfrm_algo_auth *alg)
 {
 	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
 }
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 09512d9..465c23d 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -68,7 +68,7 @@ static int verify_auth_trunc(struct nlattr **attrs)
 		return 0;
 
 	algp = nla_data(rt);
-	if (nla_len(rt) < xfrm_alg_auth_len(algp))
+	if (nla_len(rt) < (int)xfrm_alg_auth_len(algp))
 		return -EINVAL;
 
 	algp->alg_name[sizeof(algp->alg_name) - 1] = '\0';
-- 
2.7.4
