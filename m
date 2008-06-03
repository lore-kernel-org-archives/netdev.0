From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 05/39] mv643xx_eth: get rid of individual port config extend register bit defines
Date: Tue,  3 Jun 2008 13:02:20 +0200
Message-ID: <1212490974-23719-6-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48743 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753018AbYFCMAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:25 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The port config extend register is never changed at run time.
Document the meaning of the initial value, and delete the defines
for the individual bits in this register.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   16 ++++------------
 1 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 38ba365..210e7cc 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -109,17 +109,6 @@ static char mv643xx_driver_version[] = "1.0";
 #define OTHER_MCAST_TABLE(p)		(0x1500 + ((p) << 10))
 #define UNICAST_TABLE(p)		(0x1600 + ((p) << 10))
 
-/* These macros describe Ethernet Port configuration extend reg (Px_cXR) bits*/
-#define CLASSIFY_EN				(1 << 0)
-#define SPAN_BPDU_PACKETS_AS_NORMAL		(0 << 1)
-#define SPAN_BPDU_PACKETS_TO_RX_QUEUE_7		(1 << 1)
-#define PARTITION_DISABLE			(0 << 2)
-#define PARTITION_ENABLE			(1 << 2)
-
-#define PORT_CONFIG_EXTEND_DEFAULT_VALUE		\
-		SPAN_BPDU_PACKETS_AS_NORMAL	|	\
-		PARTITION_DISABLE
-
 /* These macros describe Ethernet Port Sdma configuration reg (SDCR) bits */
 #define RIFB				(1 << 0)
 #define RX_BURST_SIZE_1_64BIT		(0 << 1)
@@ -2199,7 +2188,10 @@ static void eth_port_start(struct net_device *dev)
 	 */
 	wrl(mp, PORT_CONFIG(port_num), 0x00000000);
 
-	wrl(mp, PORT_CONFIG_EXT(port_num), PORT_CONFIG_EXTEND_DEFAULT_VALUE);
+	/*
+	 * Treat BPDUs as normal multicasts, and disable partition mode.
+	 */
+	wrl(mp, PORT_CONFIG_EXT(port_num), 0x00000000);
 
 	pscr = rdl(mp, PORT_SERIAL_CONTROL(port_num));
 
-- 
1.5.3.4

