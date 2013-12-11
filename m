From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] net: eth: cpsw: 64-bit phys_addr_t and sparse cleanup
Date: Wed, 11 Dec 2013 15:58:07 -0800
Message-ID: <1386806287-6564-1-git-send-email-olof@lixom.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-omap@vger.kernel.org, Olof Johansson <olof@lixom.net>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Minor fix for printk format of a phys_addr_t, and the switch of two local
functions to static since they're not used outside of the file.

Signed-off-by: Olof Johansson <olof@lixom.net>
---

Missed this one with the previous 64-bit phys_addr_t fix. Feel free to
fold it in, or apply separately.


-Olof

 drivers/net/ethernet/ti/cpsw.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index c8a54f9..915eca9 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -582,7 +582,7 @@ static void cpsw_intr_disable(struct cpsw_priv *priv)
 	return;
 }
 
-void cpsw_tx_handler(void *token, int len, int status)
+static void cpsw_tx_handler(void *token, int len, int status)
 {
 	struct sk_buff		*skb = token;
 	struct net_device	*ndev = skb->dev;
@@ -599,7 +599,7 @@ void cpsw_tx_handler(void *token, int len, int status)
 	dev_kfree_skb_any(skb);
 }
 
-void cpsw_rx_handler(void *token, int len, int status)
+static void cpsw_rx_handler(void *token, int len, int status)
 {
 	struct sk_buff		*skb = token;
 	struct sk_buff		*new_skb;
@@ -2142,8 +2142,8 @@ static int cpsw_probe(struct platform_device *pdev)
 			  data->cpts_clock_mult, data->cpts_clock_shift))
 		dev_err(priv->dev, "error registering cpts device\n");
 
-	cpsw_notice(priv, probe, "initialized device (regs %x, irq %d)\n",
-		    ss_res->start, ndev->irq);
+	cpsw_notice(priv, probe, "initialized device (regs %pa, irq %d)\n",
+		    &ss_res->start, ndev->irq);
 
 	if (priv->data.dual_emac) {
 		ret = cpsw_probe_dual_emac(pdev, priv);
-- 
1.7.10.4
