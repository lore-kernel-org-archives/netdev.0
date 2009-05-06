From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 3/5] mv643xx_eth: minor register definition cleanup
Date: Wed, 6 May 2009 15:01:17 +0200
Message-ID: <20090506130117.GH24429@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:40435 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753627AbZEFMyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 08:54:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the definitions for the SDMA and port serial configuration
register values to where all the other register definitions live,
and expand the shifts to 32 bit constants.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   44 +++++++++++++++++++++-----------------------
 1 files changed, 21 insertions(+), 23 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 92a867c..cc16f3e 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -88,7 +88,24 @@ static char mv643xx_eth_driver_version[] = "1.4";
 #define MAC_ADDR_LOW			0x0014
 #define MAC_ADDR_HIGH			0x0018
 #define SDMA_CONFIG			0x001c
+#define  TX_BURST_SIZE_16_64BIT		0x01000000
+#define  TX_BURST_SIZE_4_64BIT		0x00800000
+#define  BLM_TX_NO_SWAP			0x00000020
+#define  BLM_RX_NO_SWAP			0x00000010
+#define  RX_BURST_SIZE_16_64BIT		0x00000008
+#define  RX_BURST_SIZE_4_64BIT		0x00000004
 #define PORT_SERIAL_CONTROL		0x003c
+#define  SET_MII_SPEED_TO_100		0x01000000
+#define  SET_GMII_SPEED_TO_1000		0x00800000
+#define  SET_FULL_DUPLEX_MODE		0x00200000
+#define  MAX_RX_PACKET_9700BYTE		0x000a0000
+#define  DISABLE_AUTO_NEG_SPEED_GMII	0x00002000
+#define  DO_NOT_FORCE_LINK_FAIL		0x00000400
+#define  SERIAL_PORT_CONTROL_RESERVED	0x00000200
+#define  DISABLE_AUTO_NEG_FOR_FLOW_CTRL	0x00000008
+#define  DISABLE_AUTO_NEG_FOR_DUPLEX	0x00000004
+#define  FORCE_LINK_PASS		0x00000002
+#define  SERIAL_PORT_ENABLE		0x00000001
 #define PORT_STATUS			0x0044
 #define  TX_FIFO_EMPTY			0x00000400
 #define  TX_IN_PROGRESS			0x00000080
@@ -135,15 +152,8 @@ static char mv643xx_eth_driver_version[] = "1.4";
 
 
 /*
- * SDMA configuration register.
+ * SDMA configuration register default value.
  */
-#define RX_BURST_SIZE_4_64BIT		(2 << 1)
-#define RX_BURST_SIZE_16_64BIT		(4 << 1)
-#define BLM_RX_NO_SWAP			(1 << 4)
-#define BLM_TX_NO_SWAP			(1 << 5)
-#define TX_BURST_SIZE_4_64BIT		(2 << 22)
-#define TX_BURST_SIZE_16_64BIT		(4 << 22)
-
 #if defined(__BIG_ENDIAN)
 #define PORT_SDMA_CONFIG_DEFAULT_VALUE		\
 		(RX_BURST_SIZE_4_64BIT	|	\
@@ -160,22 +170,10 @@ static char mv643xx_eth_driver_version[] = "1.4";
 
 
 /*
- * Port serial control register.
+ * Misc definitions.
  */
-#define SET_MII_SPEED_TO_100			(1 << 24)
-#define SET_GMII_SPEED_TO_1000			(1 << 23)
-#define SET_FULL_DUPLEX_MODE			(1 << 21)
-#define MAX_RX_PACKET_9700BYTE			(5 << 17)
-#define DISABLE_AUTO_NEG_SPEED_GMII		(1 << 13)
-#define DO_NOT_FORCE_LINK_FAIL			(1 << 10)
-#define SERIAL_PORT_CONTROL_RESERVED		(1 << 9)
-#define DISABLE_AUTO_NEG_FOR_FLOW_CTRL		(1 << 3)
-#define DISABLE_AUTO_NEG_FOR_DUPLEX		(1 << 2)
-#define FORCE_LINK_PASS				(1 << 1)
-#define SERIAL_PORT_ENABLE			(1 << 0)
-
-#define DEFAULT_RX_QUEUE_SIZE		128
-#define DEFAULT_TX_QUEUE_SIZE		256
+#define DEFAULT_RX_QUEUE_SIZE	128
+#define DEFAULT_TX_QUEUE_SIZE	256
 
 
 /*
-- 
1.5.6.4
