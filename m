From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 15/15] neigh: Don't require a dst in neigh_resolve_output
Date: Mon, 02 Mar 2015 00:14:14 -0600
Message-ID: <87oaoc53k9.fsf_-_@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
	<20150227.162131.431559184124647735.davem@davemloft.net>
	<87mw3yg8da.fsf@x220.int.ebiederm.org>
	<20150301.230306.2023670900391030920.davem@davemloft.net>
	<871tl8dlxn.fsf@x220.int.ebiederm.org>
	<87lhjg9byo.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>,
	linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <87lhjg9byo.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sun, 01 Mar 2015 23:59:11 -0600")
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Having a dst helps a little bit for teql but is fundamentally
unnecessary and there are code paths where a dst is not available that
it would be nice to use the neighbour cache.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/core/neighbour.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index af72b863e968..0f48ea3affed 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1284,12 +1284,8 @@ static void neigh_hh_init(struct neighbour *n)
 
 int neigh_resolve_output(struct neighbour *neigh, struct sk_buff *skb)
 {
-	struct dst_entry *dst = skb_dst(skb);
 	int rc = 0;
 
-	if (!dst)
-		goto discard;
-
 	if (!neigh_event_send(neigh, skb)) {
 		int err;
 		struct net_device *dev = neigh->dev;
@@ -1312,8 +1308,6 @@ int neigh_resolve_output(struct neighbour *neigh, struct sk_buff *skb)
 	}
 out:
 	return rc;
-discard:
-	neigh_dbg(1, "%s: dst=%p neigh=%p\n", __func__, dst, neigh);
 out_kfree_skb:
 	rc = -EINVAL;
 	kfree_skb(skb);
-- 
2.2.1

