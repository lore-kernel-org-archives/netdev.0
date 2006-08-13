From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 11/16] [IPSEC]: Add compatibility algorithm name support
Date: Sun, 13 Aug 2006 22:20:19 +1000
Message-ID: <E1GCEx1-0004gM-00@gondolin.me.apana.org.au>
References: <20060813121722.GA16115@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:13833 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751085AbWHMMUV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 08:20:21 -0400
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Add compatibility algorithm name support

This patch adds a compatibility name field for each IPsec algorithm.  This
is needed when parameterised algorithms are used.  For example, "md5" will
become "hmac(md5)", and "aes" will become "cbc(aes)".

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/xfrm.h   |    1 +
 net/xfrm/xfrm_algo.c |    3 ++-
 net/xfrm/xfrm_user.c |    1 +
 3 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -854,6 +854,7 @@ struct xfrm_algo_comp_info {
 
 struct xfrm_algo_desc {
 	char *name;
+	char *compat;
 	u8 available:1;
 	union {
 		struct xfrm_algo_auth_info auth;
diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -359,7 +359,8 @@ static struct xfrm_algo_desc *xfrm_get_b
 		return NULL;
 
 	for (i = 0; i < entries; i++) {
-		if (strcmp(name, list[i].name))
+		if (strcmp(name, list[i].name) &&
+		    (!list[i].compat || strcmp(name, list[i].compat)))
 			continue;
 
 		if (list[i].available)
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -213,6 +213,7 @@ static int attach_one_algo(struct xfrm_a
 		return -ENOMEM;
 
 	memcpy(p, ualg, len);
+	strcpy(p->alg_name, algo->name);
 	*algpp = p;
 	return 0;
 }
