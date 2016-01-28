From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 29/40] net: fec: don't free skb when returning busy
Date: Thu, 28 Jan 2016 14:25:53 -0700
Message-ID: <1454016364-30985-30-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36568 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755888AbcA1V26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:28:58 -0500
Received: by mail-pf0-f178.google.com with SMTP id n128so29537569pfn.3
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:28:57 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From Documentation/networking/driver.txt

If you return NETDEV_TX_BUSY from the ndo_start_xmit method, you
must not keep any reference to that SKB and you must not attempt
to free it up.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index e141f6f..3a82bfe 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -558,7 +558,6 @@ fec_enet_txq_put_data_tso(struct fec_enet_priv_tx_q *txq, struct sk_buff *skb,
 
 	addr = dma_map_single(&fep->pdev->dev, data, size, DMA_TO_DEVICE);
 	if (dma_mapping_error(&fep->pdev->dev, addr)) {
-		dev_kfree_skb_any(skb);
 		if (net_ratelimit())
 			netdev_err(ndev, "Tx DMA memory map failed\n");
 		return NETDEV_TX_BUSY;
@@ -616,7 +615,6 @@ fec_enet_txq_put_hdr_tso(struct fec_enet_priv_tx_q *txq,
 		dmabuf = dma_map_single(&fep->pdev->dev, bufaddr,
 					hdr_len, DMA_TO_DEVICE);
 		if (dma_mapping_error(&fep->pdev->dev, dmabuf)) {
-			dev_kfree_skb_any(skb);
 			if (net_ratelimit())
 				netdev_err(ndev, "Tx DMA memory map failed\n");
 			return NETDEV_TX_BUSY;
-- 
2.5.0
