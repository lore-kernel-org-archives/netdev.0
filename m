From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/12] net: sched: Simplify em_ipset_match
Date: Fri, 19 Jun 2015 19:17:44 +0200
Message-ID: <1434734269-4545-8-git-send-email-pablo@netfilter.org>
References: <1434734269-4545-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1434734269-4545-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eric W. Biederman" <ebiederm@xmission.com>

em->net is always set and always available, use it in preference
to dev_net(skb->dev).

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/sched/em_ipset.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/em_ipset.c b/net/sched/em_ipset.c
index a3d79c8..df0328b 100644
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
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
