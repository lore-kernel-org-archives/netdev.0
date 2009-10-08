From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/5] ah: Remove obsolete code
Date: Thu, 8 Oct 2009 10:49:57 +0200
Message-ID: <20091008084957.GN15653@secunet.com>
References: <20091008084631.GJ15653@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:43238 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752327AbZJHIuf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2009 04:50:35 -0400
Content-Disposition: inline
In-Reply-To: <20091008084631.GJ15653@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ah4 and ah6 are converted to ahash now, so we can remove the
code for the obsolete hash algorithm.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/ah.h |   29 +++--------------------------
 1 files changed, 3 insertions(+), 26 deletions(-)

diff --git a/include/net/ah.h b/include/net/ah.h
index 7ac5221..7573a71 100644
--- a/include/net/ah.h
+++ b/include/net/ah.h
@@ -1,44 +1,21 @@
 #ifndef _NET_AH_H
 #define _NET_AH_H
 
-#include <linux/crypto.h>
-#include <net/xfrm.h>
+#include <linux/skbuff.h>
 
 /* This is the maximum truncated ICV length that we know of. */
 #define MAX_AH_AUTH_LEN	12
 
+struct crypto_ahash;
+
 struct ah_data
 {
-	u8			*work_icv;
 	int			icv_full_len;
 	int			icv_trunc_len;
 
-	struct crypto_hash	*tfm;
 	struct crypto_ahash	*ahash;
 };
 
-static inline int ah_mac_digest(struct ah_data *ahp, struct sk_buff *skb,
-				u8 *auth_data)
-{
-	struct hash_desc desc;
-	int err;
-
-	desc.tfm = ahp->tfm;
-	desc.flags = 0;
-
-	memset(auth_data, 0, ahp->icv_trunc_len);
-	err = crypto_hash_init(&desc);
-	if (unlikely(err))
-		goto out;
-	err = skb_icv_walk(skb, &desc, 0, skb->len, crypto_hash_update);
-	if (unlikely(err))
-		goto out;
-	err = crypto_hash_final(&desc, ahp->work_icv);
-
-out:
-	return err;
-}
-
 struct ip_auth_hdr;
 
 static inline struct ip_auth_hdr *ip_auth_hdr(const struct sk_buff *skb)
-- 
1.5.4.2

