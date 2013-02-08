From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH net-next] cxgb4vf: Fix extraction of cpl_rx_pkt from the response queue descriptor
Date: Fri,  8 Feb 2013 18:19:51 +0530
Message-ID: <1360327791-21704-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, divy@chelsio.com, dm@chelsio.com,
	leedom@chelsio.com, abhishek@chelsio.com,
	Vipul Pandya <vipul@chelsio.com>,
	Jay Hernandez <jay@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:29496 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946422Ab3BHMzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 07:55:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was preventing GRO and RxCheckSum offload to happen.

Signed-off-by: Jay Hernandez <jay@chelsio.com>
Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 92170d5..9e8841e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -1501,7 +1501,7 @@ int t4vf_ethrx_handler(struct sge_rspq *rspq, const __be64 *rsp,
 		       const struct pkt_gl *gl)
 {
 	struct sk_buff *skb;
-	const struct cpl_rx_pkt *pkt = (void *)&rsp[1];
+	const struct cpl_rx_pkt *pkt = (void *)rsp;
 	bool csum_ok = pkt->csum_calc && !pkt->err_vec;
 	struct sge_eth_rxq *rxq = container_of(rspq, struct sge_eth_rxq, rspq);
 
-- 
1.7.1
