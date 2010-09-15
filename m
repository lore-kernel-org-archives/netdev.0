From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 5/9] tg3: Clarify semantics of TG3_IRQ_MAX_VECS
Date: Wed, 15 Sep 2010 11:59:57 -0700
Message-ID: <1284577201-6117-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3174 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755145Ab0IOTBH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 15:01:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TG3_IRQ_MAX_VECS should be seen as the maximum number of vectors that
any device could be expected to use.  tp->irq_max represents the maximum
number of vectors the current device can use.  This patch clarifies the
semantics of the code to match the above description.

Reviewed-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |    6 +++---
 drivers/net/tg3.h |    3 ++-
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4e92b81..7468479 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7564,7 +7564,7 @@ static void tg3_rings_reset(struct tg3 *tp)
 
 	/* Zero mailbox registers. */
 	if (tp->tg3_flags & TG3_FLAG_SUPPORT_MSIX) {
-		for (i = 1; i < TG3_IRQ_MAX_VECS; i++) {
+		for (i = 1; i < tp->irq_max; i++) {
 			tp->napi[i].tx_prod = 0;
 			tp->napi[i].tx_cons = 0;
 			if (tp->tg3_flags3 & TG3_FLG3_ENABLE_TSS)
@@ -9886,7 +9886,7 @@ static int tg3_set_ringparam(struct net_device *dev, struct ethtool_ringparam *e
 		tp->rx_pending = 63;
 	tp->rx_jumbo_pending = ering->rx_jumbo_pending;
 
-	for (i = 0; i < TG3_IRQ_MAX_VECS; i++)
+	for (i = 0; i < tp->irq_max; i++)
 		tp->napi[i].tx_pending = ering->tx_pending;
 
 	if (netif_running(dev)) {
@@ -14598,7 +14598,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	intmbx = MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW;
 	rcvmbx = MAILBOX_RCVRET_CON_IDX_0 + TG3_64BIT_REG_LOW;
 	sndmbx = MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW;
-	for (i = 0; i < TG3_IRQ_MAX_VECS; i++) {
+	for (i = 0; i < tp->irq_max; i++) {
 		struct tg3_napi *tnapi = &tp->napi[i];
 
 		tnapi->tp = tp;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 5cd0653..d39426f 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2659,7 +2659,8 @@ struct tg3_rx_prodring_set {
 	dma_addr_t			rx_jmb_mapping;
 };
 
-#define TG3_IRQ_MAX_VECS 5
+#define TG3_IRQ_MAX_VECS_RSS		5
+#define TG3_IRQ_MAX_VECS		TG3_IRQ_MAX_VECS_RSS
 
 struct tg3_napi {
 	struct napi_struct		napi	____cacheline_aligned;
-- 
1.7.1


