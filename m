From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 06/39] mv643xx_eth: delete unused SDMA config register bit defines
Date: Tue,  3 Jun 2008 13:02:21 +0200
Message-ID: <1212490974-23719-7-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48745 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753833AbYFCMAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:25 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Delete the defines for SDMA config register bit values that are
never used in the driver, to tidy up the code some more.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   21 ++++-----------------
 1 files changed, 4 insertions(+), 17 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 210e7cc..8287cf0 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -109,37 +109,24 @@ static char mv643xx_driver_version[] = "1.0";
 #define OTHER_MCAST_TABLE(p)		(0x1500 + ((p) << 10))
 #define UNICAST_TABLE(p)		(0x1600 + ((p) << 10))
 
-/* These macros describe Ethernet Port Sdma configuration reg (SDCR) bits */
-#define RIFB				(1 << 0)
-#define RX_BURST_SIZE_1_64BIT		(0 << 1)
-#define RX_BURST_SIZE_2_64BIT		(1 << 1)
+
+/*
+ * SDMA configuration register.
+ */
 #define RX_BURST_SIZE_4_64BIT		(2 << 1)
-#define RX_BURST_SIZE_8_64BIT		(3 << 1)
-#define RX_BURST_SIZE_16_64BIT		(4 << 1)
 #define BLM_RX_NO_SWAP			(1 << 4)
-#define BLM_RX_BYTE_SWAP		(0 << 4)
 #define BLM_TX_NO_SWAP			(1 << 5)
-#define BLM_TX_BYTE_SWAP		(0 << 5)
-#define DESCRIPTORS_BYTE_SWAP		(1 << 6)
-#define DESCRIPTORS_NO_SWAP		(0 << 6)
-#define IPG_INT_RX(value)		(((value) & 0x3fff) << 8)
-#define TX_BURST_SIZE_1_64BIT		(0 << 22)
-#define TX_BURST_SIZE_2_64BIT		(1 << 22)
 #define TX_BURST_SIZE_4_64BIT		(2 << 22)
-#define TX_BURST_SIZE_8_64BIT		(3 << 22)
-#define TX_BURST_SIZE_16_64BIT		(4 << 22)
 
 #if defined(__BIG_ENDIAN)
 #define PORT_SDMA_CONFIG_DEFAULT_VALUE		\
 		RX_BURST_SIZE_4_64BIT	|	\
-		IPG_INT_RX(0)		|	\
 		TX_BURST_SIZE_4_64BIT
 #elif defined(__LITTLE_ENDIAN)
 #define PORT_SDMA_CONFIG_DEFAULT_VALUE		\
 		RX_BURST_SIZE_4_64BIT	|	\
 		BLM_RX_NO_SWAP		|	\
 		BLM_TX_NO_SWAP		|	\
-		IPG_INT_RX(0)		|	\
 		TX_BURST_SIZE_4_64BIT
 #else
 #error One of __BIG_ENDIAN or __LITTLE_ENDIAN must be defined
-- 
1.5.3.4

