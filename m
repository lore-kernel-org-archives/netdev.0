From: Tushar Gohad <tgohad@mvista.com>
Subject: [PATCH] xfrm: Fix key lengths for rfc3686(ctr(aes))
Date: Thu, 28 Jul 2011 13:36:20 -0700 (MST)
Message-ID: <alpine.LFD.1.10.1107281246381.11308@net-test1.az.mvista.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: netdev <netdev@vger.kernel.org>, tgohad@mvista.com
To: Joy Latten <latten@austin.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:63210 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175Ab1G1Uq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 16:46:26 -0400
Received: by yxi11 with SMTP id 11so1818050yxi.19
        for <netdev@vger.kernel.org>; Thu, 28 Jul 2011 13:46:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Fix the min and max bit lengths for AES-CTR (RFC3686) keys.
The number of bits in key spec is the key length (128/256)
plus 32 bits of nonce.

This change takes care of the "Invalid key length" errors
reported by setkey when specifying 288 bit keys for aes-ctr.

Signed-off-by: Tushar Gohad <tgohad@mvista.com>
---
  net/xfrm/xfrm_algo.c |    4 ++--
  1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index 58064d9..791ab2e 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -462,8 +462,8 @@ static struct xfrm_algo_desc ealg_list[] = {
  	.desc = {
  		.sadb_alg_id = SADB_X_EALG_AESCTR,
  		.sadb_alg_ivlen	= 8,
-		.sadb_alg_minbits = 128,
-		.sadb_alg_maxbits = 256
+		.sadb_alg_minbits = 160,
+		.sadb_alg_maxbits = 288
  	}
  },
  };
-- 
1.6.3.3.202.g91879

