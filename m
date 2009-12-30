From: Julia Lawall <julia@diku.dk>
Subject: Re: [PATCH 2/5] drivers/net : Correct the size argument to kzalloc
Date: Wed, 30 Dec 2009 15:34:04 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0912301533280.23134@ask.diku.dk>
References: <Pine.LNX.4.64.0912292015240.4001@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752869AbZL3OeK@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0912292015240.4001@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To: netdev@vger.kernel.org,linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

Subject: [PATCH 2/5] drivers/net : Correct the size argument to kzalloc


----------------------------

From: Julia Lawall <julia@diku.dk>

lp->rx_skb has type struct sk_buff **, not struct sk_buff *, so the
elements of the array should have pointer type, not structure type.

Convert kzalloc to kcalloc as well.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@disable sizeof_type_expr@
type T;
T **x;
@@

  x =
  <+...sizeof(
- T
+ *x
  )...+>
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/ll_temac_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -u -p a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -134,7 +134,7 @@ static int temac_dma_bd_init(struct net_
 	struct sk_buff *skb;
 	int i;
 
-	lp->rx_skb = kzalloc(sizeof(struct sk_buff)*RX_BD_NUM, GFP_KERNEL);
+	lp->rx_skb = kcalloc(RX_BD_NUM, sizeof(*lp->rx_skb), GFP_KERNEL);
 	/* allocate the tx and rx ring buffer descriptors. */
 	/* returns a virtual addres and a physical address. */
 	lp->tx_bd_v = dma_alloc_coherent(ndev->dev.parent,
