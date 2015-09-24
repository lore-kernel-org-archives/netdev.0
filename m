From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 50/84] ipvs: Pass ipvs not net to estimation_timer
Date: Thu, 24 Sep 2015 09:52:35 +0900
Message-ID: <1443055989-1306-51-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Simon Horman <horms@verge.net.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:44941 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932730AbbIXAy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 20:54:57 -0400
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_est.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 638a301f7ee4..c86dc456c8f4 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -102,10 +102,8 @@ static void estimation_timer(unsigned long arg)
 	struct ip_vs_estimator *e;
 	struct ip_vs_stats *s;
 	u64 rate;
-	struct net *net = (struct net *)arg;
-	struct netns_ipvs *ipvs;
+	struct netns_ipvs *ipvs = (struct netns_ipvs *)arg;
 
-	ipvs = net_ipvs(net);
 	spin_lock(&ipvs->est_lock);
 	list_for_each_entry(e, &ipvs->est_list, list) {
 		s = container_of(e, struct ip_vs_stats, est);
@@ -196,7 +194,7 @@ int __net_init ip_vs_estimator_net_init(struct net *net)
 
 	INIT_LIST_HEAD(&ipvs->est_list);
 	spin_lock_init(&ipvs->est_lock);
-	setup_timer(&ipvs->est_timer, estimation_timer, (unsigned long)net);
+	setup_timer(&ipvs->est_timer, estimation_timer, (unsigned long)ipvs);
 	mod_timer(&ipvs->est_timer, jiffies + 2 * HZ);
 	return 0;
 }
-- 
2.1.4
