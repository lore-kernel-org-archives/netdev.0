From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 4/5] net/davinci_cpdma: remove unused argument in cpdma_chan_submit()
Date: Wed, 17 Apr 2013 23:52:15 +0200
Message-ID: <1366235536-15744-5-git-send-email-bigeasy@linutronix.de>
References: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de>
Cc: netdev@vger.kernel.org, tglx@linutronix.de,
	"David S. Miller" <davem@davemloft.net>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:41220 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966828Ab3DQVwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 17:52:38 -0400
In-Reply-To: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The gfp_mask argument is not used in cpdma_chan_submit() and always set
to GFP_KERNEL even in atomic sections. This patch drops it since it is
unused.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/ethernet/ti/cpsw.c          |   10 +++++-----
 drivers/net/ethernet/ti/davinci_cpdma.c |    2 +-
 drivers/net/ethernet/ti/davinci_cpdma.h |    2 +-
 drivers/net/ethernet/ti/davinci_emac.c  |    6 +++---
 4 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index c32780d..559b020 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -503,7 +503,7 @@ void cpsw_rx_handler(void *token, int len, int status)
 			return;
 
 		ret = cpdma_chan_submit(priv->rxch, skb, skb->data,
-					skb_tailroom(skb), 0, GFP_KERNEL);
+					skb_tailroom(skb), 0);
 	}
 	WARN_ON(ret < 0);
 }
@@ -742,14 +742,14 @@ static inline int cpsw_tx_packet_submit(struct net_device *ndev,
 {
 	if (!priv->data.dual_emac)
 		return cpdma_chan_submit(priv->txch, skb, skb->data,
-				  skb->len, 0, GFP_KERNEL);
+				  skb->len, 0);
 
 	if (ndev == cpsw_get_slave_ndev(priv, 0))
 		return cpdma_chan_submit(priv->txch, skb, skb->data,
-				  skb->len, 1, GFP_KERNEL);
+				  skb->len, 1);
 	else
 		return cpdma_chan_submit(priv->txch, skb, skb->data,
-				  skb->len, 2, GFP_KERNEL);
+				  skb->len, 2);
 }
 
 static inline void cpsw_add_dual_emac_def_ale_entries(
@@ -923,7 +923,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 			if (!skb)
 				goto err_cleanup;
 			ret = cpdma_chan_submit(priv->rxch, skb, skb->data,
-					skb_tailroom(skb), 0, GFP_KERNEL);
+					skb_tailroom(skb), 0);
 			if (ret < 0) {
 				kfree_skb(skb);
 				goto err_cleanup;
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 3e34187..3cc20e7 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -676,7 +676,7 @@ static void __cpdma_chan_submit(struct cpdma_chan *chan,
 }
 
 int cpdma_chan_submit(struct cpdma_chan *chan, void *token, void *data,
-		      int len, int directed, gfp_t gfp_mask)
+		      int len, int directed)
 {
 	struct cpdma_ctlr		*ctlr = chan->ctlr;
 	struct cpdma_desc __iomem	*desc;
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.h b/drivers/net/ethernet/ti/davinci_cpdma.h
index d9bcc60..86dee48 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.h
+++ b/drivers/net/ethernet/ti/davinci_cpdma.h
@@ -89,7 +89,7 @@ int cpdma_chan_dump(struct cpdma_chan *chan);
 int cpdma_chan_get_stats(struct cpdma_chan *chan,
 			 struct cpdma_chan_stats *stats);
 int cpdma_chan_submit(struct cpdma_chan *chan, void *token, void *data,
-		      int len, int directed, gfp_t gfp_mask);
+		      int len, int directed);
 int cpdma_chan_process(struct cpdma_chan *chan, int quota);
 
 int cpdma_ctlr_int_ctrl(struct cpdma_ctlr *ctlr, bool enable);
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 1fd7260..f1daa4d 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1037,7 +1037,7 @@ static void emac_rx_handler(void *token, int len, int status)
 
 recycle:
 	ret = cpdma_chan_submit(priv->rxchan, skb, skb->data,
-			skb_tailroom(skb), 0, GFP_KERNEL);
+			skb_tailroom(skb), 0);
 
 	WARN_ON(ret == -ENOMEM);
 	if (unlikely(ret < 0))
@@ -1092,7 +1092,7 @@ static int emac_dev_xmit(struct sk_buff *skb, struct net_device *ndev)
 	skb_tx_timestamp(skb);
 
 	ret_code = cpdma_chan_submit(priv->txchan, skb, skb->data, skb->len,
-				     0, GFP_KERNEL);
+				     0);
 	if (unlikely(ret_code != 0)) {
 		if (netif_msg_tx_err(priv) && net_ratelimit())
 			dev_err(emac_dev, "DaVinci EMAC: desc submit failed");
@@ -1558,7 +1558,7 @@ static int emac_dev_open(struct net_device *ndev)
 			break;
 
 		ret = cpdma_chan_submit(priv->rxchan, skb, skb->data,
-					skb_tailroom(skb), 0, GFP_KERNEL);
+					skb_tailroom(skb), 0);
 		if (WARN_ON(ret < 0))
 			break;
 	}
-- 
1.7.10.4
