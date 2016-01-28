From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 21/40] net: fec: print more debug info in fec_timeout
Date: Thu, 28 Jan 2016 14:25:45 -0700
Message-ID: <1454016364-30985-22-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36758 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755548AbcA1V2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:28:44 -0500
Received: by mail-pa0-f43.google.com with SMTP id yy13so29101613pab.3
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:28:43 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Print the current interrupt flags and mask and
the interrupt state during the last interrupt in
fec_timeout.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec.h      | 1 +
 drivers/net/ethernet/freescale/fec_main.c | 4 ++++
 2 files changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index be0e3d9..d2ca2e2 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -490,6 +490,7 @@ struct fec_enet_private {
 	unsigned int total_tx_ring_size;
 	unsigned int total_rx_ring_size;
 	uint	events;
+	uint	last_ievents;
 
 	struct	platform_device *pdev;
 
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 47df66e..bc084ad9 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1102,6 +1102,9 @@ fec_timeout(struct net_device *ndev)
 	int i;
 	uint events = 0;
 
+	pr_err("%s: last=%x %x, mask %x\n", __func__, fep->last_ievents,
+	       readl(fep->hwp + FEC_IEVENT), readl(fep->hwp + FEC_IMASK));
+
 	for (i = 0; i < fep->num_tx_queues; i++) {
 		struct fec_enet_priv_tx_q *txq = fep->tx_queue[i];
 		int index;
@@ -1504,6 +1507,7 @@ fec_enet_interrupt(int irq, void *dev_id)
 
 	if (!int_events)
 		return IRQ_NONE;
+	fep->last_ievents = int_events;
 
 	if (int_events & (FEC_ENET_RXF | FEC_ENET_TXF)) {
 		if (napi_schedule_prep(&fep->napi)) {
-- 
2.5.0
