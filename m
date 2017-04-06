From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/4] xfrm: Prepare for CRYPTO_MAX_ALG_NAME expansion
Date: Thu, 06 Apr 2017 16:16:10 +0800
Message-ID: <E1cw2aQ-00085u-SY@gondobar>
References: <20170406081509.GB30557@gondor.apana.org.au>
To: Alexander Sverdlin <alexander.sverdlin@nokia.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-crypto@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orcrist.hmeau.com ([104.223.48.154]:37966 "EHLO
        deadmen.hmeau.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751920AbdDFIQg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 04:16:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the xfrm_user code to use the actual array size
rather than the hard-coded CRYPTO_MAX_ALG_NAME length.  This is
because the array size is fixed at 64 bytes while we want to increase
the in-kernel CRYPTO_MAX_ALG_NAME value.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/xfrm/xfrm_user.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 9705c27..96557cf 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -55,7 +55,7 @@ static int verify_one_alg(struct nlattr **attrs, enum xfrm_attr_type_t type)
 		return -EINVAL;
 	}
 
-	algp->alg_name[CRYPTO_MAX_ALG_NAME - 1] = '\0';
+	algp->alg_name[sizeof(algp->alg_name) - 1] = '\0';
 	return 0;
 }
 
@@ -71,7 +71,7 @@ static int verify_auth_trunc(struct nlattr **attrs)
 	if (nla_len(rt) < xfrm_alg_auth_len(algp))
 		return -EINVAL;
 
-	algp->alg_name[CRYPTO_MAX_ALG_NAME - 1] = '\0';
+	algp->alg_name[sizeof(algp->alg_name) - 1] = '\0';
 	return 0;
 }
 
@@ -87,7 +87,7 @@ static int verify_aead(struct nlattr **attrs)
 	if (nla_len(rt) < aead_len(algp))
 		return -EINVAL;
 
-	algp->alg_name[CRYPTO_MAX_ALG_NAME - 1] = '\0';
+	algp->alg_name[sizeof(algp->alg_name) - 1] = '\0';
 	return 0;
 }
 
