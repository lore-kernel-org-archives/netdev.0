From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH] net: eth: davicnci_cpdma: check dma map error
Date: Thu, 20 Jun 2013 16:58:45 +0200
Message-ID: <1371740325-14560-1-git-send-email-bigeasy@linutronix.de>
Cc: netdev@vger.kernel.org,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:33784 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758017Ab3FTO7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 10:59:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the DMA mapping may fail the caller should check the return value.

Cc: Mugunthan V N <mugunthanvnm@ti.com>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/ethernet/ti/davinci_cpdma.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 49dfd59..053c84f 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -705,6 +705,13 @@ int cpdma_chan_submit(struct cpdma_chan *chan, void *token, void *data,
 	}
 
 	buffer = dma_map_single(ctlr->dev, data, len, chan->dir);
+	ret = dma_mapping_error(ctlr->dev, buffer);
+	if (ret) {
+		cpdma_desc_free(ctlr->pool, desc, 1);
+		ret = -EINVAL;
+		goto unlock_ret;
+	}
+
 	mode = CPDMA_DESC_OWNER | CPDMA_DESC_SOP | CPDMA_DESC_EOP;
 	cpdma_desc_to_port(chan, mode, directed);
 
-- 
1.8.3.1
