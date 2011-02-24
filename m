From: David Miller <davem@davemloft.net>
Subject: [PATCH 10/26] xfrm: Const'ify address args to hash helpers.
Date: Wed, 23 Feb 2011 23:13:20 -0800 (PST)
Message-ID: <20110223.231320.260084505.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37475
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932570Ab1BXHMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:12:44 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 18CA624C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:13:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_hash.h   |   32 +++++++++++++++++++-------------
 net/xfrm/xfrm_policy.c |    9 +++++++--
 2 files changed, 26 insertions(+), 15 deletions(-)

diff --git a/net/xfrm/xfrm_hash.h b/net/xfrm/xfrm_hash.h
index 8e69533..7199d78 100644
--- a/net/xfrm/xfrm_hash.h
+++ b/net/xfrm/xfrm_hash.h
@@ -4,29 +4,32 @@
 #include <linux/xfrm.h>
 #include <linux/socket.h>
 
-static inline unsigned int __xfrm4_addr_hash(xfrm_address_t *addr)
+static inline unsigned int __xfrm4_addr_hash(const xfrm_address_t *addr)
 {
 	return ntohl(addr->a4);
 }
 
-static inline unsigned int __xfrm6_addr_hash(xfrm_address_t *addr)
+static inline unsigned int __xfrm6_addr_hash(const xfrm_address_t *addr)
 {
 	return ntohl(addr->a6[2] ^ addr->a6[3]);
 }
 
-static inline unsigned int __xfrm4_daddr_saddr_hash(xfrm_address_t *daddr, xfrm_address_t *saddr)
+static inline unsigned int __xfrm4_daddr_saddr_hash(const xfrm_address_t *daddr,
+						    const xfrm_address_t *saddr)
 {
 	u32 sum = (__force u32)daddr->a4 + (__force u32)saddr->a4;
 	return ntohl((__force __be32)sum);
 }
 
-static inline unsigned int __xfrm6_daddr_saddr_hash(xfrm_address_t *daddr, xfrm_address_t *saddr)
+static inline unsigned int __xfrm6_daddr_saddr_hash(const xfrm_address_t *daddr,
+						    const xfrm_address_t *saddr)
 {
 	return ntohl(daddr->a6[2] ^ daddr->a6[3] ^
 		     saddr->a6[2] ^ saddr->a6[3]);
 }
 
-static inline unsigned int __xfrm_dst_hash(xfrm_address_t *daddr, xfrm_address_t *saddr,
+static inline unsigned int __xfrm_dst_hash(const xfrm_address_t *daddr,
+					   const xfrm_address_t *saddr,
 					   u32 reqid, unsigned short family,
 					   unsigned int hmask)
 {
@@ -42,8 +45,8 @@ static inline unsigned int __xfrm_dst_hash(xfrm_address_t *daddr, xfrm_address_t
 	return (h ^ (h >> 16)) & hmask;
 }
 
-static inline unsigned __xfrm_src_hash(xfrm_address_t *daddr,
-				       xfrm_address_t *saddr,
+static inline unsigned __xfrm_src_hash(const xfrm_address_t *daddr,
+				       const xfrm_address_t *saddr,
 				       unsigned short family,
 				       unsigned int hmask)
 {
@@ -60,8 +63,8 @@ static inline unsigned __xfrm_src_hash(xfrm_address_t *daddr,
 }
 
 static inline unsigned int
-__xfrm_spi_hash(xfrm_address_t *daddr, __be32 spi, u8 proto, unsigned short family,
-		unsigned int hmask)
+__xfrm_spi_hash(const xfrm_address_t *daddr, __be32 spi, u8 proto,
+		unsigned short family, unsigned int hmask)
 {
 	unsigned int h = (__force u32)spi ^ proto;
 	switch (family) {
@@ -80,10 +83,11 @@ static inline unsigned int __idx_hash(u32 index, unsigned int hmask)
 	return (index ^ (index >> 8)) & hmask;
 }
 
-static inline unsigned int __sel_hash(struct xfrm_selector *sel, unsigned short family, unsigned int hmask)
+static inline unsigned int __sel_hash(const struct xfrm_selector *sel,
+				      unsigned short family, unsigned int hmask)
 {
-	xfrm_address_t *daddr = &sel->daddr;
-	xfrm_address_t *saddr = &sel->saddr;
+	const xfrm_address_t *daddr = &sel->daddr;
+	const xfrm_address_t *saddr = &sel->saddr;
 	unsigned int h = 0;
 
 	switch (family) {
@@ -107,7 +111,9 @@ static inline unsigned int __sel_hash(struct xfrm_selector *sel, unsigned short
 	return h & hmask;
 }
 
-static inline unsigned int __addr_hash(xfrm_address_t *daddr, xfrm_address_t *saddr, unsigned short family, unsigned int hmask)
+static inline unsigned int __addr_hash(const xfrm_address_t *daddr,
+				       const xfrm_address_t *saddr,
+				       unsigned short family, unsigned int hmask)
 {
 	unsigned int h = 0;
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index eb76da7..0770b3a 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -311,7 +311,9 @@ static inline unsigned int idx_hash(struct net *net, u32 index)
 	return __idx_hash(index, net->xfrm.policy_idx_hmask);
 }
 
-static struct hlist_head *policy_hash_bysel(struct net *net, struct xfrm_selector *sel, unsigned short family, int dir)
+static struct hlist_head *policy_hash_bysel(struct net *net,
+					    const struct xfrm_selector *sel,
+					    unsigned short family, int dir)
 {
 	unsigned int hmask = net->xfrm.policy_bydst[dir].hmask;
 	unsigned int hash = __sel_hash(sel, family, hmask);
@@ -321,7 +323,10 @@ static struct hlist_head *policy_hash_bysel(struct net *net, struct xfrm_selecto
 		net->xfrm.policy_bydst[dir].table + hash);
 }
 
-static struct hlist_head *policy_hash_direct(struct net *net, xfrm_address_t *daddr, xfrm_address_t *saddr, unsigned short family, int dir)
+static struct hlist_head *policy_hash_direct(struct net *net,
+					     const xfrm_address_t *daddr,
+					     const xfrm_address_t *saddr,
+					     unsigned short family, int dir)
 {
 	unsigned int hmask = net->xfrm.policy_bydst[dir].hmask;
 	unsigned int hash = __addr_hash(daddr, saddr, family, hmask);
-- 
1.7.4.1

