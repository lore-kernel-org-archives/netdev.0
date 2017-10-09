From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/12] netfilter: nf_tables: do not dump chain counters if not enabled
Date: Mon,  9 Oct 2017 18:25:43 +0200
Message-ID: <1507566346-32553-10-git-send-email-pablo@netfilter.org>
References: <1507566346-32553-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1507566346-32553-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chain counters are only enabled on demand since 9f08ea848117, skip them
when dumping them via netlink.

Fixes: 9f08ea848117 ("netfilter: nf_tables: keep chain counters away from hot path")
Reported-by: Johny Mattsson <johny.mattsson+kernel@gmail.com>
Tested-by: Johny Mattsson <johny.mattsson+kernel@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 34adedcb239e..64e1ee091225 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1048,7 +1048,7 @@ static int nf_tables_fill_chain_info(struct sk_buff *skb, struct net *net,
 		if (nla_put_string(skb, NFTA_CHAIN_TYPE, basechain->type->name))
 			goto nla_put_failure;
 
-		if (nft_dump_stats(skb, nft_base_chain(chain)->stats))
+		if (basechain->stats && nft_dump_stats(skb, basechain->stats))
 			goto nla_put_failure;
 	}
 
-- 
2.1.4

