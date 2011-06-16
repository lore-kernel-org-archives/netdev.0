From: Manuel Zerpies <manuel.f.zerpies@ww.stud.uni-erlangen.de>
Subject: [PATCH 06/11] drivers/net: use printk_ratelimited() instead of
 printk_ratelimit()
Date: Thu, 16 Jun 2011 14:12:08 +0200
Message-ID: <bbe5954082599bcf65e9fdf565df8b9646ec3e3b.1308142053.git.manuel.f.zerpies__32049.0366816104$1308226369$gmane$org@ww.stud.uni-erlangen.de>
References: <cover.1308142053.git.manuel.f.zerpies@ww.stud.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: christian.dietrich@informatik.uni-erlangen.de
To: "David S. Miller" <davem@davemloft.net>,
	David Decotigny <decot@google.com>,
	"Hans J. Koch" <hjk@linutronix.de>, Jiri Kosina <jkosina@suse.cz>,
	Ben Pfaff <blp@cs.stanford.edu>, netdev
Return-path: <netdev-owner@vger.kernel.org>
Received: from faui40.informatik.uni-erlangen.de ([131.188.34.40]:40329 "EHLO
	faui40.informatik.uni-erlangen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757145Ab1FPMMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 08:12:10 -0400
Content-Disposition: inline
In-Reply-To: <cover.1308142053.git.manuel.f.zerpies@ww.stud.uni-erlangen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since printk_ratelimit() shouldn't be used anymore (see comment in
include/linux/printk.h), replace it with printk_ratelimited()

Signed-off-by: Manuel Zerpies <manuel.f.zerpies@ww.stud.uni-erlangen.de>
---
 drivers/net/sc92031.c |   16 ++++++----------
 1 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index fa74314..6f6bbb3 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -31,6 +31,7 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/crc32.h>
+#include <linux/ratelimit.h>
 
 #include <asm/irq.h>
 
@@ -536,8 +537,7 @@ static bool _sc92031_check_media(struct net_device *dev)
 
 		netif_carrier_on(dev);
 
-		if (printk_ratelimit())
-			printk(KERN_INFO "%s: link up, %sMbps, %s-duplex\n",
+		printk_ratelimited(KERN_INFO "%s: link up, %sMbps, %s-duplex\n",
 				dev->name,
 				speed_100 ? "100" : "10",
 				duplex_full ? "full" : "half");
@@ -549,8 +549,7 @@ static bool _sc92031_check_media(struct net_device *dev)
 
 		_sc92031_disable_tx_rx(dev);
 
-		if (printk_ratelimit())
-			printk(KERN_INFO "%s: link down\n", dev->name);
+		printk_ratelimited(KERN_INFO "%s: link down\n", dev->name);
 		return false;
 	}
 }
@@ -755,8 +754,7 @@ static void _sc92031_rx_tasklet(struct net_device *dev)
 		return;
 
 	if (unlikely(rx_len > RX_BUF_LEN)) {
-		if (printk_ratelimit())
-			printk(KERN_ERR "%s: rx packets length > rx buffer\n",
+		printk_ratelimited(KERN_ERR "%s: rx packets length > rx buffer\n",
 					dev->name);
 		return;
 	}
@@ -786,8 +784,7 @@ static void _sc92031_rx_tasklet(struct net_device *dev)
 		}
 
 		if (unlikely(rx_size_align + 4 > rx_len)) {
-			if (printk_ratelimit())
-				printk(KERN_ERR "%s: rx_len is too small\n", dev->name);
+			printk_ratelimited(KERN_ERR "%s: rx_len is too small\n", dev->name);
 			break;
 		}
 
@@ -795,8 +792,7 @@ static void _sc92031_rx_tasklet(struct net_device *dev)
 
 		skb = netdev_alloc_skb_ip_align(dev, pkt_size);
 		if (unlikely(!skb)) {
-			if (printk_ratelimit())
-				printk(KERN_ERR "%s: Couldn't allocate a skb_buff for a packet of size %u\n",
+			printk_ratelimited(KERN_ERR "%s: Couldn't allocate a skb_buff for a packet of size %u\n",
 						dev->name, pkt_size);
 			goto next;
 		}
-- 
1.7.4.1

