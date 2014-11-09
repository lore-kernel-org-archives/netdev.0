From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH 3/3 net-next] sunvnet: Add missing rcu_read_unlock() in
 vnet_start_xmit
Date: Sat, 8 Nov 2014 20:42:20 -0500
Message-ID: <20141109014220.GE31217@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, david.stevens@oracle.com
To: davem@davemloft.net, sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:23163 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401AbaKIBmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Nov 2014 20:42:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The out_dropped label will only do rcu_read_unlock for non-null port.
So add the missing rcu_read_unlock() when bailing due to non-null port.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 826b385..55d66c9 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -981,8 +981,10 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	rcu_read_lock();
 	port = __tx_port_find(vp, skb);
-	if (unlikely(!port))
+	if (unlikely(!port)) {
+		rcu_read_unlock();
 		goto out_dropped;
+	}
 
 	if (skb->len > port->rmtu) {
 		unsigned long localmtu = port->rmtu - ETH_HLEN;
-- 
1.8.4.2
