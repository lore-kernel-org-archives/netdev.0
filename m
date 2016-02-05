From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next V2 6/8] net: fec: don't disable FEC_ENET_TS_TIMER interrupt
Date: Fri,  5 Feb 2016 14:52:48 -0700
Message-ID: <1454709170-19527-7-git-send-email-troy.kisky@boundarydevices.com>
References: <1454709170-19527-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, johannes@sipsolutions.net, arnd@arndb.de,
	Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34918 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451AbcBEVzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 16:55:15 -0500
Received: by mail-pa0-f44.google.com with SMTP id ho8so40383259pac.2
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 13:55:14 -0800 (PST)
In-Reply-To: <1454709170-19527-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only the interrupt routine processes this condition.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec.h      | 1 +
 drivers/net/ethernet/freescale/fec_main.c | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index bedd28a..195122e 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -375,6 +375,7 @@ struct bufdesc_ex {
 #define FEC_ENET_TS_TIMER       ((uint)0x00008000)
 
 #define FEC_DEFAULT_IMASK (FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MII | FEC_ENET_TS_TIMER)
+#define FEC_NAPI_IMASK	(FEC_ENET_MII | FEC_ENET_TS_TIMER)
 #define FEC_RX_DISABLED_IMASK (FEC_DEFAULT_IMASK & (~FEC_ENET_RXF))
 
 /* ENET interrupt coalescing macro define */
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 712e3bb..ca2708d 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1553,7 +1553,7 @@ fec_enet_interrupt(int irq, void *dev_id)
 
 		if (napi_schedule_prep(&fep->napi)) {
 			/* Disable the NAPI interrupts */
-			writel(FEC_ENET_MII, fep->hwp + FEC_IMASK);
+			writel(FEC_NAPI_IMASK, fep->hwp + FEC_IMASK);
 			__napi_schedule(&fep->napi);
 		}
 	}
-- 
2.5.0
