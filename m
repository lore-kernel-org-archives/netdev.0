From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] be2net: use shift instead of expensive divide
Date: Tue, 29 Aug 2017 11:18:39 +0800
Message-ID: <1503976719-3063-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: sathya.perla@broadcom.com, ajit.khaparde@broadcom.com,
        sriharsha.basavapatna@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:57432 "EHLO
        cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751213AbdH2DTC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 23:19:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace shift instead of expensive divide.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 319eee3..e06094f 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2455,7 +2455,7 @@ static struct be_rx_compl_info *be_rx_compl_get(struct be_rx_obj *rxo)
 
 	/* For checking the valid bit it is Ok to use either definition as the
 	 * valid bit is at the same position in both v0 and v1 Rx compl */
-	if (compl->dw[offsetof(struct amap_eth_rx_compl_v1, valid) / 32] == 0)
+	if (compl->dw[offsetof(struct amap_eth_rx_compl_v1, valid) >> 5] == 0)
 		return NULL;
 
 	rmb();
@@ -2486,7 +2486,7 @@ static struct be_rx_compl_info *be_rx_compl_get(struct be_rx_obj *rxo)
 	}
 
 	/* As the compl has been parsed, reset it; we wont touch it again */
-	compl->dw[offsetof(struct amap_eth_rx_compl_v1, valid) / 32] = 0;
+	compl->dw[offsetof(struct amap_eth_rx_compl_v1, valid) >> 5] = 0;
 
 	queue_tail_inc(&rxo->cq);
 	return rxcp;
@@ -2590,7 +2590,7 @@ static struct be_tx_compl_info *be_tx_compl_get(struct be_tx_obj *txo)
 	struct be_tx_compl_info *txcp = &txo->txcp;
 	struct be_eth_tx_compl *compl = queue_tail_node(tx_cq);
 
-	if (compl->dw[offsetof(struct amap_eth_tx_compl, valid) / 32] == 0)
+	if (compl->dw[offsetof(struct amap_eth_tx_compl, valid) >> 5] == 0)
 		return NULL;
 
 	/* Ensure load ordering of valid bit dword and other dwords below */
@@ -2600,7 +2600,7 @@ static struct be_tx_compl_info *be_tx_compl_get(struct be_tx_obj *txo)
 	txcp->status = GET_TX_COMPL_BITS(status, compl);
 	txcp->end_index = GET_TX_COMPL_BITS(wrb_index, compl);
 
-	compl->dw[offsetof(struct amap_eth_tx_compl, valid) / 32] = 0;
+	compl->dw[offsetof(struct amap_eth_tx_compl, valid) >> 5] = 0;
 	queue_tail_inc(tx_cq);
 	return txcp;
 }
-- 
1.8.3.1
