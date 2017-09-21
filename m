From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 3/5] xfrm: make xfrm_alg_auth_len() return unsigned int
Date: Thu, 21 Sep 2017 23:47:09 +0300
Message-ID: <20170921204709.GD13550@avx2>
References: <20170921204543.GB13550@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
        netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34871 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751697AbdIUUrN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 16:47:13 -0400
Received: by mail-wr0-f196.google.com with SMTP id n64so3719066wrb.2
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 13:47:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170921204543.GB13550@avx2>
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
@@ -1774,7 +1774,7 @@ static inline unsigned int xfrm_alg_len(const struct xfrm_algo *alg)
 	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
 }
 
-static inline int xfrm_alg_auth_len(const struct xfrm_algo_auth *alg)
+static inline unsigned int xfrm_alg_auth_len(const struct xfrm_algo_auth *alg)
 {
 	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
 }
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -68,7 +68,7 @@ static int verify_auth_trunc(struct nlattr **attrs)
 		return 0;
 
 	algp = nla_data(rt);
-	if (nla_len(rt) < xfrm_alg_auth_len(algp))
+	if (nla_len(rt) < (int)xfrm_alg_auth_len(algp))
 		return -EINVAL;
 
 	algp->alg_name[sizeof(algp->alg_name) - 1] = '\0';
