From: mathieu.poirier@linaro.org
Subject: [PATCH 1/8] davinci_cpdma: export symbols used by other drivers
Date: Fri, 20 Apr 2012 14:56:09 -0600
Message-ID: <1334955376-17793-2-git-send-email-mathieu.poirier@linaro.org>
References: <1334955376-17793-1-git-send-email-mathieu.poirier@linaro.org>
Cc: arnd@arndb.de, mathieu.poirier@linaro.org
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334955376-17793-1-git-send-email-mathieu.poirier@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>

The davinci_emac driver can be a module, so the symbols
it needs from the cpdma driver must be exported.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Mathieu Poirier <mathieu.poirier@linaro.org>
---
 drivers/net/ethernet/ti/davinci_cpdma.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 3455876..d614c37 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -92,7 +92,7 @@ enum cpdma_state {
 	CPDMA_STATE_TEARDOWN,
 };
 
-const char *cpdma_state_str[] = { "idle", "active", "teardown" };
+static const char *cpdma_state_str[] = { "idle", "active", "teardown" };
 
 struct cpdma_ctlr {
 	enum cpdma_state	state;
@@ -276,6 +276,7 @@ struct cpdma_ctlr *cpdma_ctlr_create(struct cpdma_params *params)
 		ctlr->num_chan = CPDMA_MAX_CHANNELS;
 	return ctlr;
 }
+EXPORT_SYMBOL_GPL(cpdma_ctlr_create);
 
 int cpdma_ctlr_start(struct cpdma_ctlr *ctlr)
 {
@@ -321,6 +322,7 @@ int cpdma_ctlr_start(struct cpdma_ctlr *ctlr)
 	spin_unlock_irqrestore(&ctlr->lock, flags);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cpdma_ctlr_start);
 
 int cpdma_ctlr_stop(struct cpdma_ctlr *ctlr)
 {
@@ -351,6 +353,7 @@ int cpdma_ctlr_stop(struct cpdma_ctlr *ctlr)
 	spin_unlock_irqrestore(&ctlr->lock, flags);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cpdma_ctlr_stop);
 
 int cpdma_ctlr_dump(struct cpdma_ctlr *ctlr)
 {
@@ -421,6 +424,7 @@ int cpdma_ctlr_dump(struct cpdma_ctlr *ctlr)
 	spin_unlock_irqrestore(&ctlr->lock, flags);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cpdma_ctlr_dump);
 
 int cpdma_ctlr_destroy(struct cpdma_ctlr *ctlr)
 {
@@ -444,6 +448,7 @@ int cpdma_ctlr_destroy(struct cpdma_ctlr *ctlr)
 	kfree(ctlr);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(cpdma_ctlr_destroy);
 
 int cpdma_ctlr_int_ctrl(struct cpdma_ctlr *ctlr, bool enable)
 {
@@ -528,6 +533,7 @@ err_chan_busy:
 err_chan_alloc:
 	return ERR_PTR(ret);
 }
+EXPORT_SYMBOL_GPL(cpdma_chan_create);
 
 int cpdma_chan_destroy(struct cpdma_chan *chan)
 {
@@ -545,6 +551,7 @@ int cpdma_chan_destroy(struct cpdma_chan *chan)
 	kfree(chan);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cpdma_chan_destroy);
 
 int cpdma_chan_get_stats(struct cpdma_chan *chan,
 			 struct cpdma_chan_stats *stats)
@@ -693,6 +700,7 @@ unlock_ret:
 	spin_unlock_irqrestore(&chan->lock, flags);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(cpdma_chan_submit);
 
 static void __cpdma_chan_free(struct cpdma_chan *chan,
 			      struct cpdma_desc __iomem *desc,
@@ -776,6 +784,7 @@ int cpdma_chan_process(struct cpdma_chan *chan, int quota)
 	}
 	return used;
 }
+EXPORT_SYMBOL_GPL(cpdma_chan_process);
 
 int cpdma_chan_start(struct cpdma_chan *chan)
 {
@@ -803,6 +812,7 @@ int cpdma_chan_start(struct cpdma_chan *chan)
 	spin_unlock_irqrestore(&chan->lock, flags);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cpdma_chan_start);
 
 int cpdma_chan_stop(struct cpdma_chan *chan)
 {
@@ -863,6 +873,7 @@ int cpdma_chan_stop(struct cpdma_chan *chan)
 	spin_unlock_irqrestore(&chan->lock, flags);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cpdma_chan_stop);
 
 int cpdma_chan_int_ctrl(struct cpdma_chan *chan, bool enable)
 {
-- 
1.7.5.4
