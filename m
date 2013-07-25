From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH] e100: dump small buffers via %*phC
Date: Thu, 25 Jul 2013 14:24:19 +0300
Message-ID: <1374751459-17994-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: netdev@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:51383 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754994Ab3GYLYj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jul 2013 07:24:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is nice specifier in kernel that allows us to print small buffers easily.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/intel/e100.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 5115ae7..0da5911 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -1175,15 +1175,12 @@ static int e100_configure(struct nic *nic, struct cb *cb, struct sk_buff *skb)
 		config->rx_discard_short_frames = 0x0;  /* 1=discard, 0=save */
 	}
 
-	netif_printk(nic, hw, KERN_DEBUG, nic->netdev,
-		     "[00-07]=%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X\n",
-		     c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7]);
-	netif_printk(nic, hw, KERN_DEBUG, nic->netdev,
-		     "[08-15]=%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X\n",
-		     c[8], c[9], c[10], c[11], c[12], c[13], c[14], c[15]);
-	netif_printk(nic, hw, KERN_DEBUG, nic->netdev,
-		     "[16-23]=%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X\n",
-		     c[16], c[17], c[18], c[19], c[20], c[21], c[22], c[23]);
+	netif_printk(nic, hw, KERN_DEBUG, nic->netdev, "[00-07]=%8phC\n",
+		     c + 0);
+	netif_printk(nic, hw, KERN_DEBUG, nic->netdev, "[08-15]=%8phC\n",
+		     c + 8);
+	netif_printk(nic, hw, KERN_DEBUG, nic->netdev, "[16-23]=%8phC\n",
+		     c + 16);
 	return 0;
 }
 
-- 
1.8.3.2
