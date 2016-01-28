From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 26/40] net: fec: set cbd_esc only once
Date: Thu, 28 Jan 2016 14:25:50 -0700
Message-ID: <1454016364-30985-27-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34325 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755895AbcA1V2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:28:53 -0500
Received: by mail-pa0-f43.google.com with SMTP id uo6so29723077pac.1
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:28:52 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 380c8e2..cf53e21 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -569,6 +569,8 @@ fec_enet_txq_put_data_tso(struct fec_enet_priv_tx_q *txq, struct sk_buff *skb,
 			estatus |= FEC_TX_BD_FTYPE(txq->bd.qid);
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			estatus |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
+		if (is_last)
+			estatus |= BD_ENET_TX_INT;
 		ebdp->cbd_bdu = 0;
 		ebdp->cbd_esc = estatus;
 	}
@@ -576,12 +578,8 @@ fec_enet_txq_put_data_tso(struct fec_enet_priv_tx_q *txq, struct sk_buff *skb,
 	/* Handle the last BD specially */
 	if (last_tcp)
 		status |= (BD_ENET_TX_LAST | BD_ENET_TX_TC);
-	if (is_last) {
+	if (is_last)
 		status |= BD_ENET_TX_INTR;
-		if (fep->bufdesc_ex)
-			ebdp->cbd_esc |= BD_ENET_TX_INT;
-	}
-
 	bdp->cbd_sc = status;
 
 	return 0;
-- 
2.5.0
