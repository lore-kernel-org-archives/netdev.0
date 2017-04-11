From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/4] xfrm: use "unsigned int" in __xfrm6_pref_hash()
Date: Tue, 11 Apr 2017 07:53:50 +0200
Message-ID: <1491890032-28655-3-git-send-email-steffen.klassert@secunet.com>
References: <1491890032-28655-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:56564 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752220AbdDKF7r (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 01:59:47 -0400
In-Reply-To: <1491890032-28655-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>

x86_64 is zero-extending arch so "unsigned int" is preferred over "int"
for address calculations.

Space savings:

	add/remove: 0/0 grow/shrink: 0/3 up/down: 0/-58 (-58)
	function                                     old     new   delta
	xfrm_hash_resize                            2752    2743      -9
	policy_hash_bysel                            985     973     -12
	policy_hash_direct                          1036     999     -37

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_hash.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_hash.h b/net/xfrm/xfrm_hash.h
index 666c5ff..eaea9c4 100644
--- a/net/xfrm/xfrm_hash.h
+++ b/net/xfrm/xfrm_hash.h
@@ -54,8 +54,8 @@ static inline unsigned int __xfrm4_dpref_spref_hash(const xfrm_address_t *daddr,
 static inline unsigned int __xfrm6_pref_hash(const xfrm_address_t *addr,
 					     __u8 prefixlen)
 {
-	int pdw;
-	int pbi;
+	unsigned int pdw;
+	unsigned int pbi;
 	u32 initval = 0;
 
 	pdw = prefixlen >> 5;     /* num of whole u32 in prefix */
-- 
2.7.4
