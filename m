From: Abhilash K V <abhilash.kv@ti.com>
Subject: [PATCH] can : TI_HECC : Unintialized variables
Date: Thu, 10 Mar 2011 21:51:27 +0530
Message-ID: <1299774087-8532-1-git-send-email-abhilash.kv@ti.com>
Cc: wg@grandegger.com, linux-omap@vger.kernel.org,
	Abhilash K V <abhilash.kv@ti.com>,
	Vaibhav Hiremath <hvaibhav@ti.com>
To: socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1. In ti_hecc_xmit(), "data" is not initialized, causing
   undesirable effects like setting the RTR field for every
   transmit.
2. In ti_hecc_probe(), the spinlock  priv->mbx_lock is not
   inited, causing a spinlock lockup BUG.

Signed-off-by: Vaibhav Hiremath <hvaibhav@ti.com>
Acked-by: Anant Gole <anantgole@ti.com>
Signed-off-by: Abhilash K V <abhilash.kv@ti.com>
---
 drivers/net/can/ti_hecc.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index 4d07f1e..73c6025 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -503,6 +503,7 @@ static netdev_tx_t ti_hecc_xmit(struct sk_buff *skb, struct net_device *ndev)
 	spin_unlock_irqrestore(&priv->mbx_lock, flags);
 
 	/* Prepare mailbox for transmission */
+	data = cf->can_dlc;
 	if (cf->can_id & CAN_RTR_FLAG) /* Remote transmission request */
 		data |= HECC_CANMCF_RTR;
 	data |= get_tx_head_prio(priv) << 8;
@@ -923,6 +924,7 @@ static int ti_hecc_probe(struct platform_device *pdev)
 	priv->can.do_get_state = ti_hecc_get_state;
 	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES;
 
+	spin_lock_init(&priv->mbx_lock);
 	ndev->irq = irq->start;
 	ndev->flags |= IFF_ECHO;
 	platform_set_drvdata(pdev, ndev);
-- 
1.6.2.4
