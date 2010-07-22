From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] nf_nat_core: merge the same lines
Date: Thu, 22 Jul 2010 17:49:00 +0800
Message-ID: <1279792140-10445-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nf_nat_core: merge the same lines

proto->unique_tuple() will be called finally, if the previous calls fail. This
patch checks the false condition of (range->flags & IP_NAT_RANGE_PROTO_RANDOM)
instead to avoid duplicate line of code: proto->unique_tuple().

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/ipv4/netfilter/nf_nat_core.c |    9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)
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
