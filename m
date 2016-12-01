From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH -next] net: ethernet: ti: davinci_cpdma: add missing EXPORTs
Date: Thu, 1 Dec 2016 15:25:28 -0500
Message-ID: <20161201202528.12531-1-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        <linux-omap@vger.kernel.org>, <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.windriver.com ([192.103.53.11]:41788 "EHLO mail5.wrs.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934428AbcLAU0l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Dec 2016 15:26:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As of commit 8f32b90981dcdb355516fb95953133f8d4e6b11d
("net: ethernet: ti: davinci_cpdma: add set rate for a channel") the
ARM allmodconfig builds would fail modpost with:

ERROR: "cpdma_chan_set_weight" [drivers/net/ethernet/ti/ti_cpsw.ko] undefined!
ERROR: "cpdma_chan_get_rate" [drivers/net/ethernet/ti/ti_cpsw.ko] undefined!
ERROR: "cpdma_chan_get_min_rate" [drivers/net/ethernet/ti/ti_cpsw.ko] undefined!
ERROR: "cpdma_chan_set_rate" [drivers/net/ethernet/ti/ti_cpsw.ko] undefined!

Since these weren't declared as static, it is assumed they were
meant to be shared outside the file, and that modular build testing
was simply overlooked.

Fixes: 8f32b90981dc ("net: ethernet: ti: davinci_cpdma: add set rate for a channel")
Cc: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
Cc: Grygorii Strashko <grygorii.strashko@ti.com>
Cc: linux-omap@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/ethernet/ti/davinci_cpdma.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index c776e4575d2d..36518fc5c7cc 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -796,6 +796,7 @@ int cpdma_chan_set_weight(struct cpdma_chan *ch, int weight)
 	spin_unlock_irqrestore(&ctlr->lock, flags);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(cpdma_chan_set_weight);
 
 /* cpdma_chan_get_min_rate - get minimum allowed rate for channel
  * Should be called before cpdma_chan_set_rate.
@@ -810,6 +811,7 @@ u32 cpdma_chan_get_min_rate(struct cpdma_ctlr *ctlr)
 
 	return DIV_ROUND_UP(divident, divisor);
 }
+EXPORT_SYMBOL_GPL(cpdma_chan_get_min_rate);
 
 /* cpdma_chan_set_rate - limits bandwidth for transmit channel.
  * The bandwidth * limited channels have to be in order beginning from lowest.
@@ -853,6 +855,7 @@ int cpdma_chan_set_rate(struct cpdma_chan *ch, u32 rate)
 	spin_unlock_irqrestore(&ctlr->lock, flags);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(cpdma_chan_set_rate);
 
 u32 cpdma_chan_get_rate(struct cpdma_chan *ch)
 {
@@ -865,6 +868,7 @@ u32 cpdma_chan_get_rate(struct cpdma_chan *ch)
 
 	return rate;
 }
+EXPORT_SYMBOL_GPL(cpdma_chan_get_rate);
 
 struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
 				     cpdma_handler_fn handler, int rx_type)
-- 
2.11.0
