From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 3/9] netfilter: conntrack: don't attempt to iterate over empty table
Date: Thu, 28 Apr 2016 19:13:42 +0200
Message-ID: <1461863628-23350-4-git-send-email-fw@strlen.de>
References: <1461863628-23350-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1461863628-23350-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Once we place all conntracks into same table iteration becomes more
costly because the table contains conntracks that we are not interested
in (belonging to other netns).

So don't bother scanning if the current namespace has no entries.

Signed-off-by: Florian Westphal <fw@strlen.de>
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
2.7.3

