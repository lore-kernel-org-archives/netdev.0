From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 01/15] netfilter: Kill unused copies of RCV_SKB_FAIL
Date: Sun, 14 Jun 2015 22:12:59 -0500
Message-ID: <1434337993-6248-1-git-send-email-ebiederm@xmission.com>
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

This appears to have been a dead macro in both nfnetlink_log.c and
nfnetlink_queue_core.c since these pieces of code were added in 2005.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/nfnetlink_log.c        | 2 --
 net/netfilter/nfnetlink_queue_core.c | 2 --
 2 files changed, 4 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 4ef1fae8445e..4670821b569d 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -598,8 +598,6 @@ nla_put_failure:
 	return -1;
 }
 
-#define RCV_SKB_FAIL(err) do { netlink_ack(skb, nlh, (err)); return; } while (0)
-
 static struct nf_loginfo default_loginfo = {
 	.type =		NF_LOG_TYPE_ULOG,
 	.u = {
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 22a5ac76683e..700e31725223 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -806,8 +806,6 @@ nfqnl_dev_drop(struct net *net, int ifindex)
 	rcu_read_unlock();
 }
 
-#define RCV_SKB_FAIL(err) do { netlink_ack(skb, nlh, (err)); return; } while (0)
-
 static int
 nfqnl_rcv_dev_event(struct notifier_block *this,
 		    unsigned long event, void *ptr)
-- 
2.2.1

