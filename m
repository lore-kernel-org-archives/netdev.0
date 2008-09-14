From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 3/5] mv643xx_eth: shrink default receive and transmit queue sizes
Date: Sun, 14 Sep 2008 19:14:27 +0200
Message-ID: <20080914171427.GE28798@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Nicolas Pitre <nico@cam.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:39749 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754000AbYINRO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2008 13:14:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the size of the receive queue is directly related to the data
cache footprint of the driver (between refilling a receive ring entry
with a fresh skb and receiving a packet in that entry, queue_size - 1
other skbs will have been touched), shrink the default receive queue
size to a saner number of entries, as 400 is definite overkill for
almost all workloads.

While we are at it, trim the default transmit queue size a bit as well.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 099e0be..4fbd62e 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -165,8 +165,8 @@ static char mv643xx_eth_driver_version[] = "1.3";
 #define FORCE_LINK_PASS				(1 << 1)
 #define SERIAL_PORT_ENABLE			(1 << 0)
 
-#define DEFAULT_RX_QUEUE_SIZE		400
-#define DEFAULT_TX_QUEUE_SIZE		800
+#define DEFAULT_RX_QUEUE_SIZE		128
+#define DEFAULT_TX_QUEUE_SIZE		256
 
 
 /*
-- 
1.5.6.4
