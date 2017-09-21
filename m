From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 1/5] xfrm: make aead_len() return unsigned int
Date: Thu, 21 Sep 2017 23:45:43 +0300
Message-ID: <20170921204543.GB13550@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
        netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36148 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751750AbdIUUpr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 16:45:47 -0400
Received: by mail-wr0-f195.google.com with SMTP id g50so3711112wra.3
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 13:45:46 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Key lengths can't be negative.

Comparison with nla_len() is left signed just in case negative value
can sneak in there.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/xfrm.h   |    2 +-
 net/xfrm/xfrm_user.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

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
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -84,7 +84,7 @@ static int verify_aead(struct nlattr **attrs)
 		return 0;
 
 	algp = nla_data(rt);
-	if (nla_len(rt) < aead_len(algp))
+	if (nla_len(rt) < (int)aead_len(algp))
 		return -EINVAL;
 
 	algp->alg_name[sizeof(algp->alg_name) - 1] = '\0';
