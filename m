From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 18/40] net: fec: clear cbd_sc after transmission to help with debugging
Date: Thu, 28 Jan 2016 14:25:42 -0700
Message-ID: <1454016364-30985-19-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34226 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755524AbcA1V2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:28:39 -0500
Received: by mail-pa0-f54.google.com with SMTP id uo6so29720502pac.1
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:28:38 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the tx queue is dumped, it is easier to see that this
entry is idle.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index fcbbf0d..1759705 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1161,6 +1161,7 @@ static void fec_txq(struct net_device *ndev, struct fec_enet_private *fep,
 			}
 			break;
 		}
+		bdp->cbd_sc = (bdp == txq->bd.last) ? BD_SC_WRAP : 0;
 
 		index = fec_enet_get_bd_index(bdp, &txq->bd);
 
-- 
2.5.0
