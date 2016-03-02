From: Marek Vasut <marex@denx.de>
Subject: [PATCH 3/4] net: can: ifi: Fix RX and TX ID mask
Date: Wed,  2 Mar 2016 11:42:38 +0100
Message-ID: <1456915359-6775-4-git-send-email-marex@denx.de>
References: <1456915359-6775-1-git-send-email-marex@denx.de>
Cc: netdev@vger.kernel.org, Marek Vasut <marex@denx.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Mark Rutland <mark.rutland@arm.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>
To: linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1456915359-6775-1-git-send-email-marex@denx.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The RX and TX ID mask for CAN2.0 is 11 bits wide. This patch fixes
the incorrect mask, which caused the CAN IDs to miss the MSBit both
on receive and transmit.

Signed-off-by: Marek Vasut <marex@denx.de>
Cc: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Oliver Hartkopp <socketcan@hartkopp.net>
Cc: Wolfgang Grandegger <wg@grandegger.com>
---
V2: Use CAN_SFF_MASK instead of plain bitfield
    Use CAN_EFF_MASK for the extended frame format
---
 drivers/net/can/ifi_canfd/ifi_canfd.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/ifi_canfd/ifi_canfd.c b/drivers/net/can/ifi_canfd/ifi_canfd.c
index 4bbc7d9..238dd02 100644
--- a/drivers/net/can/ifi_canfd/ifi_canfd.c
+++ b/drivers/net/can/ifi_canfd/ifi_canfd.c
@@ -135,8 +135,8 @@
 
 #define IFI_CANFD_RXFIFO_ID			0x6c
 #define IFI_CANFD_RXFIFO_ID_ID_OFFSET		0
-#define IFI_CANFD_RXFIFO_ID_ID_STD_MASK		0x3ff
-#define IFI_CANFD_RXFIFO_ID_ID_XTD_MASK		0x1fffffff
+#define IFI_CANFD_RXFIFO_ID_ID_STD_MASK		CAN_SFF_MASK
+#define IFI_CANFD_RXFIFO_ID_ID_XTD_MASK		CAN_EFF_MASK
 #define IFI_CANFD_RXFIFO_ID_IDE			BIT(29)
 
 #define IFI_CANFD_RXFIFO_DATA			0x70	/* 0x70..0xac */
@@ -156,8 +156,8 @@
 
 #define IFI_CANFD_TXFIFO_ID			0xbc
 #define IFI_CANFD_TXFIFO_ID_ID_OFFSET		0
-#define IFI_CANFD_TXFIFO_ID_ID_STD_MASK		0x3ff
-#define IFI_CANFD_TXFIFO_ID_ID_XTD_MASK		0x1fffffff
+#define IFI_CANFD_TXFIFO_ID_ID_STD_MASK		CAN_SFF_MASK
+#define IFI_CANFD_TXFIFO_ID_ID_XTD_MASK		CAN_EFF_MASK
 #define IFI_CANFD_TXFIFO_ID_IDE			BIT(29)
 
 #define IFI_CANFD_TXFIFO_DATA			0xc0	/* 0xb0..0xfc */
-- 
2.7.0

