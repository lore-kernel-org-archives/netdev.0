From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/21] netfilter: ipset: Fix hashing for ipv6 sets
Date: Mon, 18 May 2015 18:25:16 +0200
Message-ID: <1431966324-4494-14-git-send-email-pablo@netfilter.org>
References: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44044 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932294AbbERQUw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2015 12:20:52 -0400
In-Reply-To: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergey Popovich <popovich_sergei@mail.ua>

HKEY_DATALEN remains defined after first inclusion
of ip_set_hash_gen.h, so it is incorrectly reused
for IPv6 code.

Undefine HKEY_DATALEN in ip_set_hash_gen.h at the end.

Also remove some useless defines of HKEY_DATALEN in
ip_set_hash_{ip{,mark,port},netiface}.c as ip_set_hash_gen.h
defines it correctly for such set types anyway.

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ua>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_hash_gen.h      |    2 ++
 net/netfilter/ipset/ip_set_hash_ip.c       |    1 -
 net/netfilter/ipset/ip_set_hash_ipmark.c   |    3 ---
 net/netfilter/ipset/ip_set_hash_ipport.c   |    3 ---
 net/netfilter/ipset/ip_set_hash_netiface.c |    1 -
 5 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index a043065..7b72209 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -1166,3 +1166,5 @@ IPSET_TOKEN(HTYPE, _create)(struct net *net, struct ip_set *set,
 	return 0;
 }
 #endif /* IP_SET_EMIT_CREATE */
+
+#undef HKEY_DATALEN
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index ee7a72b..54df48b 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -211,7 +211,6 @@ hash_ip6_data_next(struct hash_ip4_elem *next, const struct hash_ip6_elem *e)
 
 #undef MTYPE
 #undef HOST_MASK
-#undef HKEY_DATALEN
 
 #define MTYPE		hash_ip6
 #define HOST_MASK	128
diff --git a/net/netfilter/ipset/ip_set_hash_ipmark.c b/net/netfilter/ipset/ip_set_hash_ipmark.c
index 6ac7073..061e7e8 100644
--- a/net/netfilter/ipset/ip_set_hash_ipmark.c
+++ b/net/netfilter/ipset/ip_set_hash_ipmark.c
@@ -78,7 +78,6 @@ hash_ipmark4_data_next(struct hash_ipmark4_elem *next,
 
 #define MTYPE           hash_ipmark4
 #define HOST_MASK       32
-#define HKEY_DATALEN	sizeof(struct hash_ipmark4_elem)
 #include "ip_set_hash_gen.h"
 
 static int
@@ -207,11 +206,9 @@ hash_ipmark6_data_next(struct hash_ipmark4_elem *next,
 
 #undef MTYPE
 #undef HOST_MASK
-#undef HKEY_DATALEN
 
 #define MTYPE		hash_ipmark6
 #define HOST_MASK	128
-#define HKEY_DATALEN	sizeof(struct hash_ipmark6_elem)
 #define	IP_SET_EMIT_CREATE
 #include "ip_set_hash_gen.h"
 
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index a3117d4e..e58704e 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -85,7 +85,6 @@ hash_ipport4_data_next(struct hash_ipport4_elem *next,
 
 #define MTYPE           hash_ipport4
 #define HOST_MASK       32
-#define HKEY_DATALEN	sizeof(struct hash_ipport4_elem)
 #include "ip_set_hash_gen.h"
 
 static int
@@ -245,11 +244,9 @@ hash_ipport6_data_next(struct hash_ipport4_elem *next,
 
 #undef MTYPE
 #undef HOST_MASK
-#undef HKEY_DATALEN
 
 #define MTYPE		hash_ipport6
 #define HOST_MASK	128
-#define HKEY_DATALEN	sizeof(struct hash_ipport6_elem)
 #define	IP_SET_EMIT_CREATE
 #include "ip_set_hash_gen.h"
 
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index 07920b6..fe481f6 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -460,7 +460,6 @@ hash_netiface6_data_next(struct hash_netiface4_elem *next,
 
 #undef MTYPE
 #undef HOST_MASK
-#undef HKEY_DATALEN
 
 #define MTYPE		hash_netiface6
 #define HOST_MASK	128
-- 
1.7.10.4
