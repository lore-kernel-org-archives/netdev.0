From: Cyril Roelandt <tipecaml@gmail.com>
Subject: [PATCH] net: ethernet: ti: remove redundant NULL check.
Date: Tue, 12 Feb 2013 22:54:46 +0100
Message-ID: <1360706086-31506-1-git-send-email-tipecaml@gmail.com>
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	mugunthanvnm@ti.com, zonque@gmail.com, hotforest@gmail.com,
	Julia.Lawall@lip6.fr, netdev@vger.kernel.org,
	Cyril Roelandt <tipecaml@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:61583 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755365Ab3BLWEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 17:04:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cpdma_chan_destroy() on a NULL pointer is a no-op, so the NULL check in
cpdma_ctlr_destroy() can safely be removed.

Signed-off-by: Cyril Roelandt <tipecaml@gmail.com>
---
 drivers/net/ethernet/ti/davinci_cpdma.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index f862918..aba787b 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -450,8 +450,7 @@ int cpdma_ctlr_destroy(struct cpdma_ctlr *ctlr)
 		cpdma_ctlr_stop(ctlr);
 
 	for (i = 0; i < ARRAY_SIZE(ctlr->channels); i++) {
-		if (ctlr->channels[i])
-			cpdma_chan_destroy(ctlr->channels[i]);
+		cpdma_chan_destroy(ctlr->channels[i]);
 	}
 
 	cpdma_desc_pool_destroy(ctlr->pool);
-- 
1.7.10.4
