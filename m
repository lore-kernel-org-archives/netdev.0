From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH net-next] cxgb4vf: Fix VLAN extraction counter increment
Date: Tue, 12 Feb 2013 16:06:21 +0530
Message-ID: <1360665381-17033-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, divy@chelsio.com, dm@chelsio.com,
	leedom@chelsio.com, abhishek@chelsio.com,
	Vipul Pandya <vipul@chelsio.com>,
	Santosh Rastapur <santosh@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:30366 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932529Ab3BLKln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 05:41:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Santosh Rastapur <santosh@chelsio.com>
Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 9e8841e..9488032 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -1477,8 +1477,10 @@ static void do_gro(struct sge_eth_rxq *rxq, const struct pkt_gl *gl,
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb_record_rx_queue(skb, rxq->rspq.idx);
 
-	if (pkt->vlan_ex)
+	if (pkt->vlan_ex) {
 		__vlan_hwaccel_put_tag(skb, be16_to_cpu(pkt->vlan));
+		rxq->stats.vlan_ex++;
+	}
 	ret = napi_gro_frags(&rxq->rspq.napi);
 
 	if (ret == GRO_HELD)
-- 
1.7.1
