From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/25] netfilter: ipset: Removed invalid IPSET_ATTR_MARKMASK validation
Date: Wed, 10 Sep 2014 17:10:21 +0200
Message-ID: <1410361842-4656-5-git-send-email-pablo@netfilter.org>
References: <1410361842-4656-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1410361842-4656-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vytas Dauksa <vytas.dauksa@smoothwall.net>

Markmask is an u32, hence it can't be greater then 4294967295 ( i.e.
0xffffffff ). This was causing smatch warning:
 net/netfilter/ipset/ip_set_hash_gen.h:1084 hash_ipmark_create() warn:
 impossible condition '(markmask > 4294967295) => (0-u32max > u32max)'

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_hash_gen.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 61c7fb0..0398a92 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -1093,7 +1093,7 @@ IPSET_TOKEN(HTYPE, _create)(struct net *net, struct ip_set *set,
 	if (tb[IPSET_ATTR_MARKMASK]) {
 		markmask = ntohl(nla_get_u32(tb[IPSET_ATTR_MARKMASK]));
 
-		if ((markmask > 4294967295u) || markmask == 0)
+		if (markmask == 0)
 			return -IPSET_ERR_INVALID_MARKMASK;
 	}
 #endif
-- 
1.7.10.4

