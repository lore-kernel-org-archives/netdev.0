From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next V2 10/16] net: fec: clear cbd_sc after transmission to help with debugging
Date: Wed, 24 Feb 2016 17:36:53 -0700
Message-ID: <1456360619-24390-11-git-send-email-troy.kisky@boundarydevices.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, johannes@sipsolutions.net,
	stillcompiling@gmail.com, sergei.shtylyov@cogentembedded.com,
	arnd@arndb.de, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33407 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758855AbcBYAkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 19:40:35 -0500
Received: by mail-pf0-f173.google.com with SMTP id q63so22265655pfb.0
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 16:40:34 -0800 (PST)
In-Reply-To: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the tx queue is dumped, it is easier to see that this
entry is idle.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 1902897..96a0394 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1164,6 +1164,8 @@ static void fec_txq(struct net_device *ndev, struct fec_enet_private *fep,
 			}
 			break;
 		}
+		bdp->cbd_sc = cpu_to_fec16((bdp == txq->bd.last) ?
+					   BD_SC_WRAP : 0);
 
 		index = fec_enet_get_bd_index(bdp, &txq->bd);
 
-- 
2.5.0
