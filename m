From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next V3 01/16] net: fec: only check queue 0 if RXF_0/TXF_0 interrupt is set
Date: Tue,  5 Apr 2016 19:25:47 -0700
Message-ID: <1459909562-22865-2-git-send-email-troy.kisky@boundarydevices.com>
References: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@nxp.com, l.stach@pengutronix.de, andrew@lunn.ch,
	tremyfr@gmail.com, gerg@uclinux.org,
	linux-arm-kernel@lists.infradead.org, johannes@sipsolutions.net,
	stillcompiling@gmail.com, sergei.shtylyov@cogentembedded.com,
	arnd@arndb.de, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, fugang.duan@nxp.com,
	lznuaa@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36334 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752745AbcDFC2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 22:28:11 -0400
Received: by mail-pa0-f47.google.com with SMTP id bx7so6605381pad.3
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 19:28:10 -0700 (PDT)
In-Reply-To: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before queue 0 was always checked if any queue caused an interrupt.
It is better to just mark queue 0 if queue 0 has caused an interrupt.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
Acked-by: Fugang Duan <Fugang.duan@nxp.com>

---
v3: add Acked-by
---
 drivers/net/ethernet/freescale/fec_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 08243c2..a011719 100644
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
