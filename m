From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 01/40] net: fec: stop the "rcv is not +last, " error messages
Date: Thu, 28 Jan 2016 14:25:25 -0700
Message-ID: <1454016364-30985-2-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33404 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbcA1V2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:28:10 -0500
Received: by mail-pa0-f54.google.com with SMTP id cy9so29197946pac.0
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:28:10 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Setting the FTRL register will stop the fec from
trying to use multiple receive buffers.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec.h      | 1 +
 drivers/net/ethernet/freescale/fec_main.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 99d33e2..5144e73 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -65,6 +65,7 @@
 #define FEC_R_FIFO_RSEM		0x194 /* Receive FIFO section empty threshold */
 #define FEC_R_FIFO_RAEM		0x198 /* Receive FIFO almost empty threshold */
 #define FEC_R_FIFO_RAFL		0x19c /* Receive FIFO almost full threshold */
+#define FEC_FTRL		0x1b0 /* Frame truncation receive length*/
 #define FEC_RACC		0x1c4 /* Receive Accelerator function */
 #define FEC_RCMR_1		0x1c8 /* Receive classification match ring 1 */
 #define FEC_RCMR_2		0x1cc /* Receive classification match ring 2 */
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 502da6f..2c7c845 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -984,6 +984,7 @@ fec_restart(struct net_device *ndev)
 			val &= ~FEC_RACC_OPTIONS;
 		writel(val, fep->hwp + FEC_RACC);
 	}
+	writel(PKT_MAXBUF_SIZE, fep->hwp + FEC_FTRL);
 #endif
 
 	/*
-- 
2.5.0
