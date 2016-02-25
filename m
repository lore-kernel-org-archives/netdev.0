From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next V2 01/16] net: fec: only check queue 0 if RXF_0/TXF_0 interrupt is set
Date: Wed, 24 Feb 2016 17:36:44 -0700
Message-ID: <1456360619-24390-2-git-send-email-troy.kisky@boundarydevices.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, johannes@sipsolutions.net,
	stillcompiling@gmail.com, sergei.shtylyov@cogentembedded.com,
	arnd@arndb.de, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33171 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbcBYAkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 19:40:12 -0500
Received: by mail-pa0-f47.google.com with SMTP id fl4so21824076pad.0
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 16:40:12 -0800 (PST)
In-Reply-To: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before queue 0 was always checked if any queue caused an interrupt.
It is better to just mark queue 0 if queue 0 has caused an interrupt.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index bad0ba2..dbac975 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1534,14 +1534,14 @@ fec_enet_collect_events(struct fec_enet_private *fep, uint int_events)
 	if (int_events == 0)
 		return false;
 
-	if (int_events & FEC_ENET_RXF)
+	if (int_events & FEC_ENET_RXF_0)
 		fep->work_rx |= (1 << 2);
 	if (int_events & FEC_ENET_RXF_1)
 		fep->work_rx |= (1 << 0);
 	if (int_events & FEC_ENET_RXF_2)
 		fep->work_rx |= (1 << 1);
 
-	if (int_events & FEC_ENET_TXF)
+	if (int_events & FEC_ENET_TXF_0)
 		fep->work_tx |= (1 << 2);
 	if (int_events & FEC_ENET_TXF_1)
 		fep->work_tx |= (1 << 0);
-- 
2.5.0
