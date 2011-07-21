From: kaber@trash.net
Subject: [PATCH 6/8] netfilter: ipset: make possible to hash some part of the data element only
Date: Thu, 21 Jul 2011 12:17:54 +0200
Message-ID: <1311243476-18236-7-git-send-email-kaber@trash.net>
References: <1311243476-18236-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34524 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752118Ab1GUKSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 06:18:03 -0400
In-Reply-To: <1311243476-18236-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/ipset/ip_set_ahash.h |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set_ahash.h b/include/linux/netfilter/ipset/ip_set_ahash.h
index c5b06aa..42b7d25 100644
--- a/include/linux/netfilter/ipset/ip_set_ahash.h
+++ b/include/linux/netfilter/ipset/ip_set_ahash.h
@@ -211,12 +211,16 @@ ip_set_hash_destroy(struct ip_set *set)
 	set->data = NULL;
 }
 
-#define HKEY(data, initval, htable_bits)				 \
-(jhash2((u32 *)(data), sizeof(struct type_pf_elem)/sizeof(u32), initval) \
-	& jhash_mask(htable_bits))
-
 #endif /* _IP_SET_AHASH_H */
 
+#ifndef HKEY_DATALEN
+#define HKEY_DATALEN	sizeof(struct type_pf_elem)
+#endif
+
+#define HKEY(data, initval, htable_bits)			\
+(jhash2((u32 *)(data), HKEY_DATALEN/sizeof(u32), initval)	\
+	& jhash_mask(htable_bits))
+
 #define CONCAT(a, b, c)		a##b##c
 #define TOKEN(a, b, c)		CONCAT(a, b, c)
 
@@ -1054,6 +1058,8 @@ type_pf_gc_init(struct ip_set *set)
 		 IPSET_GC_PERIOD(h->timeout));
 }
 
+#undef HKEY_DATALEN
+#undef HKEY
 #undef type_pf_data_equal
 #undef type_pf_data_isnull
 #undef type_pf_data_copy
-- 
1.7.2.3

