From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/3 net-next] tg3: Add memory barriers to sync BD data
Date: Sun, 4 Mar 2012 16:48:14 -0800
Message-ID: <1330908495-3758-2-git-send-email-mchan@broadcom.com>
References: <1330908495-3758-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3324 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756014Ab2CEApl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Mar 2012 19:45:41 -0500
In-Reply-To: <1330908495-3758-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

for weak memory model architectures to ensure that the chip will DMA
valid BD data.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 4b3243b..0da93db 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -5928,6 +5928,9 @@ next_pkt_nopost:
 
 	/* Refill RX ring(s). */
 	if (!tg3_flag(tp, ENABLE_RSS)) {
+		/* Sync BD data before updating mailbox */
+		wmb();
+
 		if (work_mask & RXD_OPAQUE_RING_STD) {
 			tpr->rx_std_prod_idx = std_prod_idx &
 					       tp->rx_std_ring_mask;
@@ -6970,6 +6973,9 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb_tx_timestamp(skb);
 	netdev_sent_queue(tp->dev, skb->len);
 
+	/* Sync BD data before updating mailbox */
+	wmb();
+
 	/* Packets are ready, update Tx producer idx local and on card. */
 	tw32_tx_mbox(tnapi->prodmbox, entry);
 
@@ -11763,6 +11769,9 @@ static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, bool tso_loopback)
 
 	tnapi->tx_prod++;
 
+	/* Sync BD data before updating mailbox */
+	wmb();
+
 	tw32_tx_mbox(tnapi->prodmbox, tnapi->tx_prod);
 	tr32_mailbox(tnapi->prodmbox);
 
-- 
1.7.1
