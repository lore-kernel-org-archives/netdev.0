From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next V2 3/8] net: fec: fix fec_enet_get_free_txdesc_num
Date: Fri,  5 Feb 2016 14:52:45 -0700
Message-ID: <1454709170-19527-4-git-send-email-troy.kisky@boundarydevices.com>
References: <1454709170-19527-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, johannes@sipsolutions.net, arnd@arndb.de,
	Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33820 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbcBEVzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 16:55:10 -0500
Received: by mail-pf0-f182.google.com with SMTP id o185so75229516pfb.1
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 13:55:09 -0800 (PST)
In-Reply-To: <1454709170-19527-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When first initialized, cur_tx points to the 1st
entry in the queue, and dirty_tx points to the last.
At this point, fec_enet_get_free_txdesc_num will
return tx_ring_size -2. If tx_ring_size -2 entries
are now queued, then fec_enet_get_free_txdesc_num
should return 0, but it returns tx_ring_size instead.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 162fa59..adbddfd 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -296,7 +296,7 @@ static int fec_enet_get_free_txdesc_num(struct fec_enet_private *fep,
 	entries = ((const char *)txq->dirty_tx -
 			(const char *)txq->cur_tx) / fep->bufdesc_size - 1;
 
-	return entries > 0 ? entries : entries + txq->tx_ring_size;
+	return entries >= 0 ? entries : entries + txq->tx_ring_size;
 }
 
 static void swap_buffer(void *bufaddr, int len)
-- 
2.5.0
