From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next V3 11/16] net: fec: clear cbd_sc after transmission to help with debugging
Date: Tue,  5 Apr 2016 19:25:57 -0700
Message-ID: <1459909562-22865-12-git-send-email-troy.kisky@boundarydevices.com>
References: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@nxp.com, l.stach@pengutronix.de, andrew@lunn.ch,
	tremyfr@gmail.com, gerg@uclinux.org,
	linux-arm-kernel@lists.infradead.org, johannes@sipsolutions.net,
	stillcompiling@gmail.com, sergei.shtylyov@cogentembedded.com,
	arnd@arndb.de, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, fugang.duan@nxp.com,
	lznuaa@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35535 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760168AbcDFC22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 22:28:28 -0400
Received: by mail-pa0-f42.google.com with SMTP id td3so22732799pab.2
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 19:28:27 -0700 (PDT)
In-Reply-To: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the tx queue is dumped, it is easier to see that this
entry is idle if cbd_sc is cleared after transmission.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>

---
v3: change commit message
---
 drivers/net/ethernet/freescale/fec_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index a2a9dca..f96ea97 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1164,6 +1164,8 @@ static void fec_txq(struct net_device *ndev, struct fec_enet_priv_tx_q *txq)
 			}
 			break;
 		}
+		bdp->cbd_sc = cpu_to_fec16((bdp == txq->bd.last) ?
+					   BD_SC_WRAP : 0);
 
 		index = fec_enet_get_bd_index(bdp, &txq->bd);
 
-- 
2.5.0
