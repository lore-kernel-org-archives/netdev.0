From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 9/9] can: pch_can: don't copy data to rx'ed RTR frames
Date: Sat, 25 Dec 2010 15:40:34 +0100
Message-ID: <1293288034-22428-10-git-send-email-mkl@pengutronix.de>
References: <1293288034-22428-1-git-send-email-mkl@pengutronix.de>
Cc: socketcan-core@lists.berlios.de,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Tomoya <tomoya-linux@dsn.okisemi.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:57243 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670Ab0LYOkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Dec 2010 09:40:51 -0500
In-Reply-To: <1293288034-22428-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: Tomoya <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index c42e972..ee488ac 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -692,16 +692,17 @@ static int pch_can_rx_normal(struct net_device *ndev, u32 obj_num, int quota)
 			cf->can_id = id;
 		}
 
-		if (id2 & PCH_ID2_DIR)
-			cf->can_id |= CAN_RTR_FLAG;
-
 		cf->can_dlc = get_can_dlc((ioread32(&priv->regs->
 						    ifregs[0].mcont)) & 0xF);
 
-		for (i = 0; i < cf->can_dlc; i += 2) {
-			data_reg = ioread16(&priv->regs->ifregs[0].data[i / 2]);
-			cf->data[i] = data_reg;
-			cf->data[i + 1] = data_reg >> 8;
+		if (id2 & PCH_ID2_DIR) {
+			cf->can_id |= CAN_RTR_FLAG;
+
+			for (i = 0; i < cf->can_dlc; i += 2) {
+				data_reg = ioread16(&priv->regs->ifregs[0].data[i / 2]);
+				cf->data[i] = data_reg;
+				cf->data[i + 1] = data_reg >> 8;
+			}
 		}
 
 		netif_receive_skb(skb);
-- 
1.7.2.3

