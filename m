From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/4] xfrm: use "unsigned int" in addr_match()
Date: Tue, 11 Apr 2017 07:53:51 +0200
Message-ID: <1491890032-28655-4-git-send-email-steffen.klassert@secunet.com>
References: <1491890032-28655-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:56556 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752807AbdDKF7g (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 01:59:36 -0400
In-Reply-To: <1491890032-28655-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>

x86_64 is zero-extending arch so "unsigned int" is preferred over "int"
for address calculations and extending to size_t.

Space savings:

	add/remove: 0/0 grow/shrink: 0/2 up/down: 0/-24 (-24)
	function                                     old     new   delta
	xfrm_state_walk                              708     696     -12
	xfrm_selector_match                          918     906     -12

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 6e03a1a..43b93d1 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -816,12 +816,12 @@ static inline void xfrm_state_hold(struct xfrm_state *x)
 }
 
 static inline bool addr_match(const void *token1, const void *token2,
-			      int prefixlen)
+			      unsigned int prefixlen)
 {
 	const __be32 *a1 = token1;
 	const __be32 *a2 = token2;
-	int pdw;
-	int pbi;
+	unsigned int pdw;
+	unsigned int pbi;
 
 	pdw = prefixlen >> 5;	  /* num of whole u32 in prefix */
 	pbi = prefixlen &  0x1f;  /* num of bits in incomplete u32 in prefix */
-- 
2.7.4
