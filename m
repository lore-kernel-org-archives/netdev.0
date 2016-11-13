From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 30/39] netfilter: ipset: Make sure element data size is a multiple of u32
Date: Sun, 13 Nov 2016 23:25:24 +0100
Message-ID: <1479075933-4491-31-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Data for hashing required to be array of u32. Make sure that
element data always multiple of u32.

Ported from a patch proposed by Sergey Popovich <popovich_sergei@mail.ua>.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_hash_gen.h | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 6c88c20ae1d4..34f115f874ab 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -260,8 +260,14 @@ htable_bits(u32 hashsize)
 #endif
 
 #define HKEY(data, initval, htable_bits)			\
-(jhash2((u32 *)(data), HKEY_DATALEN / sizeof(u32), initval)	\
-	& jhash_mask(htable_bits))
+({								\
+	const u32 *__k = (const u32 *)data;			\
+	u32 __l = HKEY_DATALEN / sizeof(u32);			\
+								\
+	BUILD_BUG_ON(HKEY_DATALEN % sizeof(u32) != 0);		\
+								\
+	jhash2(__k, __l, initval) & jhash_mask(htable_bits);	\
+})
 
 #ifndef htype
 #ifndef HTYPE
-- 
2.1.4

