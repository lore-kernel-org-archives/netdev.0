From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 7/8] netfilter: nf_tables: fix wrong format in request_module()
Date: Sat,  5 Apr 2014 18:03:49 +0200
Message-ID: <1396713830-4009-8-git-send-email-pablo@netfilter.org>
References: <1396713830-4009-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1396713830-4009-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The intended format in request_module is %.*s instead of %*.s.

Reported-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 43ae487..3fd159d 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -152,8 +152,8 @@ nf_tables_chain_type_lookup(const struct nft_af_info *afi,
 #ifdef CONFIG_MODULES
 	if (autoload) {
 		nfnl_unlock(NFNL_SUBSYS_NFTABLES);
-		request_module("nft-chain-%u-%*.s", afi->family,
-			       nla_len(nla)-1, (const char *)nla_data(nla));
+		request_module("nft-chain-%u-%.*s", afi->family,
+			       nla_len(nla), (const char *)nla_data(nla));
 		nfnl_lock(NFNL_SUBSYS_NFTABLES);
 		type = __nf_tables_chain_type_lookup(afi->family, nla);
 		if (type != NULL)
-- 
1.7.10.4

