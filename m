From: Herbert Valerio Riedel <hvr@gnu.org>
Subject: [PATCH] au1000_eth.c: use ether_crc() from <linux/crc32.h>
Date: Mon, 1 May 2006 13:46:04 +0000 (UTC)
Message-ID: <E1FaYil-0007A8-HB@fencepost.gnu.org>
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
	sshtylyov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:2220 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S932103AbWEANpy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 May 2006 09:45:54 -0400
To: jgarzik@pobox.com
Date: Mon May 1 15:37:09 2006 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

since the au1000 driver already selects the CRC32 routines, simply replace
the internal ether_crc() implementation with the semantically equivalent
one from <linux/crc32.h>

Signed-off-by: Herbert Valerio Riedel <hvr@gnu.org>


---

 drivers/net/au1000_eth.c |   18 +-----------------
 1 files changed, 1 insertions(+), 17 deletions(-)

9360df5368deaaaa8fc7dcaacf9b7ca446af94c4
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 29adebb..0823cb8 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -52,6 +52,7 @@
 #include <linux/mii.h>
 #include <linux/skbuff.h>
 #include <linux/delay.h>
+#include <linux/crc32.h>
 #include <asm/mipsregs.h>
 #include <asm/irq.h>
 #include <asm/io.h>
@@ -2070,23 +2071,6 @@ static void au1000_tx_timeout(struct net
 	netif_wake_queue(dev);
 }
 
-
-static unsigned const ethernet_polynomial = 0x04c11db7U;
-static inline u32 ether_crc(int length, unsigned char *data)
-{
-    int crc = -1;
-
-    while(--length >= 0) {
-		unsigned char current_octet = *data++;
-		int bit;
-		for (bit = 0; bit < 8; bit++, current_octet >>= 1)
-			crc = (crc << 1) ^
-				((crc < 0) ^ (current_octet & 1) ? 
-				 ethernet_polynomial : 0);
-    }
-    return crc;
-}
-
 static void set_rx_mode(struct net_device *dev)
 {
 	struct au1000_private *aup = (struct au1000_private *) dev->priv;
-- 
1.2.6

