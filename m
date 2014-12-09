From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCH net-next] sunvnet: fix incorrect rcu_read_unlock() in vnet_start_xmit()
Date: Mon, 08 Dec 2014 21:46:09 -0500
Message-ID: <54866271.1020005@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Rashmi Narasimhan <rashmi.narasimhan@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:42641 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756195AbaLICqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 21:46:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes an extra rcu_read_unlock() on an allocation failure
in vnet_skb_shape(). The needed rcu_read_unlock() is already done in
the out_dropped label.

Reported-by: Rashmi Narasimhan <rashmi.narasimhan@oracle.com>
Signed-off-by: David L Stevens <david.stevens@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index b883add..36fdf52 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -1317,10 +1317,8 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	skb = vnet_skb_shape(skb, 2);
 
-	if (unlikely(!skb)) {
-		rcu_read_unlock();
+	if (unlikely(!skb))
 		goto out_dropped;
-	}
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		vnet_fullcsum(skb);
-- 
1.7.1
