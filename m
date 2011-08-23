From: Abhilash K V <abhilash.kv@ti.com>
Subject: [PATCH] can: ti_hecc: Fix unintialized variable
Date: Tue, 23 Aug 2011 18:35:48 +0530
Message-ID: <1314104748-16424-1-git-send-email-abhilash.kv@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <wg@grandegger.com>, <linux-kernel@vger.kernel.org>,
	<=linux-omap@vger.kernel.org>, Abhilash K V <abhilash.kv@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In ti_hecc_xmit(), local variable "data" is not initialized before
being used.
This initialization got inadvertently removed in the following patch:

	can: Unify droping of invalid tx skbs and netdev stats

Acked-by: Anant Gole <anantgole@ti.com>
Signed-off-by: Abhilash K V <abhilash.kv@ti.com>
---
 drivers/net/can/ti_hecc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index f7bbde9..0b19a17 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -503,9 +503,9 @@ static netdev_tx_t ti_hecc_xmit(struct sk_buff *skb, struct net_device *ndev)
 	spin_unlock_irqrestore(&priv->mbx_lock, flags);
 
 	/* Prepare mailbox for transmission */
+	data = cf->can_dlc | (get_tx_head_prio(priv) << 8);
 	if (cf->can_id & CAN_RTR_FLAG) /* Remote transmission request */
 		data |= HECC_CANMCF_RTR;
-	data |= get_tx_head_prio(priv) << 8;
 	hecc_write_mbx(priv, mbxno, HECC_CANMCF, data);
 
 	if (cf->can_id & CAN_EFF_FLAG) /* Extended frame format */
-- 
1.6.2.4
