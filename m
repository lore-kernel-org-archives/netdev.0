From: David Miller <davem@davemloft.net>
Subject: [PATCH 08/19] qeth: Convert over to dst_neigh_lookup_skb().
Date: Tue, 03 Jul 2012 02:46:25 -0700 (PDT)
Message-ID: <20120703.024625.385551643240143384.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36831 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932113Ab2GCJq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 05:46:26 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id ED4C358411F
	for <netdev@vger.kernel.org>; Tue,  3 Jul 2012 02:46:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/s390/net/qeth_l3_main.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 7be5e97..73ac63d 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2700,10 +2700,11 @@ int inline qeth_l3_get_cast_type(struct qeth_card *card, struct sk_buff *skb)
 	rcu_read_lock();
 	dst = skb_dst(skb);
 	if (dst)
-		n = dst_get_neighbour_noref(dst);
+		n = dst_neigh_lookup_skb(dst, skb);
 	if (n) {
 		cast_type = n->type;
 		rcu_read_unlock();
+		neigh_release(n);
 		if ((cast_type == RTN_BROADCAST) ||
 		    (cast_type == RTN_MULTICAST) ||
 		    (cast_type == RTN_ANYCAST))
-- 
1.7.10
