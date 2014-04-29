From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH] net: sxgbe: Added set function for interrupt on complete
Date: Tue, 29 Apr 2014 13:15:27 +0900
Message-ID: <001d01cf6361$a675f6c0$f361e440$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ks.giri@samsung.com, vipul.pandya@samsung.com
To: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-language: ko
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch adds set_rx_int_on_com function for interrupt when
dma is completed.

Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.c |    7 +++++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h |    3 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c |    1 +
 3 files changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.c
index d71691b..2686bb5 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.c
@@ -233,6 +233,12 @@ static void sxgbe_set_rx_owner(struct sxgbe_rx_norm_desc *p)
 	p->rdes23.rx_rd_des23.own_bit = 1;
 }
 
+/* Set Interrupt on completion bit */
+static void sxgbe_set_rx_int_on_com(struct sxgbe_rx_norm_desc *p)
+{
+	p->rdes23.rx_rd_des23.int_on_com = 1;
+}
+
 /* Get the receive frame size */
 static int sxgbe_get_rx_frame_len(struct sxgbe_rx_norm_desc *p)
 {
@@ -498,6 +504,7 @@ static const struct sxgbe_desc_ops desc_ops = {
 	.init_rx_desc			= sxgbe_init_rx_desc,
 	.get_rx_owner			= sxgbe_get_rx_owner,
 	.set_rx_owner			= sxgbe_set_rx_owner,
+	.set_rx_int_on_com		= sxgbe_set_rx_int_on_com,
 	.get_rx_frame_len		= sxgbe_get_rx_frame_len,
 	.get_rx_fd_status		= sxgbe_get_rx_fd_status,
 	.get_rx_ld_status		= sxgbe_get_rx_ld_status,
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h b/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h
index 0226300..1860932 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h
@@ -258,6 +258,9 @@ struct sxgbe_desc_ops {
 	/* Set own bit */
 	void (*set_rx_owner)(struct sxgbe_rx_norm_desc *p);
 
+	/* Set Interrupt on completion bit */
+	void (*set_rx_int_on_com)(struct sxgbe_rx_norm_desc *p);
+
 	/* Get the receive frame size */
 	int (*get_rx_frame_len)(struct sxgbe_rx_norm_desc *p);
 
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index fd5c428..82a9a98 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -1456,6 +1456,7 @@ static void sxgbe_rx_refill(struct sxgbe_priv_data *priv)
 		/* Added memory barrier for RX descriptor modification */
 		wmb();
 		priv->hw->desc->set_rx_owner(p);
+		priv->hw->desc->set_rx_int_on_com(p);
 		/* Added memory barrier for RX descriptor modification */
 		wmb();
 	}
-- 
1.7.10.4
