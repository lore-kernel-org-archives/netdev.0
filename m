From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH v4 3/3] net: fec: return IRQ_HANDLED if fec_ptp_check_pps_event handled it
Date: Tue, 19 Sep 2017 17:33:09 -0700
Message-ID: <1505867589-11784-3-git-send-email-troy.kisky@boundarydevices.com>
References: <1505867589-11784-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@nxp.com, lznuaa@gmail.com,
        Troy Kisky <troy.kisky@boundarydevices.com>
To: fugang.duan@nxp.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wsip-98-189-142-135.oc.oc.cox.net ([98.189.142.135]:19541 "EHLO
        office-server2" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751284AbdITBRA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 21:17:00 -0400
In-Reply-To: <1505867589-11784-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fec_ptp_check_pps_event will return 1 if FEC_T_TF_MASK caused
an interrupt. Don't return IRQ_NONE in this case.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
Acked-by: Fugang Duan <fugang.duan@nxp.com>

---
v3: New patch, came from feedback from another patch.
v4: Added Acked-by

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 464055f..3dc2d77 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1604,8 +1604,8 @@ fec_enet_interrupt(int irq, void *dev_id)
 	}
 
 	if (fep->ptp_clock)
-		fec_ptp_check_pps_event(fep);
-
+		if (fec_ptp_check_pps_event(fep))
+			ret = IRQ_HANDLED;
 	return ret;
 }
 
-- 
2.7.4
