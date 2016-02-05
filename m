From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next V2 1/8] net: fec: stop the "rcv is not +last, " error messages
Date: Fri,  5 Feb 2016 14:52:43 -0700
Message-ID: <1454709170-19527-2-git-send-email-troy.kisky@boundarydevices.com>
References: <1454709170-19527-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, johannes@sipsolutions.net, arnd@arndb.de,
	Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:32795 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbcBEVzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 16:55:06 -0500
Received: by mail-pf0-f169.google.com with SMTP id w123so75565803pfb.0
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 13:55:06 -0800 (PST)
In-Reply-To: <1454709170-19527-1-git-send-email-troy.kisky@boundarydevices.com>
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
index 2106d72..cc9677a 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -64,6 +64,7 @@
 #define FEC_R_FIFO_RSEM		0x194 /* Receive FIFO section empty threshold */
 #define FEC_R_FIFO_RAEM		0x198 /* Receive FIFO almost empty threshold */
 #define FEC_R_FIFO_RAFL		0x19c /* Receive FIFO almost full threshold */
+#define FEC_FTRL		0x1b0 /* Frame truncation receive length*/
 #define FEC_RACC		0x1c4 /* Receive Accelerator function */
 #define FEC_RCMR_1		0x1c8 /* Receive classification match ring 1 */
 #define FEC_RCMR_2		0x1cc /* Receive classification match ring 2 */
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 41c81f6..3e5b24a 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -988,6 +988,7 @@ fec_restart(struct net_device *ndev)
 			val &= ~FEC_RACC_OPTIONS;
 		writel(val, fep->hwp + FEC_RACC);
 	}
+	writel(PKT_MAXBUF_SIZE, fep->hwp + FEC_FTRL);
 #endif
 
 	/*
-- 
2.5.0
