From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 3/8] [MV643XX_ETH] Disable RX/TX byte swapping on little-endian systems
Date: Fri, 19 Oct 2007 04:10:28 +0200
Message-ID: <20071019021028.GE16037@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Manas Saksena <msaksena@marvell.com>, netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:43995 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762440AbXJSCKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 22:10:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On little-endian systems, configure the SDMA unit with
MV643XX_ETH_BLM_RX_NO_SWAP and MV643XX_ETH_BLM_TX_NO_SWAP.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Acked-by: Tzachi Perelstein <tzachi@marvell.com>

Index: linux-2.6/drivers/net/mv643xx_eth.h
===================================================================
--- linux-2.6.orig/drivers/net/mv643xx_eth.h
+++ linux-2.6/drivers/net/mv643xx_eth.h
@@ -266,10 +266,21 @@
 
 #define	MV643XX_ETH_IPG_INT_RX(value) ((value & 0x3fff) << 8)
 
+#if defined(__BIG_ENDIAN)
 #define	MV643XX_ETH_PORT_SDMA_CONFIG_DEFAULT_VALUE		\
 		MV643XX_ETH_RX_BURST_SIZE_4_64BIT	|	\
 		MV643XX_ETH_IPG_INT_RX(0)		|	\
 		MV643XX_ETH_TX_BURST_SIZE_4_64BIT
+#elif defined(__LITTLE_ENDIAN)
+#define	MV643XX_ETH_PORT_SDMA_CONFIG_DEFAULT_VALUE		\
+		MV643XX_ETH_RX_BURST_SIZE_4_64BIT	|	\
+		MV643XX_ETH_BLM_RX_NO_SWAP		|	\
+		MV643XX_ETH_BLM_TX_NO_SWAP		|	\
+		MV643XX_ETH_IPG_INT_RX(0)		|	\
+		MV643XX_ETH_TX_BURST_SIZE_4_64BIT
+#else
+#error One of __BIG_ENDIAN or __LITTLE_ENDIAN must be defined
+#endif
 
 /* These macros describe Ethernet Port serial control reg (PSCR) bits */
 #define MV643XX_ETH_SERIAL_PORT_DISABLE			0
