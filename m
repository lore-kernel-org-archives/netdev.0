From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 24/40] net: fec: return NETDEV_TX_BUSY, when not enough space in ring
Date: Thu, 28 Jan 2016 14:25:48 -0700
Message-ID: <1454016364-30985-25-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33680 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755888AbcA1V2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:28:49 -0500
Received: by mail-pa0-f49.google.com with SMTP id cy9so29205520pac.0
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:28:49 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 29c5781..98b9be2 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -424,10 +424,9 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 
 	entries_free = fec_enet_get_free_txdesc_num(txq);
 	if (entries_free < MAX_SKB_FRAGS + 1) {
-		dev_kfree_skb_any(skb);
 		if (net_ratelimit())
 			netdev_err(ndev, "NOT enough BD for SG!\n");
-		return NETDEV_TX_OK;
+		return NETDEV_TX_BUSY;
 	}
 
 	/* Protocol checksum off-load for TCP and UDP. */
@@ -653,10 +652,9 @@ static int fec_enet_txq_submit_tso(struct fec_enet_priv_tx_q *txq,
 	int ret;
 
 	if (tso_count_descs(skb) >= fec_enet_get_free_txdesc_num(txq)) {
-		dev_kfree_skb_any(skb);
 		if (net_ratelimit())
 			netdev_err(ndev, "NOT enough BD for TSO!\n");
-		return NETDEV_TX_OK;
+		return NETDEV_TX_BUSY;
 	}
 
 	/* Protocol checksum off-load for TCP and UDP. */
-- 
2.5.0
