From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH 3/7] crypto:gf128mul: The x8_ble multiplication functions
Date: Tue,  3 Oct 2017 12:16:26 +0530
Message-ID: <3e443f7a245229a2752fcf21dfed10998847e345.1507010612.git.harsh@chelsio.com>
References: <cover.1507010612.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>
To: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:53162 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751128AbdJCGqr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 02:46:47 -0400
In-Reply-To: <cover.1507010612.git.harsh@chelsio.com>
In-Reply-To: <cover.1507010612.git.harsh@chelsio.com>
References: <cover.1507010612.git.harsh@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It multiply GF(2^128) elements in the ble format.
It will be used by chelsio driver to fasten gf multiplication.

Signed-off-by: Harsh Jain <harsh@chelsio.com>
---
 crypto/gf128mul.c         | 13 +++++++++++++
 include/crypto/gf128mul.h |  2 +-
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/crypto/gf128mul.c b/crypto/gf128mul.c
index dc01212..24e6019 100644
--- a/crypto/gf128mul.c
+++ b/crypto/gf128mul.c
@@ -156,6 +156,19 @@ static void gf128mul_x8_bbe(be128 *x)
 	x->b = cpu_to_be64((b << 8) ^ _tt);
 }
 
+void gf128mul_x8_ble(le128 *r, const le128 *x)
+{
+	u64 a = le64_to_cpu(x->a);
+	u64 b = le64_to_cpu(x->b);
+
+	/* equivalent to gf128mul_table_be[b >> 63] (see crypto/gf128mul.c): */
+	u64 _tt = gf128mul_table_be[a >> 56];
+
+	r->a = cpu_to_le64((a << 8) | (b >> 56));
+	r->b = cpu_to_le64((b << 8) ^ _tt);
+}
+EXPORT_SYMBOL(gf128mul_x8_ble);
+
 void gf128mul_lle(be128 *r, const be128 *b)
 {
 	be128 p[8];
diff --git a/include/crypto/gf128mul.h b/include/crypto/gf128mul.h
index 0977fb1..fa0a63d 100644
--- a/include/crypto/gf128mul.h
+++ b/include/crypto/gf128mul.h
@@ -227,7 +227,7 @@ struct gf128mul_4k *gf128mul_init_4k_lle(const be128 *g);
 struct gf128mul_4k *gf128mul_init_4k_bbe(const be128 *g);
 void gf128mul_4k_lle(be128 *a, const struct gf128mul_4k *t);
 void gf128mul_4k_bbe(be128 *a, const struct gf128mul_4k *t);
-
+void gf128mul_x8_ble(le128 *r, const le128 *x);
 static inline void gf128mul_free_4k(struct gf128mul_4k *t)
 {
 	kzfree(t);
-- 
2.1.4
