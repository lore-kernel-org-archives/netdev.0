From: David Miller <davem@davemloft.net>
Subject: [PATCH 06/20] xfrm: Mark token args to addr_match() const.
Date: Tue, 22 Feb 2011 19:54:21 -0800 (PST)
Message-ID: <20110222.195421.183028486.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32830
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756110Ab1BWDxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 22:53:44 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 8D6F224C088
	for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 19:54:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Also, make it return a real bool.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index cbe0003..2328532 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -765,10 +765,11 @@ static inline void xfrm_state_hold(struct xfrm_state *x)
 	atomic_inc(&x->refcnt);
 }
 
-static __inline__ int addr_match(void *token1, void *token2, int prefixlen)
+static inline bool addr_match(const void *token1, const void *token2,
+			      int prefixlen)
 {
-	__be32 *a1 = token1;
-	__be32 *a2 = token2;
+	const __be32 *a1 = token1;
+	const __be32 *a2 = token2;
 	int pdw;
 	int pbi;
 
@@ -777,7 +778,7 @@ static __inline__ int addr_match(void *token1, void *token2, int prefixlen)
 
 	if (pdw)
 		if (memcmp(a1, a2, pdw << 2))
-			return 0;
+			return false;
 
 	if (pbi) {
 		__be32 mask;
@@ -785,10 +786,10 @@ static __inline__ int addr_match(void *token1, void *token2, int prefixlen)
 		mask = htonl((0xffffffff) << (32 - pbi));
 
 		if ((a1[pdw] ^ a2[pdw]) & mask)
-			return 0;
+			return false;
 	}
 
-	return 1;
+	return true;
 }
 
 static __inline__
-- 
1.7.4.1

