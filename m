From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH net-next 1/1] net: fec: clear receive interrupts before processing a packet
Date: Wed, 2 Sep 2015 17:24:14 +0800
Message-ID: <1441185854-16107-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux@arm.linux.org.uk>, <phdm@macq.eu>,
	<b38611@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0131.outbound.protection.outlook.com ([65.55.169.131]:29241
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750971AbbIBJjg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2015 05:39:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk+kernel@arm.linux.org.uk>

The patch just to re-submit the patch "db3421c114cfa6326" because the
patch "4d494cdc92b3b9a0" remove the change.

Clear any pending receive interrupt before we process a pending packet.
This helps to avoid any spurious interrupts being raised after we have
fully cleaned the receive ring, while still allowing an interrupt to be
raised if we receive another packet.

The position of this is critical: we must do this prior to reading the
next packet status to avoid potentially dropping an interrupt when a
packet is still pending.

Acked-by: Fugang Duan <B38611@freescale.com>
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 1f89c59..6bed0ff 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1400,6 +1400,7 @@ fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
 		if ((status & BD_ENET_RX_LAST) == 0)
 			netdev_err(ndev, "rcv is not +last\n");
 
+		writel(FEC_ENET_RXF, fep->hwp + FEC_IEVENT);
 
 		/* Check for errors. */
 		if (status & (BD_ENET_RX_LG | BD_ENET_RX_SH | BD_ENET_RX_NO |
-- 
1.9.1
