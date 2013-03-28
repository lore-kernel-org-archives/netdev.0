From: Steffen Trumtrar <s.trumtrar@pengutronix.de>
Subject: [PATCH v2 2/3] net/macb: force endian_swp_pkt_en to off
Date: Thu, 28 Mar 2013 10:07:06 +0100
Message-ID: <1364461627-26521-3-git-send-email-s.trumtrar@pengutronix.de>
References: <1364461627-26521-1-git-send-email-s.trumtrar@pengutronix.de>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Steffen Trumtrar <s.trumtrar@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37637 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754890Ab3C1JHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 05:07:24 -0400
In-Reply-To: <1364461627-26521-1-git-send-email-s.trumtrar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The core has a bit for swapping packet data endianism.
Reset default from Cadence is off. Xilinx however, who uses this core on the
Zynq SoCs, opted for on.
Force it to off. This shouldn't change the behaviour for current users of the
macb, but enables usage on Zynq devices.

Signed-off-by: Steffen Trumtrar <s.trumtrar@pengutronix.de>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 1 +
 drivers/net/ethernet/cadence/macb.h | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 817835e..71e766b 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1057,6 +1057,7 @@ static void macb_configure_dma(struct macb *bp)
 		dmacfg |= GEM_BF(RXBS, RX_BUFFER_SIZE / 64);
 		dmacfg |= GEM_BF(FBLDO, 16);
 		dmacfg |= GEM_BIT(TXPBMS) | GEM_BF(RXBMS, -1L);
+		dmacfg &= ~GEM_BIT(ENDIA);
 		gem_writel(bp, DMACFG, dmacfg);
 	}
 }
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 570908b..993d703 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -173,6 +173,8 @@
 /* Bitfields in DMACFG. */
 #define GEM_FBLDO_OFFSET			0
 #define GEM_FBLDO_SIZE				5
+#define GEM_ENDIA_OFFSET			7
+#define GEM_ENDIA_SIZE				1
 #define GEM_RXBMS_OFFSET			8
 #define GEM_RXBMS_SIZE				2
 #define GEM_TXPBMS_OFFSET			10
-- 
1.8.2.rc2
