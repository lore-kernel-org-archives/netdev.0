From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [XFRM] Kill unused flow_hash
Date: Tue, 17 Aug 2004 11:35:01 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040817013501.GA21685@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0OAP2g/MAC+5xKAE"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This patch removes a left-over from the days when the flow cache lived
in xfrm_policy.c.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/net/xfrm.h 1.65 vs edited =====
--- 1.65/include/net/xfrm.h	2004-08-14 20:59:43 +10:00
+++ edited/include/net/xfrm.h	2004-08-17 11:20:39 +10:00
@@ -304,47 +304,6 @@
 extern int xfrm_unregister_km(struct xfrm_mgr *km);
 
 
-#define XFRM_FLOWCACHE_HASH_SIZE	1024
-
-static inline u32 __flow_hash4(struct flowi *fl)
-{
-	u32 hash = fl->fl4_src ^ fl->fl_ip_sport;
-
-	hash = ((hash & 0xF0F0F0F0) >> 4) | ((hash & 0x0F0F0F0F) << 4);
-
-	hash ^= fl->fl4_dst ^ fl->fl_ip_dport;
-	hash ^= (hash >> 10);
-	hash ^= (hash >> 20);
-	return hash & (XFRM_FLOWCACHE_HASH_SIZE-1);
-}
-
-static inline u32 __flow_hash6(struct flowi *fl)
-{
-	u32 hash = fl->fl6_src.s6_addr32[2] ^
-		   fl->fl6_src.s6_addr32[3] ^ 
-		   fl->fl_ip_sport;
-
-	hash = ((hash & 0xF0F0F0F0) >> 4) | ((hash & 0x0F0F0F0F) << 4);
-
-	hash ^= fl->fl6_dst.s6_addr32[2] ^
-		fl->fl6_dst.s6_addr32[3] ^ 
-		fl->fl_ip_dport;
-	hash ^= (hash >> 10);
-	hash ^= (hash >> 20);
-	return hash & (XFRM_FLOWCACHE_HASH_SIZE-1);
-}
-
-static inline u32 flow_hash(struct flowi *fl, unsigned short family)
-{
-	switch (family) {
-	case AF_INET:
-		return __flow_hash4(fl);
-	case AF_INET6:
-		return __flow_hash6(fl);
-	}
-	return 0;	/*XXX*/
-}
-
 extern struct xfrm_policy *xfrm_policy_list[XFRM_POLICY_MAX*2];
 
 static inline void xfrm_pol_hold(struct xfrm_policy *policy)

--0OAP2g/MAC+5xKAE--
