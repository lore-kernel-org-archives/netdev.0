From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 8/9] bnx2x: Multi Queue
Date: Mon, 25 Aug 2008 17:25:04 +0300
Message-ID: <1219674304.19456.34.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yitchak Gertner" <gertner@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3956 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754686AbYHYO0W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2008 10:26:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Multi Queue
The multi queue support is still disabled by default for the bnx2x
(needs some more testing and validation), but there are 2 obvious bug in
it which are fixed in this patch

Signed-off-by: Yitchak Gertner <gertner@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index f0b04c9..95e0582 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -6492,7 +6492,7 @@ static int bnx2x_stop_multi(struct bnx2x *bp, int index)
 
 	/* halt the connection */
 	bp->fp[index].state = BNX2X_FP_STATE_HALTING;
-	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_HALT, index, 0, 0, 0);
+	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_HALT, index, 0, index, 0);
 
 	/* Wait for completion */
 	rc = bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_HALTED, index,
@@ -9492,8 +9492,7 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	fp_index = (smp_processor_id() % bp->num_queues);
 	fp = &bp->fp[fp_index];
 
-	if (unlikely(bnx2x_tx_avail(bp->fp) <
-					(skb_shinfo(skb)->nr_frags + 3))) {
+	if (unlikely(bnx2x_tx_avail(fp) < (skb_shinfo(skb)->nr_frags + 3))) {
 		bp->eth_stats.driver_xoff++,
 		netif_stop_queue(dev);
 		BNX2X_ERR("BUG! Tx ring full when queue awake!\n");
@@ -9556,7 +9555,6 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		tx_bd->vlan = cpu_to_le16(pkt_prod);
 
 	if (xmit_type) {
-
 		/* turn on parsing and get a BD */
 		bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
 		pbd = (void *)&fp->tx_desc_ring[bd_prod];
-- 
1.5.3.2




