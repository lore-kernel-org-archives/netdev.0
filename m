From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 11/39] mv643xx_eth: move PHY wait defines into callers
Date: Tue,  3 Jun 2008 13:02:26 +0200
Message-ID: <1212490974-23719-12-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48757 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756352AbYFCMAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:44 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   21 +++++++++------------
 1 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index ffdd3fc..b3f4fd8 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -160,9 +160,6 @@ static char mv643xx_driver_version[] = "1.0";
 #define PORT_DEFAULT_TRANSMIT_QUEUE_SIZE	800
 #define PORT_DEFAULT_RECEIVE_QUEUE_SIZE		400
 
-#define PHY_WAIT_ITERATIONS	1000	/* 1000 iterations * 10uS = 10mS max */
-#define PHY_WAIT_MICRO_SECONDS	10
-
 /* Buffer offset from buffer pointer */
 #define RX_BUF_OFFSET				0x2
 
@@ -475,7 +472,7 @@ static unsigned int mv643xx_eth_port_disable_rx(struct mv643xx_private *mp)
 		/* Wait for all Rx activity to terminate. */
 		/* Check port cause register that all Rx queues are stopped */
 		while (rdl(mp, RXQ_COMMAND(port_num)) & 0xFF)
-			udelay(PHY_WAIT_MICRO_SECONDS);
+			udelay(10);
 	}
 
 	return queues;
@@ -501,11 +498,11 @@ static unsigned int mv643xx_eth_port_disable_tx(struct mv643xx_private *mp)
 		/* Wait for all Tx activity to terminate. */
 		/* Check port cause register that all Tx queues are stopped */
 		while (rdl(mp, TXQ_COMMAND(port_num)) & 0xFF)
-			udelay(PHY_WAIT_MICRO_SECONDS);
+			udelay(10);
 
 		/* Wait for Tx FIFO to empty */
 		while (rdl(mp, PORT_STATUS(port_num)) & ETH_PORT_TX_FIFO_EMPTY)
-			udelay(PHY_WAIT_MICRO_SECONDS);
+			udelay(10);
 	}
 
 	return queues;
@@ -1058,11 +1055,11 @@ static void eth_port_read_smi_reg(struct mv643xx_private *mp,
 
 	/* wait for the SMI register to become available */
 	for (i = 0; readl(smi_reg) & ETH_SMI_BUSY; i++) {
-		if (i == PHY_WAIT_ITERATIONS) {
+		if (i == 1000) {
 			printk("%s: PHY busy timeout\n", mp->dev->name);
 			goto out;
 		}
-		udelay(PHY_WAIT_MICRO_SECONDS);
+		udelay(10);
 	}
 
 	writel((phy_addr << 16) | (phy_reg << 21) | ETH_SMI_OPCODE_READ,
@@ -1070,11 +1067,11 @@ static void eth_port_read_smi_reg(struct mv643xx_private *mp,
 
 	/* now wait for the data to be valid */
 	for (i = 0; !(readl(smi_reg) & ETH_SMI_READ_VALID); i++) {
-		if (i == PHY_WAIT_ITERATIONS) {
+		if (i == 1000) {
 			printk("%s: PHY read timeout\n", mp->dev->name);
 			goto out;
 		}
-		udelay(PHY_WAIT_MICRO_SECONDS);
+		udelay(10);
 	}
 
 	*value = readl(smi_reg) & 0xffff;
@@ -1115,11 +1112,11 @@ static void eth_port_write_smi_reg(struct mv643xx_private *mp,
 
 	/* wait for the SMI register to become available */
 	for (i = 0; readl(smi_reg) & ETH_SMI_BUSY; i++) {
-		if (i == PHY_WAIT_ITERATIONS) {
+		if (i == 1000) {
 			printk("%s: PHY busy timeout\n", mp->dev->name);
 			goto out;
 		}
-		udelay(PHY_WAIT_MICRO_SECONDS);
+		udelay(10);
 	}
 
 	writel((phy_addr << 16) | (phy_reg << 21) |
-- 
1.5.3.4

