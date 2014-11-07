From: Dong Aisheng <b29396@freescale.com>
Subject: [PATCH V4 1/3] can: add can_is_canfd_skb() API
Date: Fri, 7 Nov 2014 16:45:12 +0800
Message-ID: <1415349914-9145-1-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <mkl@pengutronix.de>, <wg@grandegger.com>,
	<varkabhadram@gmail.com>, <netdev@vger.kernel.org>,
	<socketcan@hartkopp.net>, <b29396@freescale.com>,
	<linux-arm-kernel@lists.infradead.org>
To: <linux-can@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CAN device drivers can use it to check if the frame to send is on
CAN FD mode or normal CAN mode.

Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>
Signed-off-by: Dong Aisheng <b29396@freescale.com>
---
ChangesLog:
 * v3->v4: add comments and change prototype a bit
 * v1->v2: change to skb->len == CANFD_MTU;
---
 include/linux/can/dev.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/linux/can/dev.h b/include/linux/can/dev.h
index 6992afc..b37ea95 100644
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
1.9.1

