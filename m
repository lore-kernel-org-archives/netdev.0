From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 43/43] netfilter: Skip unnecessary calls to synchronize_net
Date: Wed, 17 Jun 2015 10:28:52 -0500
Message-ID: <1434554932-4552-43-git-send-email-ebiederm@xmission.com>
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

From: Eric W Biederman <ebiederm@xmission.com>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/core.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 95456c09cf69..1b4eadc9c030 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -134,7 +134,9 @@ void nf_unregister_hook(struct net *net, const struct nf_hook_ops *reg)
 #ifdef HAVE_JUMP_LABEL
 	static_key_slow_dec(&nf_hooks_needed[reg->pf][reg->hooknum]);
 #endif
-	synchronize_net();
+	/* Don't wait if there are no packets in flight */
+	if (net->loopback_dev)
+		synchronize_net();
 	kfree(elem);
 }
 EXPORT_SYMBOL(nf_unregister_hook);
-- 
2.2.1

