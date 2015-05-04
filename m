From: Nathan Sullivan <nathan.sullivan@ni.com>
Subject: [PATCH] net: macb: Do not enable RX buffer used interrupt
Date: Mon, 4 May 2015 12:43:15 -0500
Message-ID: <1430761396-4878-1-git-send-email-nathan.sullivan@ni.com>
Cc: linux-kernel@vger.kernel.org,
	Nathan Sullivan <nathan.sullivan@ni.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from skprod2.natinst.com ([130.164.80.23]:58684 "EHLO ni.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750779AbbEDRns (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2015 13:43:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver does not handle the RX buffer used interrupt, nor does
it need to due to handling the RX overflow interrupt already.  Enabling
the interrupt would lead to an infinite loop in the ISR.

Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
---
 drivers/net/ethernet/cadence/macb.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 4104d49..b466697 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -44,8 +44,7 @@
 /* level of occupied TX descriptors under which we wake up TX process */
 #define MACB_TX_WAKEUP_THRESH	(3 * TX_RING_SIZE / 4)
 
-#define MACB_RX_INT_FLAGS	(MACB_BIT(RCOMP) | MACB_BIT(RXUBR)	\
-				 | MACB_BIT(ISR_ROVR))
+#define MACB_RX_INT_FLAGS	(MACB_BIT(RCOMP) | MACB_BIT(ISR_ROVR))
 #define MACB_TX_ERR_FLAGS	(MACB_BIT(ISR_TUND)			\
 					| MACB_BIT(ISR_RLE)		\
 					| MACB_BIT(TXERR))
-- 
1.7.10.4
