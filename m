From: Martin Willi <martin@strongswan.org>
Subject: [PATCH 3/3] xfrm: Use the user specified truncation length in ESP and AH
Date: Wed, 25 Nov 2009 11:29:53 +0100
Message-ID: <c3215dad8a657aff32ef983ae935e435127d3e48.1259142145.git.martin@strongswan.org>
References: <cover.1259142145.git.martin@strongswan.org>
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zaes.ch ([213.133.111.41]:55415 "EHLO zaes.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752148AbZKYKx1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Nov 2009 05:53:27 -0500
In-Reply-To: <cover.1259142145.git.martin@strongswan.org>
In-Reply-To: <cover.1259142145.git.martin@strongswan.org>
References: <cover.1259142145.git.martin@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using the hardcoded truncation for authentication
algorithms, use the truncation length specified on xfrm_state.

Signed-off-by: Martin Willi <martin@strongswan.org>
---
 net/ipv4/ah4.c  |    2 +-
 net/ipv4/esp4.c |    2 +-
 net/ipv6/ah6.c  |    2 +-
 net/ipv6/esp6.c |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 5c66270..b7be5ed 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -261,7 +261,7 @@ static int ah_init_state(struct xfrm_state *x)
 	}
 
 	ahp->icv_full_len = aalg_desc->uinfo.auth.icv_fullbits/8;
-	ahp->icv_trunc_len = aalg_desc->uinfo.auth.icv_truncbits/8;
+	ahp->icv_trunc_len = x->aalg->alg_trunc_len/8;
 
 	BUG_ON(ahp->icv_trunc_len > MAX_AH_AUTH_LEN);
 
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 12f7287..1948895 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -530,7 +530,7 @@ static int esp_init_authenc(struct xfrm_state *x)
 		}
 
 		err = crypto_aead_setauthsize(
-			aead, aalg_desc->uinfo.auth.icv_truncbits / 8);
+			aead, x->aalg->alg_trunc_len / 8);
 		if (err)
 			goto free_key;
 	}
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index c1589e2..0c2ae68 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -469,7 +469,7 @@ static int ah6_init_state(struct xfrm_state *x)
 	}
 
 	ahp->icv_full_len = aalg_desc->uinfo.auth.icv_fullbits/8;
-	ahp->icv_trunc_len = aalg_desc->uinfo.auth.icv_truncbits/8;
+	ahp->icv_trunc_len = x->aalg->alg_trunc_len/8;
 
 	BUG_ON(ahp->icv_trunc_len > MAX_AH_AUTH_LEN);
 
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index af597c7..668a46b 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -473,7 +473,7 @@ static int esp_init_authenc(struct xfrm_state *x)
 		}
 
 		err = crypto_aead_setauthsize(
-			aead, aalg_desc->uinfo.auth.icv_truncbits / 8);
+			aead, x->aalg->alg_trunc_len / 8);
 		if (err)
 			goto free_key;
 	}
-- 
1.6.3.3

