From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 07/10] mv643xx_eth: use longer DMA bursts
Date: Wed, 16 Jul 2008 12:32:47 +0200
Message-ID: <20080716103247.GH8545@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:44738 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756581AbYGPKcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 06:32:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv643xx_eth driver is limiting DMA bursts to 32 bytes, while
using the largest burst size (128 bytes) gives a couple percentage
points performance improvement in throughput tests, and the docs
say that the 128 byte default should not need to be changed, so
use 128 byte bursts instead.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index c700c1f..9d20056 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -129,21 +129,21 @@ static char mv643xx_eth_driver_version[] = "1.1";
 /*
  * SDMA configuration register.
  */
-#define RX_BURST_SIZE_4_64BIT		(2 << 1)
+#define RX_BURST_SIZE_16_64BIT		(4 << 1)
 #define BLM_RX_NO_SWAP			(1 << 4)
 #define BLM_TX_NO_SWAP			(1 << 5)
-#define TX_BURST_SIZE_4_64BIT		(2 << 22)
+#define TX_BURST_SIZE_16_64BIT		(4 << 22)
 
 #if defined(__BIG_ENDIAN)
 #define PORT_SDMA_CONFIG_DEFAULT_VALUE		\
-		RX_BURST_SIZE_4_64BIT	|	\
-		TX_BURST_SIZE_4_64BIT
+		RX_BURST_SIZE_16_64BIT	|	\
+		TX_BURST_SIZE_16_64BIT
 #elif defined(__LITTLE_ENDIAN)
 #define PORT_SDMA_CONFIG_DEFAULT_VALUE		\
-		RX_BURST_SIZE_4_64BIT	|	\
+		RX_BURST_SIZE_16_64BIT	|	\
 		BLM_RX_NO_SWAP		|	\
 		BLM_TX_NO_SWAP		|	\
-		TX_BURST_SIZE_4_64BIT
+		TX_BURST_SIZE_16_64BIT
 #else
 #error One of __BIG_ENDIAN or __LITTLE_ENDIAN must be defined
 #endif
-- 
1.5.3.4
