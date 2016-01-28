From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 06/40] net: fec: don't disable FEC_ENET_TS_TIMER interrupt
Date: Thu, 28 Jan 2016 14:25:30 -0700
Message-ID: <1454016364-30985-7-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36279 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966431AbcA1V2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:28:19 -0500
Received: by mail-pf0-f182.google.com with SMTP id n128so29529846pfn.3
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:28:19 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only the interrupt routine processes this condition.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec.h      | 1 +
 drivers/net/ethernet/freescale/fec_main.c | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index f8d7fdb..684fe91f 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -359,6 +359,7 @@ struct bufdesc_ex {
 #define FEC_ENET_TS_TIMER       ((uint)0x00008000)
 
 #define FEC_DEFAULT_IMASK (FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MII | FEC_ENET_TS_TIMER)
+#define FEC_NAPI_IMASK	(FEC_ENET_MII | FEC_ENET_TS_TIMER)
 #define FEC_RX_DISABLED_IMASK (FEC_DEFAULT_IMASK & (~FEC_ENET_RXF))
 
 /* ENET interrupt coalescing macro define */
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 0e8c8b6..e8f35fb 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1545,7 +1545,7 @@ fec_enet_interrupt(int irq, void *dev_id)
 
 		if (napi_schedule_prep(&fep->napi)) {
 			/* Disable the NAPI interrupts */
-			writel(FEC_ENET_MII, fep->hwp + FEC_IMASK);
+			writel(FEC_NAPI_IMASK, fep->hwp + FEC_IMASK);
 			__napi_schedule(&fep->napi);
 		}
 	}
-- 
2.5.0
