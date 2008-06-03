From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 07/39] mv643xx_eth: delete unused port serial control register bit defines
Date: Tue,  3 Jun 2008 13:02:22 +0200
Message-ID: <1212490974-23719-8-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48744 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753613AbYFCMAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:25 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Over half of the port serial control register bit defines are never
used, and the PORT_SERIAL_CONTROL_DEFAULT_VALUE define is never used
either.  Keep only those defines that are actually used.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   78 +++++++++------------------------------------
 1 files changed, 15 insertions(+), 63 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 8287cf0..e4f0189 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -132,71 +132,23 @@ static char mv643xx_driver_version[] = "1.0";
 #error One of __BIG_ENDIAN or __LITTLE_ENDIAN must be defined
 #endif
 
-/* These macros describe Ethernet Port serial control reg (PSCR) bits */
-#define SERIAL_PORT_DISABLE			(0 << 0)
-#define SERIAL_PORT_ENABLE			(1 << 0)
-#define DO_NOT_FORCE_LINK_PASS			(0 << 1)
-#define FORCE_LINK_PASS				(1 << 1)
-#define ENABLE_AUTO_NEG_FOR_DUPLX		(0 << 2)
-#define DISABLE_AUTO_NEG_FOR_DUPLX		(1 << 2)
-#define ENABLE_AUTO_NEG_FOR_FLOW_CTRL		(0 << 3)
-#define DISABLE_AUTO_NEG_FOR_FLOW_CTRL		(1 << 3)
-#define ADV_NO_FLOW_CTRL			(0 << 4)
-#define ADV_SYMMETRIC_FLOW_CTRL			(1 << 4)
-#define FORCE_FC_MODE_NO_PAUSE_DIS_TX		(0 << 5)
-#define FORCE_FC_MODE_TX_PAUSE_DIS		(1 << 5)
-#define FORCE_BP_MODE_NO_JAM			(0 << 7)
-#define FORCE_BP_MODE_JAM_TX			(1 << 7)
-#define FORCE_BP_MODE_JAM_TX_ON_RX_ERR		(2 << 7)
-#define SERIAL_PORT_CONTROL_RESERVED		(1 << 9)
-#define FORCE_LINK_FAIL				(0 << 10)
-#define DO_NOT_FORCE_LINK_FAIL			(1 << 10)
-#define RETRANSMIT_16_ATTEMPTS			(0 << 11)
-#define RETRANSMIT_FOREVER			(1 << 11)
-#define ENABLE_AUTO_NEG_SPEED_GMII		(0 << 13)
-#define DISABLE_AUTO_NEG_SPEED_GMII		(1 << 13)
-#define DTE_ADV_0				(0 << 14)
-#define DTE_ADV_1				(1 << 14)
-#define DISABLE_AUTO_NEG_BYPASS			(0 << 15)
-#define ENABLE_AUTO_NEG_BYPASS			(1 << 15)
-#define AUTO_NEG_NO_CHANGE			(0 << 16)
-#define RESTART_AUTO_NEG			(1 << 16)
-#define MAX_RX_PACKET_1518BYTE			(0 << 17)
+
+/*
+ * Port serial control register.
+ */
+#define SET_MII_SPEED_TO_100			(1 << 24)
+#define SET_GMII_SPEED_TO_1000			(1 << 23)
+#define SET_FULL_DUPLEX_MODE			(1 << 21)
 #define MAX_RX_PACKET_1522BYTE			(1 << 17)
-#define MAX_RX_PACKET_1552BYTE			(2 << 17)
-#define MAX_RX_PACKET_9022BYTE			(3 << 17)
-#define MAX_RX_PACKET_9192BYTE			(4 << 17)
 #define MAX_RX_PACKET_9700BYTE			(5 << 17)
 #define MAX_RX_PACKET_MASK			(7 << 17)
-#define CLR_EXT_LOOPBACK			(0 << 20)
-#define SET_EXT_LOOPBACK			(1 << 20)
-#define SET_HALF_DUPLEX_MODE			(0 << 21)
-#define SET_FULL_DUPLEX_MODE			(1 << 21)
-#define DISABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX	(0 << 22)
-#define ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX	(1 << 22)
-#define SET_GMII_SPEED_TO_10_100		(0 << 23)
-#define SET_GMII_SPEED_TO_1000			(1 << 23)
-#define SET_MII_SPEED_TO_10			(0 << 24)
-#define SET_MII_SPEED_TO_100			(1 << 24)
-
-#define PORT_SERIAL_CONTROL_DEFAULT_VALUE		\
-		DO_NOT_FORCE_LINK_PASS		|	\
-		ENABLE_AUTO_NEG_FOR_DUPLX	|	\
-		DISABLE_AUTO_NEG_FOR_FLOW_CTRL	|	\
-		ADV_SYMMETRIC_FLOW_CTRL		|	\
-		FORCE_FC_MODE_NO_PAUSE_DIS_TX	|	\
-		FORCE_BP_MODE_NO_JAM		|	\
-		(1 << 9) /* reserved */		|	\
-		DO_NOT_FORCE_LINK_FAIL		|	\
-		RETRANSMIT_16_ATTEMPTS		|	\
-		ENABLE_AUTO_NEG_SPEED_GMII	|	\
-		DTE_ADV_0			|	\
-		DISABLE_AUTO_NEG_BYPASS		|	\
-		AUTO_NEG_NO_CHANGE		|	\
-		MAX_RX_PACKET_9700BYTE		|	\
-		CLR_EXT_LOOPBACK		|	\
-		SET_FULL_DUPLEX_MODE		|	\
-		ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX
+#define DISABLE_AUTO_NEG_SPEED_GMII		(1 << 13)
+#define DO_NOT_FORCE_LINK_FAIL			(1 << 10)
+#define SERIAL_PORT_CONTROL_RESERVED		(1 << 9)
+#define DISABLE_AUTO_NEG_FOR_FLOW_CTRL		(1 << 3)
+#define DISABLE_AUTO_NEG_FOR_DUPLEX		(1 << 2)
+#define FORCE_LINK_PASS				(1 << 1)
+#define SERIAL_PORT_ENABLE			(1 << 0)
 
 /* These macros describe Ethernet Serial Status reg (PSR) bits */
 #define PORT_STATUS_MODE_10_BIT		(1 << 0)
@@ -2187,7 +2139,7 @@ static void eth_port_start(struct net_device *dev)
 
 	pscr |= DISABLE_AUTO_NEG_FOR_FLOW_CTRL |
 		DISABLE_AUTO_NEG_SPEED_GMII    |
-		DISABLE_AUTO_NEG_FOR_DUPLX     |
+		DISABLE_AUTO_NEG_FOR_DUPLEX    |
 		DO_NOT_FORCE_LINK_FAIL	   |
 		SERIAL_PORT_CONTROL_RESERVED;
 
-- 
1.5.3.4

