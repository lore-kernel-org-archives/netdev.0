From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 04/11] ll_temac: enable transmit and receive time stamping.
Date: Sun, 19 Jun 2011 13:20:00 +0200
Message-ID: <5445cebff9f71fa7d9070bed38fdcaded348cae4.1308481492.git.richard.cochran@omicron.at>
References: <cover.1308481491.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Grant Likely <grant.likely@secretlab.ca>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44082 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753452Ab1FSLUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 07:20:13 -0400
Received: by mail-fx0-f46.google.com with SMTP id 17so448603fxm.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 04:20:12 -0700 (PDT)
In-Reply-To: <cover.1308481491.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308481491.git.richard.cochran@omicron.at>
References: <cover.1308481491.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables software (and phy device) time stamping. Since this MAC
is based on phylib, adding the hooks makes hardware time stamping in the
phy possible.

Compile tested only.

Cc: Grant Likely <grant.likely@secretlab.ca>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/ll_temac_main.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index b7948cc..eabc378 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -730,6 +730,8 @@ static int temac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	/* Kick off the transfer */
 	lp->dma_out(lp, TX_TAILDESC_PTR, tail_p); /* DMA start */
 
+	skb_tx_timestamp(skb);
+
 	return NETDEV_TX_OK;
 }
 
@@ -772,7 +774,8 @@ static void ll_temac_recv(struct net_device *ndev)
 			skb->ip_summed = CHECKSUM_COMPLETE;
 		}
 
-		netif_rx(skb);
+		if (!skb_defer_rx_timestamp(skb))
+			netif_rx(skb);
 
 		ndev->stats.rx_packets++;
 		ndev->stats.rx_bytes += length;
-- 
1.7.0.4

