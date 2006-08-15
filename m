From: David Miller <davem@davemloft.net>
Subject: [PATCH 8/10]: [XFRM]: Simplify xfrm_spi_hash
Date: Tue, 15 Aug 2006 04:40:10 -0700 (PDT)
Message-ID: <20060815.044010.93209014.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:4315
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030263AbWHOLkL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 07:40:11 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[XFRM]: Simplify xfrm_spi_hash

It can use __xfrm{4,6}_addr_hash().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_state.c |   27 ++++++---------------------
 1 files changed, 6 insertions(+), 21 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 9b3ab5c..3e8485a 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -86,35 +86,20 @@ static inline unsigned int xfrm_dst_hash
 	return __xfrm_dst_hash(addr, reqid, family, xfrm_state_hmask);
 }
 
-static inline unsigned int __xfrm4_spi_hash(xfrm_address_t *addr, u32 spi, u8 proto,
-					    unsigned int hmask)
-{
-	unsigned int h;
-	h = ntohl(addr->a4^spi^proto);
-	h = (h ^ (h>>10) ^ (h>>20)) & hmask;
-	return h;
-}
-
-static inline unsigned int __xfrm6_spi_hash(xfrm_address_t *addr, u32 spi, u8 proto,
-					    unsigned int hmask)
-{
-	unsigned int h;
-	h = ntohl(addr->a6[2]^addr->a6[3]^spi^proto);
-	h = (h ^ (h>>10) ^ (h>>20)) & hmask;
-	return h;
-}
-
 static inline unsigned int
 __xfrm_spi_hash(xfrm_address_t *addr, u32 spi, u8 proto, unsigned short family,
 		unsigned int hmask)
 {
+	unsigned int h = spi ^ proto;
 	switch (family) {
 	case AF_INET:
-		return __xfrm4_spi_hash(addr, spi, proto, hmask);
+		h ^= __xfrm4_addr_hash(addr);
+		break;
 	case AF_INET6:
-		return __xfrm6_spi_hash(addr, spi, proto, hmask);
+		h ^= __xfrm6_addr_hash(addr);
+		break;
 	}
-	return 0;	/*XXX*/
+	return (h ^ (h >> 10) ^ (h >> 20)) & hmask;
 }
 
 static inline unsigned int
-- 
1.4.2.rc2.g3e042

