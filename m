From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/36] netfilter: conntrack: don't attempt to iterate over empty table
Date: Mon,  9 May 2016 20:46:35 +0200
Message-ID: <1462819614-5402-18-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Once we place all conntracks into same table iteration becomes more
costly because the table contains conntracks that we are not interested
in (belonging to other netns).

So don't bother scanning if the current namespace has no entries.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 29fa08b..f2e75a5 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1428,6 +1428,9 @@ void nf_ct_iterate_cleanup(struct net *net,
 
 	might_sleep();
 
+	if (atomic_read(&net->ct.count) == 0)
+		return;
+
 	while ((ct = get_next_corpse(net, iter, data, &bucket)) != NULL) {
 		/* Time to push up daises... */
 		if (del_timer(&ct->timeout))
-- 
2.1.4

