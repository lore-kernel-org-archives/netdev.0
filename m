From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 30/40] net: fec: move last_bdp assignment for symmetry
Date: Thu, 28 Jan 2016 14:25:54 -0700
Message-ID: <1454016364-30985-31-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:32958 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755908AbcA1V27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:28:59 -0500
Received: by mail-pf0-f176.google.com with SMTP id x125so29979089pfb.0
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:28:59 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This way both if clauses assign last_bdp instead
of only one clause overriding the default.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 3a82bfe..b829c29 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -436,7 +436,6 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 
 	/* Fill in a Tx ring entry */
 	bdp = txq->bd.cur;
-	last_bdp = bdp;
 
 	/* Set buffer length and buffer pointer */
 	bufaddr = skb->data;
@@ -472,6 +471,7 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 			return NETDEV_TX_OK;
 		}
 	} else {
+		last_bdp = bdp;
 		status |= (BD_ENET_TX_INTR | BD_ENET_TX_LAST);
 		if (fep->bufdesc_ex) {
 			estatus = BD_ENET_TX_INT;
-- 
2.5.0
