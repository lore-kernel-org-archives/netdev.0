From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH 1/4][CRYPTO][IPsec] pass the flags to the internal tfm
 allocation
Date: Wed, 18 Oct 2006 11:26:06 +0900
Message-ID: <20061018112606.b4f40c18.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 221x116x13x66.ap221.ftth.ucom.ne.jp ([221.116.13.66]:58859 "EHLO
	miyazawa.org") by vger.kernel.org with ESMTP id S1751161AbWJRC0I
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 22:26:08 -0400
To: davem@davemloft.net, herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

XCBC needs to allocate the tfm as CBC mode to use
"xor" function in the tfm.

Signed-off-by: Kazunori MIYAZAWA <miyazawa@linux-ipv6.org>
---
 crypto/algapi.c         |    2 +-
 include/crypto/algapi.h |    1 +
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/crypto/algapi.c b/crypto/algapi.c
index c915300..d3f4bb4 100644
--- a/crypto/algapi.c
+++ b/crypto/algapi.c
@@ -396,7 +396,7 @@ struct crypto_tfm *crypto_spawn_tfm(stru
 		return ERR_PTR(-EAGAIN);
 	}
 
-	tfm = __crypto_alloc_tfm(alg, 0);
+	tfm = __crypto_alloc_tfm(alg, spawn->flags);
 	if (IS_ERR(tfm))
 		crypto_mod_put(alg);
 
diff --git a/include/crypto/algapi.h b/include/crypto/algapi.h
index 5748aec..fb7f958 100644
--- a/include/crypto/algapi.h
+++ b/include/crypto/algapi.h
@@ -48,6 +48,7 @@ struct crypto_spawn {
 	struct list_head list;
 	struct crypto_alg *alg;
 	struct crypto_instance *inst;
+	u32 flags;
 };
 
 struct scatter_walk {
-- 
1.4.2
