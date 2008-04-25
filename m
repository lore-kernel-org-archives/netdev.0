From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [XFRM]: alg_key_len & alg_icv_len should be unsigned
Date: Fri, 25 Apr 2008 09:09:05 +0200
Message-ID: <48118391.3010109@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000006040102080002070506"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2e.orange.fr ([80.12.242.112]:49085 "EHLO smtp2e.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751205AbYDYHJY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 03:09:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000006040102080002070506
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

In commit ba749ae98d5aa9d2ce9a7facde0deed454f92230 ([XFRM]: alg_key_len 
should be unsigned to avoid integer divides 
<http://git2.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commitdiff;h=ba749ae98d5aa9d2ce9a7facde0deed454f92230>) 
alg_key_len field of struct xfrm_algo was converted to unsigned int to 
avoid integer divides.

Then Herbert in commit 1a6509d991225ad210de54c63314fd9542922095 
([IPSEC]: Add support for combined mode algorithms) added a new 
structure xfrm_algo_aead, that resurrected a signed int for alg_key_len 
and re-introduce integer divides.

This patch avoids these divides and saves 64 bytes of text on i386.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>



--------------000006040102080002070506
Content-Type: text/plain;
 name="xfrm.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="xfrm.patch"

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 0c82c80..2ca6bae 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -97,10 +97,10 @@ struct xfrm_algo {
 };
 
 struct xfrm_algo_aead {
-	char	alg_name[64];
-	int	alg_key_len;	/* in bits */
-	int	alg_icv_len;	/* in bits */
-	char	alg_key[0];
+	char		alg_name[64];
+	unsigned int	alg_key_len;	/* in bits */
+	unsigned int	alg_icv_len;	/* in bits */
+	char		alg_key[0];
 };
 
 struct xfrm_stats {

--------------000006040102080002070506--


