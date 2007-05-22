From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC]: Fix warnings with casting int to pointer
Date: Tue, 22 May 2007 21:27:03 +1000
Message-ID: <20070522112703.GA12673@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4520 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755701AbXEVL1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 07:27:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

Here's patch to fix the warnings.

[IPSEC]: Fix warnings with casting int to pointer

This patch adds some casts to shut up the warnings introduced by my
last patch that added a common interator function for xfrm algorightms.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au> 

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index 94e3588..ffa1515 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -390,27 +390,27 @@ static struct xfrm_algo_desc *xfrm_find_algo(
 static int xfrm_alg_id_match(const struct xfrm_algo_desc *entry,
 			     const void *data)
 {
-	return entry->desc.sadb_alg_id == (int)data;
+	return entry->desc.sadb_alg_id == (unsigned long)data;
 }
 
 struct xfrm_algo_desc *xfrm_aalg_get_byid(int alg_id)
 {
 	return xfrm_find_algo(&xfrm_aalg_list, xfrm_alg_id_match,
-			      (void *)alg_id, 1);
+			      (void *)(unsigned long)alg_id, 1);
 }
 EXPORT_SYMBOL_GPL(xfrm_aalg_get_byid);
 
 struct xfrm_algo_desc *xfrm_ealg_get_byid(int alg_id)
 {
 	return xfrm_find_algo(&xfrm_ealg_list, xfrm_alg_id_match,
-			      (void *)alg_id, 1);
+			      (void *)(unsigned long)alg_id, 1);
 }
 EXPORT_SYMBOL_GPL(xfrm_ealg_get_byid);
 
 struct xfrm_algo_desc *xfrm_calg_get_byid(int alg_id)
 {
 	return xfrm_find_algo(&xfrm_calg_list, xfrm_alg_id_match,
-			      (void *)alg_id, 1);
+			      (void *)(unsigned long)alg_id, 1);
 }
 EXPORT_SYMBOL_GPL(xfrm_calg_get_byid);
 
