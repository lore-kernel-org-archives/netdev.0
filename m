From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net] tg3: Fix for disallow tx coalescing time to be 0
Date: Tue, 30 Aug 2016 16:38:55 +0200
Message-ID: <1472567935-13177-1-git-send-email-ivecera@redhat.com>
Cc: satish.baddipadige@broadcom.com, siva.kallam@broadcom.com,
        michael.chan@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56588 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750860AbcH3Oi7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 Aug 2016 10:38:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent commit 087d7a8c disallows to set Rx coalescing time to be 0
as this stops generating interrupts for the incoming packets. I found
the zero Tx coalescing time stops generating interrupts similarly for
outgoing packets and fires Tx watchdog later. To avoid this, don't allow
to set Tx coalescing time to 0.

Cc: satish.baddipadige@broadcom.com
Cc: siva.kallam@broadcom.com
Cc: michael.chan@broadcom.com
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 6592612..07e3beb 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -14012,6 +14012,7 @@ static int tg3_set_coalesce(struct net_device *dev, struct ethtool_coalesce *ec)
 	if ((ec->rx_coalesce_usecs > MAX_RXCOL_TICKS) ||
 	    (!ec->rx_coalesce_usecs) ||
 	    (ec->tx_coalesce_usecs > MAX_TXCOL_TICKS) ||
+	    (!ec->tx_coalesce_usecs) ||
 	    (ec->rx_max_coalesced_frames > MAX_RXMAX_FRAMES) ||
 	    (ec->tx_max_coalesced_frames > MAX_TXMAX_FRAMES) ||
 	    (ec->rx_coalesce_usecs_irq > max_rxcoal_tick_int) ||
-- 
2.7.3
