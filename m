From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 14/40] net: fec: don't clear all rx queue bits when just one is being checked
Date: Thu, 28 Jan 2016 14:25:38 -0700
Message-ID: <1454016364-30985-15-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34180 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754954AbcA1V2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:28:32 -0500
Received: by mail-pa0-f54.google.com with SMTP id uo6so29719286pac.1
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:28:32 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FEC_ENET_RXF is 3 separate bits, we only check one queue
at a time. So, when the last queue is being checked, it is
bad to remove the interrupt on the 1st queue.

Also, since this is now done in the napi
routine and not the interrupt, it is not needed.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 04b1fb7..a7af1ac 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1330,8 +1330,6 @@ static int fec_rxq(struct net_device *ndev, struct fec_enet_private *fep,
 			break;
 		pkt_received++;
 
-		writel(FEC_ENET_RXF, fep->hwp + FEC_IEVENT);
-
 		/* Check for errors. */
 		status ^= BD_ENET_RX_LAST;
 		if (status & (BD_ENET_RX_LG | BD_ENET_RX_SH | BD_ENET_RX_NO |
-- 
2.5.0
