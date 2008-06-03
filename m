From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 14/39] mv643xx_eth: remove port serial status register bit defines
Date: Tue,  3 Jun 2008 13:02:29 +0200
Message-ID: <1212490974-23719-15-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48748 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754233AbYFCMA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:27 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All except one of the port serial status register bit defines are
unused -- kill the unused ones.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   15 ++-------------
 1 files changed, 2 insertions(+), 13 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 075ee2a..34bfdf6 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -94,6 +94,7 @@ static char mv643xx_driver_version[] = "1.0";
 #define SDMA_CONFIG(p)			(0x041c + ((p) << 10))
 #define PORT_SERIAL_CONTROL(p)		(0x043c + ((p) << 10))
 #define PORT_STATUS(p)			(0x0444 + ((p) << 10))
+#define  TX_FIFO_EMPTY			0x00000400
 #define TXQ_COMMAND(p)			(0x0448 + ((p) << 10))
 #define TX_BW_MTU(p)			(0x0458 + ((p) << 10))
 #define INT_CAUSE(p)			(0x0460 + ((p) << 10))
@@ -160,18 +161,6 @@ static char mv643xx_driver_version[] = "1.0";
 #define PORT_DEFAULT_TRANSMIT_QUEUE_SIZE	800
 #define PORT_DEFAULT_RECEIVE_QUEUE_SIZE		400
 
-/* Port serial status reg (PSR) */
-#define ETH_INTERFACE_PCM			0x00000001
-#define ETH_LINK_IS_UP				0x00000002
-#define ETH_PORT_AT_FULL_DUPLEX			0x00000004
-#define ETH_RX_FLOW_CTRL_ENABLED		0x00000008
-#define ETH_GMII_SPEED_1000			0x00000010
-#define ETH_MII_SPEED_100			0x00000020
-#define ETH_TX_IN_PROGRESS			0x00000080
-#define ETH_BYPASS_ACTIVE			0x00000100
-#define ETH_PORT_AT_PARTITION_STATE		0x00000200
-#define ETH_PORT_TX_FIFO_EMPTY			0x00000400
-
 /* SMI reg */
 #define ETH_SMI_BUSY		0x10000000	/* 0 - Write, 1 - Read	*/
 #define ETH_SMI_READ_VALID	0x08000000	/* 0 - Write, 1 - Read	*/
@@ -462,7 +451,7 @@ static unsigned int mv643xx_eth_port_disable_tx(struct mv643xx_private *mp)
 			udelay(10);
 
 		/* Wait for Tx FIFO to empty */
-		while (rdl(mp, PORT_STATUS(port_num)) & ETH_PORT_TX_FIFO_EMPTY)
+		while (rdl(mp, PORT_STATUS(port_num)) & TX_FIFO_EMPTY)
 			udelay(10);
 	}
 
-- 
1.5.3.4

