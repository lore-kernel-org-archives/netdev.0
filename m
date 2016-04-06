From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next V3 07/16] net: fec: don't clear all rx queue bits when just one is being checked
Date: Tue,  5 Apr 2016 19:25:53 -0700
Message-ID: <1459909562-22865-8-git-send-email-troy.kisky@boundarydevices.com>
References: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@nxp.com, l.stach@pengutronix.de, andrew@lunn.ch,
	tremyfr@gmail.com, gerg@uclinux.org,
	linux-arm-kernel@lists.infradead.org, johannes@sipsolutions.net,
	stillcompiling@gmail.com, sergei.shtylyov@cogentembedded.com,
	arnd@arndb.de, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, fugang.duan@nxp.com,
	lznuaa@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36447 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760070AbcDFC2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 22:28:21 -0400
Received: by mail-pa0-f43.google.com with SMTP id bx7so6607974pad.3
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 19:28:20 -0700 (PDT)
In-Reply-To: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FEC_ENET_RXF is 3 separate bits, we only check one queue
at a time. So, when the last queue is being checked, it is
bad to remove the interrupt on the 1st queue.

Also, since tx/rx interrupts are now cleared in the napi
routine and not the interrupt, it is not needed here any longer.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>

---
v3: change commit message
---
 drivers/net/ethernet/freescale/fec_main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 17140ea..3cd0cdf 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1339,8 +1339,6 @@ static int fec_rxq(struct net_device *ndev, struct fec_enet_priv_rx_q *rxq,
 			break;
 		pkt_received++;
 
-		writel(FEC_ENET_RXF, fep->hwp + FEC_IEVENT);
-
 		/* Check for errors. */
 		status ^= BD_ENET_RX_LAST;
 		if (status & (BD_ENET_RX_LG | BD_ENET_RX_SH | BD_ENET_RX_NO |
-- 
2.5.0
