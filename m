From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 2/5] xfrm: make xfrm_alg_len() return unsigned int
Date: Thu, 21 Sep 2017 23:46:30 +0300
Message-ID: <20170921204630.GC13550@avx2>
References: <20170921204543.GB13550@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
        netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36648 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751707AbdIUUqe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 16:46:34 -0400
Received: by mail-wm0-f65.google.com with SMTP id r136so6211154wmf.3
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 13:46:33 -0700 (PDT)
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
@@ -1769,7 +1769,7 @@ static inline unsigned int aead_len(struct xfrm_algo_aead *alg)
 	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
 }
 
-static inline int xfrm_alg_len(const struct xfrm_algo *alg)
+static inline unsigned int xfrm_alg_len(const struct xfrm_algo *alg)
 {
 	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
 }
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -42,7 +42,7 @@ static int verify_one_alg(struct nlattr **attrs, enum xfrm_attr_type_t type)
 		return 0;
 
 	algp = nla_data(rt);
-	if (nla_len(rt) < xfrm_alg_len(algp))
+	if (nla_len(rt) < (int)xfrm_alg_len(algp))
 		return -EINVAL;
 
 	switch (type) {
