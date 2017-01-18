From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH] net: ethernet: ti: davinci_cpdma: correct check on NULL in set rate
Date: Wed, 18 Jan 2017 02:28:06 +0200
Message-ID: <1484699286-6197-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: grygorii.strashko@ti.com, netdev@vger.kernel.org,
        linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check "ch" on NULL first, then get ctlr.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---

Based on net-next/master

 drivers/net/ethernet/ti/davinci_cpdma.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index d80bff1..7ecc6b7 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -835,8 +835,8 @@ EXPORT_SYMBOL_GPL(cpdma_chan_get_min_rate);
  */
 int cpdma_chan_set_rate(struct cpdma_chan *ch, u32 rate)
 {
-	struct cpdma_ctlr *ctlr = ch->ctlr;
 	unsigned long flags, ch_flags;
+	struct cpdma_ctlr *ctlr;
 	int ret, prio_mode;
 	u32 rmask;
 
@@ -846,6 +846,7 @@ int cpdma_chan_set_rate(struct cpdma_chan *ch, u32 rate)
 	if (ch->rate == rate)
 		return rate;
 
+	ctlr = ch->ctlr;
 	spin_lock_irqsave(&ctlr->lock, flags);
 	spin_lock_irqsave(&ch->lock, ch_flags);
 
-- 
2.7.4
