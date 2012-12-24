From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH 25/29] net/netfilter: rename random32() and net_random() to prandom_u32()
Date: Mon, 24 Dec 2012 11:14:12 +0900
Message-ID: <1356315256-6572-26-git-send-email-akinobu.mita@gmail.com>
References: <1356315256-6572-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1356315256-6572-1-git-send-email-akinobu.mita@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use more preferable function name which implies using a pseudo-random
number generator.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org
Cc: netfilter@vger.kernel.org
Cc: coreteam@netfilter.org
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 net/netfilter/ipvs/ip_vs_conn.c   | 2 +-
 net/netfilter/nf_conntrack_core.c | 4 ++--
 net/netfilter/xt_statistic.c      | 2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 30e764a..870dff6 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1200,7 +1200,7 @@ void ip_vs_random_dropentry(struct net *net)
 	 * Randomly scan 1/32 of the whole table every second
 	 */
 	for (idx = 0; idx < (ip_vs_conn_tab_size>>5); idx++) {
-		unsigned int hash = net_random() & ip_vs_conn_tab_mask;
+		unsigned int hash = prandom_u32() & ip_vs_conn_tab_mask;
 		struct hlist_node *n;
 
 		/*
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 08cdc71..a8f5c7a 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -263,7 +263,7 @@ static void death_by_event(unsigned long ul_conntrack)
 	if (nf_conntrack_event(IPCT_DESTROY, ct) < 0) {
 		/* bad luck, let's retry again */
 		ecache->timeout.expires = jiffies +
-			(random32() % net->ct.sysctl_events_retry_timeout);
+			(prandom_u32() % net->ct.sysctl_events_retry_timeout);
 		add_timer(&ecache->timeout);
 		return;
 	}
@@ -282,7 +282,7 @@ void nf_ct_dying_timeout(struct nf_conn *ct)
 	/* set a new timer to retry event delivery */
 	setup_timer(&ecache->timeout, death_by_event, (unsigned long)ct);
 	ecache->timeout.expires = jiffies +
-		(random32() % net->ct.sysctl_events_retry_timeout);
+		(prandom_u32() % net->ct.sysctl_events_retry_timeout);
 	add_timer(&ecache->timeout);
 }
 EXPORT_SYMBOL_GPL(nf_ct_dying_timeout);
diff --git a/net/netfilter/xt_statistic.c b/net/netfilter/xt_statistic.c
index 4fe4fb4..11de55e 100644
--- a/net/netfilter/xt_statistic.c
+++ b/net/netfilter/xt_statistic.c
@@ -37,7 +37,7 @@ statistic_mt(const struct sk_buff *skb, struct xt_action_param *par)
 
 	switch (info->mode) {
 	case XT_STATISTIC_MODE_RANDOM:
-		if ((net_random() & 0x7FFFFFFF) < info->u.random.probability)
+		if ((prandom_u32() & 0x7FFFFFFF) < info->u.random.probability)
 			ret = !ret;
 		break;
 	case XT_STATISTIC_MODE_NTH:
-- 
1.7.11.7
