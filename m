From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 08/15] tc: Simplify em_ipset_match
Date: Sun, 14 Jun 2015 22:13:06 -0500
Message-ID: <1434337993-6248-8-git-send-email-ebiederm@xmission.com>
References: <87616ppt3h.fsf@x220.int.ebiederm.org>
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
In-Reply-To: <87616ppt3h.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

em->net is always set and always available, use it in preference
to dev_net(skb->dev).

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/sched/em_ipset.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/em_ipset.c b/net/sched/em_ipset.c
index a3d79c8bf3b8..df0328ba6a48 100644
--- a/net/sched/em_ipset.c
+++ b/net/sched/em_ipset.c
@@ -92,8 +92,8 @@ static int em_ipset_match(struct sk_buff *skb, struct tcf_ematch *em,
 
 	rcu_read_lock();
 
-	if (dev && skb->skb_iif)
-		indev = dev_get_by_index_rcu(dev_net(dev), skb->skb_iif);
+	if (skb->skb_iif)
+		indev = dev_get_by_index_rcu(em->net, skb->skb_iif);
 
 	acpar.in      = indev ? indev : dev;
 	acpar.out     = dev;
-- 
2.2.1

