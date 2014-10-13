From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net PATCH 1/3] drivers: net: davinci_cpdma: remove kfree on objects allocated with devm_* apis
Date: Mon, 13 Oct 2014 22:21:05 +0530
Message-ID: <1413219067-15328-2-git-send-email-mugunthanvnm@ti.com>
References: <1413219067-15328-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:58090 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753895AbaJMQvR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2014 12:51:17 -0400
In-Reply-To: <1413219067-15328-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

memories allocated with devm_* apis must not be freed with kfree apis,
so removing the kfree calls

Fixes: e194312854ed ('drivers: net: davinci_cpdma: Convert kzalloc() to devm_kzalloc().')

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/davinci_cpdma.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 4a000f6..32dc289 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -561,7 +561,6 @@ int cpdma_chan_destroy(struct cpdma_chan *chan)
 		cpdma_chan_stop(chan);
 	ctlr->channels[chan->chan_num] = NULL;
 	spin_unlock_irqrestore(&ctlr->lock, flags);
-	kfree(chan);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(cpdma_chan_destroy);
-- 
2.1.1.332.g0bf7dd6
