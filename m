From: Tao Hou <hotforest@gmail.com>
Subject: [PATCH] net: ethernet: davinci_cpdma: decrease the desc count when cleaning up the remaining packets
Date: Tue,  2 Oct 2012 10:42:43 +0800
Message-ID: <1349145763-6292-1-git-send-email-hotforest@gmail.com>
Cc: linux-kernel@vger.kernel.org, Tao Hou <hotforest@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:46625 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753734Ab2JBCnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 22:43:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

chan->count is used by rx channel. If the desc count is not updated by
the clean up loop in cpdma_chan_stop, the value written to the rxfree
register in cpdma_chan_start will be incorrect.

Signed-off-by: Tao Hou <hotforest@gmail.com>
---
 drivers/net/ethernet/ti/davinci_cpdma.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index d15c888..4995673 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -863,6 +863,7 @@ int cpdma_chan_stop(struct cpdma_chan *chan)
 
 		next_dma = desc_read(desc, hw_next);
 		chan->head = desc_from_phys(pool, next_dma);
+		chan->count--;
 		chan->stats.teardown_dequeue++;
 
 		/* issue callback without locks held */
-- 
1.7.9.5
