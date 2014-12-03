From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/12] netfilter: ipset: Indicate when /0 networks are supported
Date: Wed,  3 Dec 2014 13:55:39 +0100
Message-ID: <1417611342-25257-10-git-send-email-pablo@netfilter.org>
References: <1417611342-25257-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48792 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752461AbaLCMxu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 07:53:50 -0500
In-Reply-To: <1417611342-25257-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_hash_gen.h      |    2 +-
 net/netfilter/ipset/ip_set_hash_netiface.c |    1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index a12ee04..9428fa5 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -156,7 +156,7 @@ hbucket_elem_add(struct hbucket *n, u8 ahash_max, size_t dsize)
 
 #define SET_HOST_MASK(family)	(family == AF_INET ? 32 : 128)
 
-#ifdef IP_SET_HASH_WITH_MULTI
+#ifdef IP_SET_HASH_WITH_NET0
 #define NLEN(family)		(SET_HOST_MASK(family) + 1)
 #else
 #define NLEN(family)		SET_HOST_MASK(family)
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index 35dd358..758b002 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -115,6 +115,7 @@ iface_add(struct rb_root *root, const char **iface)
 #define IP_SET_HASH_WITH_NETS
 #define IP_SET_HASH_WITH_RBTREE
 #define IP_SET_HASH_WITH_MULTI
+#define IP_SET_HASH_WITH_NET0
 
 #define STREQ(a, b)	(strcmp(a, b) == 0)
 
-- 
1.7.10.4
