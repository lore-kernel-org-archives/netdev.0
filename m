From: Mirko Lindner <mlindner@marvell.com>
Subject: [PATCH 1/2] sky2: Receive Overflows not counted
Date: Tue, 26 Mar 2013 17:38:35 +0100
Message-ID: <90975282.csDe8I7Lqy@mlindner-lin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog131.obsmtp.com ([74.125.149.247]:58504 "EHLO
	na3sys009aog131.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755564Ab3CZQlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 12:41:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sky2 driver doesn't count the Receive Overflows because the MAC 
interrupt for this event is not set in the MAC's interrupt mask.
The MAC's interrupt mask is set only for Transmit FIFO Underruns.

Fix: The correct setting should be (GM_IS_TX_FF_UR | GM_IS_RX_FF_OR)
Otherwise the Receive Overflow event will not generate any interrupt.
The  Receive Overflow interrupt is handled correctly

Signed-off-by: Mirko Lindner <mlindner@marvell.com>
---
 drivers/net/ethernet/marvell/sky2.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/sky2.h b/drivers/net/ethernet/marvell/sky2.h
index 615ac63..ec6dcd8 100644
--- a/drivers/net/ethernet/marvell/sky2.h
+++ b/drivers/net/ethernet/marvell/sky2.h
@@ -2074,7 +2074,7 @@ enum {
 	GM_IS_RX_FF_OR	= 1<<1,	/* Receive FIFO Overrun */
 	GM_IS_RX_COMPL	= 1<<0,	/* Frame Reception Complete */
 
-#define GMAC_DEF_MSK     GM_IS_TX_FF_UR
+#define GMAC_DEF_MSK     (GM_IS_TX_FF_UR | GM_IS_RX_FF_OR)
 };
 
 /*	GMAC_LINK_CTRL	16 bit	GMAC Link Control Reg (YUKON only) */
-- 
1.7.10.4
