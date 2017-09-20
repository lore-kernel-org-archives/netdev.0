From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH v4 1/3] net: fec: only check queue 0 if RXF_0/TXF_0 interrupt is set
Date: Tue, 19 Sep 2017 17:33:07 -0700
Message-ID: <1505867589-11784-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@nxp.com, lznuaa@gmail.com,
        Troy Kisky <troy.kisky@boundarydevices.com>
To: fugang.duan@nxp.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wsip-98-189-142-135.oc.oc.cox.net ([98.189.142.135]:51062 "EHLO
        office-server2" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750872AbdITBQ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 21:16:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before queue 0 was always checked if any queue caused an interrupt.
It is better to just mark queue 0 if queue 0 has caused an interrupt.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
Acked-by: Fugang Duan <Fugang.duan@nxp.com>

---
v3: add Acked-by
v4: no change

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 56f56d6..464055f 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1559,14 +1559,14 @@ fec_enet_collect_events(struct fec_enet_private *fep, uint int_events)
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
2.7.4
