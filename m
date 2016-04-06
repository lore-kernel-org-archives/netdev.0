From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next V3 03/16] net: fec: return IRQ_HANDLED if fec_ptp_check_pps_event handled it
Date: Tue,  5 Apr 2016 19:25:49 -0700
Message-ID: <1459909562-22865-4-git-send-email-troy.kisky@boundarydevices.com>
References: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@nxp.com, l.stach@pengutronix.de, andrew@lunn.ch,
	tremyfr@gmail.com, gerg@uclinux.org,
	linux-arm-kernel@lists.infradead.org, johannes@sipsolutions.net,
	stillcompiling@gmail.com, sergei.shtylyov@cogentembedded.com,
	arnd@arndb.de, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, fugang.duan@nxp.com,
	lznuaa@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34226 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759477AbcDFC2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 22:28:14 -0400
Received: by mail-pa0-f51.google.com with SMTP id fe3so22785818pab.1
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 19:28:14 -0700 (PDT)
In-Reply-To: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fec_ptp_check_pps_event will return 1 if FEC_T_TF_MASK caused
an interrupt. Don't return IRQ_NONE in this case.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>

---
v3: New patch, came from feedback from another patch.
---
 drivers/net/ethernet/freescale/fec_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index a011719..7993040 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1579,8 +1579,8 @@ fec_enet_interrupt(int irq, void *dev_id)
 	}
 
 	if (fep->ptp_clock)
-		fec_ptp_check_pps_event(fep);
-
+		if (fec_ptp_check_pps_event(fep))
+			ret = IRQ_HANDLED;
 	return ret;
 }
 
-- 
2.5.0
