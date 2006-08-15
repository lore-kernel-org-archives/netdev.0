From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/10]: [XFRM]: Move SPI hashing functions local to
 xfrm_state.c
Date: Tue, 15 Aug 2006 04:38:21 -0700 (PDT)
Message-ID: <20060815.043821.130848883.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:475
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030227AbWHOLiX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 07:38:23 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[XFRM]: Move SPI hashing functions local to xfrm_state.c

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h    |   32 --------------------------------
 net/xfrm/xfrm_state.c |   32 ++++++++++++++++++++++++++++++++
 2 files changed, 32 insertions(+), 32 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 00ae025..2cbaee7 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -382,38 +382,6 @@ static inline void xfrm_pol_put(struct x
 		__xfrm_policy_destroy(policy);
 }
 
-#define XFRM_DST_HSIZE		1024
-
-static __inline__
-unsigned __xfrm4_spi_hash(xfrm_address_t *addr, u32 spi, u8 proto)
-{
-	unsigned h;
-	h = ntohl(addr->a4^spi^proto);
-	h = (h ^ (h>>10) ^ (h>>20)) % XFRM_DST_HSIZE;
-	return h;
-}
-
-static __inline__
-unsigned __xfrm6_spi_hash(xfrm_address_t *addr, u32 spi, u8 proto)
-{
-	unsigned h;
-	h = ntohl(addr->a6[2]^addr->a6[3]^spi^proto);
-	h = (h ^ (h>>10) ^ (h>>20)) % XFRM_DST_HSIZE;
-	return h;
-}
-
-static __inline__
-unsigned xfrm_spi_hash(xfrm_address_t *addr, u32 spi, u8 proto, unsigned short family)
-{
-	switch (family) {
-	case AF_INET:
-		return __xfrm4_spi_hash(addr, spi, proto);
-	case AF_INET6:
-		return __xfrm6_spi_hash(addr, spi, proto);
-	}
-	return 0;	/*XXX*/
-}
-
 extern void __xfrm_state_destroy(struct xfrm_state *);
 
 static inline void __xfrm_state_put(struct xfrm_state *x)
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 9da47aa..e4b0c6e 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -38,6 +38,8 @@ EXPORT_SYMBOL(sysctl_xfrm_aevent_rseqth)
 
 static DEFINE_SPINLOCK(xfrm_state_lock);
 
+#define XFRM_DST_HSIZE		1024
+
 /* Hash table to find appropriate SA towards given target (endpoint
  * of tunnel or destination of transport mode) allowed by selector.
  *
@@ -77,6 +79,36 @@ unsigned xfrm_dst_hash(xfrm_address_t *a
 	return 0;
 }
 
+static __inline__
+unsigned __xfrm4_spi_hash(xfrm_address_t *addr, u32 spi, u8 proto)
+{
+	unsigned h;
+	h = ntohl(addr->a4^spi^proto);
+	h = (h ^ (h>>10) ^ (h>>20)) % XFRM_DST_HSIZE;
+	return h;
+}
+
+static __inline__
+unsigned __xfrm6_spi_hash(xfrm_address_t *addr, u32 spi, u8 proto)
+{
+	unsigned h;
+	h = ntohl(addr->a6[2]^addr->a6[3]^spi^proto);
+	h = (h ^ (h>>10) ^ (h>>20)) % XFRM_DST_HSIZE;
+	return h;
+}
+
+static __inline__
+unsigned xfrm_spi_hash(xfrm_address_t *addr, u32 spi, u8 proto, unsigned short family)
+{
+	switch (family) {
+	case AF_INET:
+		return __xfrm4_spi_hash(addr, spi, proto);
+	case AF_INET6:
+		return __xfrm6_spi_hash(addr, spi, proto);
+	}
+	return 0;	/*XXX*/
+}
+
 DECLARE_WAIT_QUEUE_HEAD(km_waitq);
 EXPORT_SYMBOL(km_waitq);
 
-- 
1.4.2.rc2.g3e042

