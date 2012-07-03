From: David Miller <davem@davemloft.net>
Subject: [PATCH 12/19] neigh: Convert over to dst_neigh_lookup_skb().
Date: Tue, 03 Jul 2012 02:46:44 -0700 (PDT)
Message-ID: <20120703.024644.638173463391088464.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36847 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756066Ab2GCJqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 05:46:44 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 6B10D584120
	for <netdev@vger.kernel.org>; Tue,  3 Jul 2012 02:46:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/neighbour.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index a793af9..eb3efdc 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1202,9 +1202,15 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
 
 			rcu_read_lock();
 			/* On shaper/eql skb->dst->neighbour != neigh :( */
-			if (dst && (n2 = dst_get_neighbour_noref(dst)) != NULL)
-				n1 = n2;
+			n2 = NULL;
+			if (dst) {
+				n2 = dst_neigh_lookup_skb(dst, skb);
+				if (n2)
+					n1 = n2;
+			}
 			n1->output(n1, skb);
+			if (n2)
+				neigh_release(n2);
 			rcu_read_unlock();
 
 			write_lock_bh(&neigh->lock);
-- 
1.7.10
