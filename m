From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 31/43] netfilter: nf_tables: adapt it to pernet hooks
Date: Wed, 17 Jun 2015 10:28:40 -0500
Message-ID: <1434554932-4552-31-git-send-email-ebiederm@xmission.com>
References: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Cc: <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Since pernet hooks, we need to register the hook for each netnamespace space.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Eric W Biederman <ebiederm@xmission.com>
---
 net/netfilter/nf_tables_api.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index ce996362083f..ed9ef9925166 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -130,20 +130,24 @@ static void nft_trans_destroy(struct nft_trans *trans)
 int nft_register_basechain(struct nft_base_chain *basechain,
 			   unsigned int hook_nops)
 {
+	struct net *net = read_pnet(&basechain->pnet);
+
 	if (basechain->flags & NFT_BASECHAIN_DISABLED)
 		return 0;
 
-	return nf_register_hooks(&init_net, basechain->ops, hook_nops);
+	return nf_register_hooks(net, basechain->ops, hook_nops);
 }
 EXPORT_SYMBOL_GPL(nft_register_basechain);
 
 void nft_unregister_basechain(struct nft_base_chain *basechain,
 			      unsigned int hook_nops)
 {
+	struct net *net = read_pnet(&basechain->pnet);
+
 	if (basechain->flags & NFT_BASECHAIN_DISABLED)
 		return;
 
-	nf_unregister_hooks(&init_net, basechain->ops, hook_nops);
+	nf_unregister_hooks(net, basechain->ops, hook_nops);
 }
 EXPORT_SYMBOL_GPL(nft_unregister_basechain);
 
-- 
2.2.1

