From: pablo@netfilter.org
Subject: [PATCH] netfilter: ipset: fix netiface set name overflow
Date: Tue, 27 Nov 2012 02:03:05 +0100
Message-ID: <1353978185-3564-2-git-send-email-pablo@netfilter.org>
References: <1353978185-3564-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1353978185-3564-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

attribute is copied to IFNAMSIZ-size stack variable,
but IFNAMSIZ is smaller than IPSET_MAXNAMELEN.

Fortunately nfnetlink needs CAP_NET_ADMIN.

Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_hash_netiface.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index b9a6338..45a1014 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -793,7 +793,7 @@ static struct ip_set_type hash_netiface_type __read_mostly = {
 		[IPSET_ATTR_IP]		= { .type = NLA_NESTED },
 		[IPSET_ATTR_IP_TO]	= { .type = NLA_NESTED },
 		[IPSET_ATTR_IFACE]	= { .type = NLA_NUL_STRING,
-					    .len = IPSET_MAXNAMELEN - 1 },
+					    .len  = IFNAMSIZ - 1 },
 		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
 		[IPSET_ATTR_CIDR]	= { .type = NLA_U8 },
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
-- 
1.7.10.4

