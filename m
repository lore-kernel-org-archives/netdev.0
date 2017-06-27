From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH net-next 1/3] net: ethernet: ti: cpsw: move skb timestamp to packet_submit
Date: Tue, 27 Jun 2017 16:58:51 +0300
Message-ID: <1498571933-3663-2-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1498571933-3663-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: grygorii.strashko@ti.com, linux-omap@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: m-karicheri2@ti.com, w-kwok2@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1498571933-3663-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move sw timestamp function close to channel submit function.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index b7a0f5e..422994e 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1236,6 +1236,7 @@ static inline int cpsw_tx_packet_submit(struct cpsw_priv *priv,
 {
 	struct cpsw_common *cpsw = priv->cpsw;
 
+	skb_tx_timestamp(skb);
 	return cpdma_chan_submit(txch, skb, skb->data, skb->len,
 				 priv->emac_port + cpsw->data.dual_emac);
 }
@@ -1611,8 +1612,6 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 	    cpts_is_tx_enabled(cpsw->cpts))
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 
-	skb_tx_timestamp(skb);
-
 	q_idx = skb_get_queue_mapping(skb);
 	if (q_idx >= cpsw->tx_ch_num)
 		q_idx = q_idx % cpsw->tx_ch_num;
-- 
2.7.4
