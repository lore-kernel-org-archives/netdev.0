From: Cyril Chemparathy <cyril@ti.com>
Subject: [PATCH 8/9] net: davinci_cpdma: add register dump routines
Date: Mon, 13 Sep 2010 14:07:30 -0400
Message-ID: <1284401251-8846-9-git-send-email-cyril@ti.com>
References: <1284401251-8846-1-git-send-email-cyril@ti.com>
Cc: michael.williamson@criticallink.com, caglarakyuz@gmail.com,
	bparrot@ti.com, Cyril Chemparathy <cyril@ti.com>
To: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-omap@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1284401251-8846-1-git-send-email-cyril@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds register dump routines at both controller and channel levels.
These are intended to be used in higher level driver debug dumps, e.g.
emac_dump_regs().

Signed-off-by: Cyril Chemparathy <cyril@ti.com>
Signed-off-by: Michael Williamson <michael.williamson@criticallink.com>
Signed-off-by: Caglar Akyuz <caglarakyuz@gmail.com>
---
 drivers/net/davinci_cpdma.c |  120 +++++++++++++++++++++++++++++++++++++++++++
 drivers/net/davinci_cpdma.h |    2 +
 2 files changed, 122 insertions(+), 0 deletions(-)

diff --git a/drivers/net/davinci_cpdma.c b/drivers/net/davinci_cpdma.c
index abc2b14..e92b2b6 100644
--- a/drivers/net/davinci_cpdma.c
+++ b/drivers/net/davinci_cpdma.c
@@ -91,6 +91,8 @@ enum cpdma_state {
 	CPDMA_STATE_TEARDOWN,
 };
 
+const char *cpdma_state_str[] = { "idle", "active", "teardown" };
+
 struct cpdma_ctlr {
 	enum cpdma_state	state;
 	struct cpdma_params	params;
@@ -345,6 +347,76 @@ int cpdma_ctlr_stop(struct cpdma_ctlr *ctlr)
 	return 0;
 }
 
+int cpdma_ctlr_dump(struct cpdma_ctlr *ctlr)
+{
+	struct device *dev = ctlr->dev;
+	unsigned long flags;
+	int i;
+
+	spin_lock_irqsave(&ctlr->lock, flags);
+
+	dev_info(dev, "CPDMA: state: %s", cpdma_state_str[ctlr->state]);
+
+	dev_info(dev, "CPDMA: txidver: %x",
+		 dma_reg_read(ctlr, CPDMA_TXIDVER));
+	dev_info(dev, "CPDMA: txcontrol: %x",
+		 dma_reg_read(ctlr, CPDMA_TXCONTROL));
+	dev_info(dev, "CPDMA: txteardown: %x",
+		 dma_reg_read(ctlr, CPDMA_TXTEARDOWN));
+	dev_info(dev, "CPDMA: rxidver: %x",
+		 dma_reg_read(ctlr, CPDMA_RXIDVER));
+	dev_info(dev, "CPDMA: rxcontrol: %x",
+		 dma_reg_read(ctlr, CPDMA_RXCONTROL));
+	dev_info(dev, "CPDMA: softreset: %x",
+		 dma_reg_read(ctlr, CPDMA_SOFTRESET));
+	dev_info(dev, "CPDMA: rxteardown: %x",
+		 dma_reg_read(ctlr, CPDMA_RXTEARDOWN));
+	dev_info(dev, "CPDMA: txintstatraw: %x",
+		 dma_reg_read(ctlr, CPDMA_TXINTSTATRAW));
+	dev_info(dev, "CPDMA: txintstatmasked: %x",
+		 dma_reg_read(ctlr, CPDMA_TXINTSTATMASKED));
+	dev_info(dev, "CPDMA: txintmaskset: %x",
+		 dma_reg_read(ctlr, CPDMA_TXINTMASKSET));
+	dev_info(dev, "CPDMA: txintmaskclear: %x",
+		 dma_reg_read(ctlr, CPDMA_TXINTMASKCLEAR));
+	dev_info(dev, "CPDMA: macinvector: %x",
+		 dma_reg_read(ctlr, CPDMA_MACINVECTOR));
+	dev_info(dev, "CPDMA: maceoivector: %x",
+		 dma_reg_read(ctlr, CPDMA_MACEOIVECTOR));
+	dev_info(dev, "CPDMA: rxintstatraw: %x",
+		 dma_reg_read(ctlr, CPDMA_RXINTSTATRAW));
+	dev_info(dev, "CPDMA: rxintstatmasked: %x",
+		 dma_reg_read(ctlr, CPDMA_RXINTSTATMASKED));
+	dev_info(dev, "CPDMA: rxintmaskset: %x",
+		 dma_reg_read(ctlr, CPDMA_RXINTMASKSET));
+	dev_info(dev, "CPDMA: rxintmaskclear: %x",
+		 dma_reg_read(ctlr, CPDMA_RXINTMASKCLEAR));
+	dev_info(dev, "CPDMA: dmaintstatraw: %x",
+		 dma_reg_read(ctlr, CPDMA_DMAINTSTATRAW));
+	dev_info(dev, "CPDMA: dmaintstatmasked: %x",
+		 dma_reg_read(ctlr, CPDMA_DMAINTSTATMASKED));
+	dev_info(dev, "CPDMA: dmaintmaskset: %x",
+		 dma_reg_read(ctlr, CPDMA_DMAINTMASKSET));
+	dev_info(dev, "CPDMA: dmaintmaskclear: %x",
+		 dma_reg_read(ctlr, CPDMA_DMAINTMASKCLEAR));
+
+	if (!ctlr->params.has_ext_regs) {
+		dev_info(dev, "CPDMA: dmacontrol: %x",
+			 dma_reg_read(ctlr, CPDMA_DMACONTROL));
+		dev_info(dev, "CPDMA: dmastatus: %x",
+			 dma_reg_read(ctlr, CPDMA_DMASTATUS));
+		dev_info(dev, "CPDMA: rxbuffofs: %x",
+			 dma_reg_read(ctlr, CPDMA_RXBUFFOFS));
+	}
+
+	for (i = 0; i < ARRAY_SIZE(ctlr->channels); i++)
+		if (ctlr->channels[i])
+			cpdma_chan_dump(ctlr->channels[i]);
+
+	spin_unlock_irqrestore(&ctlr->lock, flags);
+	return 0;
+}
+
 int cpdma_ctlr_destroy(struct cpdma_ctlr *ctlr)
 {
 	unsigned long flags;
@@ -481,6 +553,54 @@ int cpdma_chan_get_stats(struct cpdma_chan *chan,
 	return 0;
 }
 
+int cpdma_chan_dump(struct cpdma_chan *chan)
+{
+	unsigned long flags;
+	struct device *dev = chan->ctlr->dev;
+
+	spin_lock_irqsave(&chan->lock, flags);
+
+	dev_info(dev, "channel %d (%s %d) state %s",
+		 chan->chan_num, is_rx_chan(chan) ? "rx" : "tx",
+		 chan_linear(chan), cpdma_state_str[chan->state]);
+	dev_info(dev, "\thdp: %x\n", chan_read(chan, hdp));
+	dev_info(dev, "\tcp: %x\n", chan_read(chan, cp));
+	if (chan->rxfree) {
+		dev_info(dev, "\trxfree: %x\n",
+			 chan_read(chan, rxfree));
+	}
+
+	dev_info(dev, "\tstats head_enqueue: %d\n",
+		 chan->stats.head_enqueue);
+	dev_info(dev, "\tstats tail_enqueue: %d\n",
+		 chan->stats.tail_enqueue);
+	dev_info(dev, "\tstats pad_enqueue: %d\n",
+		 chan->stats.pad_enqueue);
+	dev_info(dev, "\tstats misqueued: %d\n",
+		 chan->stats.misqueued);
+	dev_info(dev, "\tstats desc_alloc_fail: %d\n",
+		 chan->stats.desc_alloc_fail);
+	dev_info(dev, "\tstats pad_alloc_fail: %d\n",
+		 chan->stats.pad_alloc_fail);
+	dev_info(dev, "\tstats runt_receive_buff: %d\n",
+		 chan->stats.runt_receive_buff);
+	dev_info(dev, "\tstats runt_transmit_buff: %d\n",
+		 chan->stats.runt_transmit_buff);
+	dev_info(dev, "\tstats empty_dequeue: %d\n",
+		 chan->stats.empty_dequeue);
+	dev_info(dev, "\tstats busy_dequeue: %d\n",
+		 chan->stats.busy_dequeue);
+	dev_info(dev, "\tstats good_dequeue: %d\n",
+		 chan->stats.good_dequeue);
+	dev_info(dev, "\tstats requeue: %d\n",
+		 chan->stats.requeue);
+	dev_info(dev, "\tstats teardown_dequeue: %d\n",
+		 chan->stats.teardown_dequeue);
+
+	spin_unlock_irqrestore(&chan->lock, flags);
+	return 0;
+}
+
 static void __cpdma_chan_submit(struct cpdma_chan *chan,
 				struct cpdma_desc __iomem *desc)
 {
diff --git a/drivers/net/davinci_cpdma.h b/drivers/net/davinci_cpdma.h
index 9baacca..868e50e 100644
--- a/drivers/net/davinci_cpdma.h
+++ b/drivers/net/davinci_cpdma.h
@@ -69,12 +69,14 @@ struct cpdma_ctlr *cpdma_ctlr_create(struct cpdma_params *params);
 int cpdma_ctlr_destroy(struct cpdma_ctlr *ctlr);
 int cpdma_ctlr_start(struct cpdma_ctlr *ctlr);
 int cpdma_ctlr_stop(struct cpdma_ctlr *ctlr);
+int cpdma_ctlr_dump(struct cpdma_ctlr *ctlr);
 
 struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
 				     cpdma_handler_fn handler);
 int cpdma_chan_destroy(struct cpdma_chan *chan);
 int cpdma_chan_start(struct cpdma_chan *chan);
 int cpdma_chan_stop(struct cpdma_chan *chan);
+int cpdma_chan_dump(struct cpdma_chan *chan);
 
 int cpdma_chan_get_stats(struct cpdma_chan *chan,
 			 struct cpdma_chan_stats *stats);
-- 
1.7.0.4

