From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 1/1] drivers: net: davinci_cpdma: acknowledge interrupt properly
Date: Thu, 31 Jan 2013 01:26:53 +0530
Message-ID: <1359575813-15703-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <panto@antoniou-consulting.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:58623 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756792Ab3A3T5k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 14:57:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CPDMA interrupts are not properly acknowledged which leads to interrupt
storm, only cpdma interrupt 0 is acknowledged in Davinci CPDMA driver.
Changed cpdma_ctlr_eoi api to acknowledge 1 and 2 interrupts which are
used for rx and tx respectively.

Reported-by: Pantelis Antoniou <panto@antoniou-consulting.com>
Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/davinci_cpdma.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index f862918..afe14a6 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -487,6 +487,8 @@ int cpdma_ctlr_int_ctrl(struct cpdma_ctlr *ctlr, bool enable)
 void cpdma_ctlr_eoi(struct cpdma_ctlr *ctlr)
 {
 	dma_reg_write(ctlr, CPDMA_MACEOIVECTOR, 0);
+	dma_reg_write(ctlr, CPDMA_MACEOIVECTOR, 1);
+	dma_reg_write(ctlr, CPDMA_MACEOIVECTOR, 2);
 }
 
 struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
-- 
1.7.9.5
