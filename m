From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 02/10] fec: enable transmit and receive time stamping.
Date: Sun, 12 Jun 2011 14:18:59 +0200
Message-ID: <1a5a97397356b4b715e12bac3b10ad9074756ea3.1307880494.git.richard.cochran@omicron.at>
References: <cover.1307880494.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Greg Ungerer <gerg@uclinux.org>,
	=?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>,
	Shawn Guo <shawn.guo@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:46427 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753329Ab1FLMTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 08:19:15 -0400
Received: by mail-bw0-f46.google.com with SMTP id 15so3125460bwz.19
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2011 05:19:15 -0700 (PDT)
In-Reply-To: <cover.1307880494.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1307880494.git.richard.cochran@omicron.at>
References: <cover.1307880494.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch has been tested on the Freescale M5234BCC, which includes th=
e
National Semiconductor DP83640 with IEEE 1588 support.

Cc: Greg Ungerer <gerg@uclinux.org>
Cc: "Uwe Kleine-K=C3=B6nig" <u.kleine-koenig@pengutronix.de>
Cc: Shawn Guo <shawn.guo@freescale.com>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/fec.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 885d8ba..965fe90 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -326,6 +326,8 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net=
_device *ndev)
=20
 	spin_unlock_irqrestore(&fep->hw_lock, flags);
=20
+	skb_tx_timestamp(skb);
+
 	return NETDEV_TX_OK;
 }
=20
@@ -650,7 +652,8 @@ fec_enet_rx(struct net_device *ndev)
 			skb_put(skb, pkt_len - 4);	/* Make room */
 			skb_copy_to_linear_data(skb, data, pkt_len - 4);
 			skb->protocol =3D eth_type_trans(skb, ndev);
-			netif_rx(skb);
+			if (!skb_defer_rx_timestamp(skb))
+				netif_rx(skb);
 		}
=20
 		bdp->cbd_bufaddr =3D dma_map_single(&fep->pdev->dev, data,
--=20
1.7.0.4

