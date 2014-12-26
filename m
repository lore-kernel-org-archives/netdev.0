From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 15/27] net: sxgbe: Use setup_timer
Date: Fri, 26 Dec 2014 15:35:46 +0100
Message-ID: <1419604558-29743-16-git-send-email-Julia.Lawall@lip6.fr>
References: <1419604558-29743-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, Girish K S <ks.giri@samsung.com>,
	Vipul Pandya <vipul.pandya@samsung.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Byungho An <bh74.an@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419604558-29743-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert a call to init_timer and accompanying intializations of
the timer's data and function fields to a call to setup_timer.

A simplified version of the semantic match that fixes this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression t,f,d;
@@

-init_timer(&t);
+setup_timer(&t,f,d);
-t.function = f;
-t.data = d;
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index 6984944..b6612d6 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -133,9 +133,8 @@ bool sxgbe_eee_init(struct sxgbe_priv_data * const priv)
 			return false;
 
 		priv->eee_active = 1;
-		init_timer(&priv->eee_ctrl_timer);
-		priv->eee_ctrl_timer.function = sxgbe_eee_ctrl_timer;
-		priv->eee_ctrl_timer.data = (unsigned long)priv;
+		setup_timer(&priv->eee_ctrl_timer, sxgbe_eee_ctrl_timer,
+			    (unsigned long)priv);
 		priv->eee_ctrl_timer.expires = SXGBE_LPI_TIMER(eee_timer);
 		add_timer(&priv->eee_ctrl_timer);
 
@@ -1009,10 +1008,9 @@ static void sxgbe_tx_init_coalesce(struct sxgbe_priv_data *priv)
 		struct sxgbe_tx_queue *p = priv->txq[queue_num];
 		p->tx_coal_frames =  SXGBE_TX_FRAMES;
 		p->tx_coal_timer = SXGBE_COAL_TX_TIMER;
-		init_timer(&p->txtimer);
+		setup_timer(&p->txtimer, sxgbe_tx_timer,
+			    (unsigned long)&priv->txq[queue_num]);
 		p->txtimer.expires = SXGBE_COAL_TIMER(p->tx_coal_timer);
-		p->txtimer.data = (unsigned long)&priv->txq[queue_num];
-		p->txtimer.function = sxgbe_tx_timer;
 		add_timer(&p->txtimer);
 	}
 }
