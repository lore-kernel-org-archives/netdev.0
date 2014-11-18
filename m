From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 03/17] can: dev: add can_is_canfd_skb() API
Date: Tue, 18 Nov 2014 21:37:33 +0100
Message-ID: <1416343067-9810-4-git-send-email-mkl@pengutronix.de>
References: <1416343067-9810-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Dong Aisheng <b29396@freescale.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:47274 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754861AbaKRUh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 15:37:57 -0500
In-Reply-To: <1416343067-9810-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dong Aisheng <b29396@freescale.com>

The CAN device drivers can use can_is_canfd_skb() to check if the frame to send
is on CAN FD mode or normal CAN mode.

Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>
Signed-off-by: Dong Aisheng <b29396@freescale.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 include/linux/can/dev.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/linux/can/dev.h b/include/linux/can/dev.h
index 6992afc6ba7f..b37ea95bc348 100644
--- a/include/linux/can/dev.h
+++ b/include/linux/can/dev.h
@@ -99,6 +99,12 @@ inval_skb:
 	return 1;
 }
 
+static inline bool can_is_canfd_skb(const struct sk_buff *skb)
+{
+	/* the CAN specific type of skb is identified by its data length */
+	return skb->len == CANFD_MTU;
+}
+
 /* get data length from can_dlc with sanitized can_dlc */
 u8 can_dlc2len(u8 can_dlc);
 
-- 
2.1.3
