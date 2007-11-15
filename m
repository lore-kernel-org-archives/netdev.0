From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH] chelsio - Fix skb->dev setting
Date: Thu, 15 Nov 2007 03:38:57 -0800
Message-ID: <20071115113857.10170.87392.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:9290 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755526AbXKOMcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 07:32:52 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

eth_type_trans() now sets skb->dev. 
Access skb->def after it gets set.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/chelsio/sge.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index ffa7e64..4436662 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1379,11 +1379,11 @@ static void sge_rx(struct sge *sge, struct freelQ *fl, unsigned int len)
 	}
 	__skb_pull(skb, sizeof(*p));
 
-	skb->dev->last_rx = jiffies;
 	st = per_cpu_ptr(sge->port_stats[p->iff], smp_processor_id());
 	st->rx_packets++;
 
 	skb->protocol = eth_type_trans(skb, adapter->port[p->iff].dev);
+	skb->dev->last_rx = jiffies;
 	if ((adapter->flags & RX_CSUM_ENABLED) && p->csum == 0xffff &&
 	    skb->protocol == htons(ETH_P_IP) &&
 	    (skb->data[9] == IPPROTO_TCP || skb->data[9] == IPPROTO_UDP)) {
