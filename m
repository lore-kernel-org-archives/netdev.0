From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH -v2 22/26] net/netfilter: rename random32() to prandom_u32()
Date: Thu,  3 Jan 2013 21:19:18 +0900
Message-ID: <1357215562-6288-23-git-send-email-akinobu.mita@gmail.com>
References: <1357215562-6288-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1357215562-6288-1-git-send-email-akinobu.mita@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
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

* Change from v1
- leave net_random() callers as-is because that is a useful indirection

 net/netfilter/nf_conntrack_core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

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
-- 
1.7.11.7

