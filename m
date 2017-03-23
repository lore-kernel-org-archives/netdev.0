From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] xfrm: use "unsigned int" in addr_match()
Date: Fri, 24 Mar 2017 02:07:50 +0300
Message-ID: <20170323230750.GD31372@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
        netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:33313 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752008AbdCWXHz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 19:07:55 -0400
Received: by mail-lf0-f68.google.com with SMTP id r36so18432074lfi.0
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 16:07:54 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

x86_64 is zero-extending arch so "unsigned int" is preferred over "int"
for address calculations and extending to size_t.

Space savings:

	add/remove: 0/0 grow/shrink: 0/2 up/down: 0/-24 (-24)
	function                                     old     new   delta
	xfrm_state_walk                              708     696     -12
	xfrm_selector_match                          918     906     -12

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/xfrm.h |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

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
