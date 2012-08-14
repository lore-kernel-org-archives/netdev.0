From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 4/5] drivers/net/ethernet/ti/davinci_cpdma.c: Remove potential NULL dereference
Date: Tue, 14 Aug 2012 17:49:47 +0200
Message-ID: <1344959388-19719-5-git-send-email-Julia.Lawall@lip6.fr>
References: <1344959388-19719-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344959388-19719-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

If the NULL test is necessary, the initialization involving a dereference of
the tested value should be moved after the NULL test.

The sematic patch that fixes this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
type T;
expression E;
identifier i,fld;
statement S;
@@

- T i = E->fld;
+ T i;
  ... when != E
      when != i
  if (E == NULL) S
+ i = E->fld;
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/ethernet/ti/davinci_cpdma.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 3b5c457..d15c888 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -538,11 +538,12 @@ EXPORT_SYMBOL_GPL(cpdma_chan_create);
 
 int cpdma_chan_destroy(struct cpdma_chan *chan)
 {
-	struct cpdma_ctlr *ctlr = chan->ctlr;
+	struct cpdma_ctlr *ctlr;
 	unsigned long flags;
 
 	if (!chan)
 		return -EINVAL;
+	ctlr = chan->ctlr;
 
 	spin_lock_irqsave(&ctlr->lock, flags);
 	if (chan->state != CPDMA_STATE_IDLE)
