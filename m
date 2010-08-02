From: kaber@trash.net
Subject: [PATCH 15/28] netfilter: nf_nat_core: merge the same lines
Date: Mon,  2 Aug 2010 21:57:32 +0200
Message-ID: <1280779065-9333-16-git-send-email-kaber@trash.net>
References: <1280779065-9333-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1280779065-9333-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Changli Gao <xiaosuo@gmail.com>

proto->unique_tuple() will be called finally, if the previous calls fail. This
patch checks the false condition of (range->flags &IP_NAT_RANGE_PROTO_RANDOM)
instead to avoid duplicate line of code: proto->unique_tuple().

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/nf_nat_core.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index c7719b2..037a3a6 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -261,14 +261,9 @@ get_unique_tuple(struct nf_conntrack_tuple *tuple,
 	rcu_read_lock();
 	proto = __nf_nat_proto_find(orig_tuple->dst.protonum);
 
-	/* Change protocol info to have some randomization */
-	if (range->flags & IP_NAT_RANGE_PROTO_RANDOM) {
-		proto->unique_tuple(tuple, range, maniptype, ct);
-		goto out;
-	}
-
 	/* Only bother mapping if it's not already in range and unique */
-	if ((!(range->flags & IP_NAT_RANGE_PROTO_SPECIFIED) ||
+	if (!(range->flags & IP_NAT_RANGE_PROTO_RANDOM) &&
+	    (!(range->flags & IP_NAT_RANGE_PROTO_SPECIFIED) ||
 	     proto->in_range(tuple, maniptype, &range->min, &range->max)) &&
 	    !nf_nat_used_tuple(tuple, ct))
 		goto out;
-- 
1.7.1

