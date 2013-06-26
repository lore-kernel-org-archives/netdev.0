From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/10] e100: dump small buffers via %*ph
Date: Wed, 26 Jun 2013 03:55:16 -0700
Message-ID: <1372244122-17664-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1372244122-17664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61757 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751782Ab3FZKz1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 06:55:27 -0400
In-Reply-To: <1372244122-17664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e100.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index d2bea3f..68849cc 100644
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
+	netif_printk(nic, hw, KERN_DEBUG, nic->netdev, "[00-07]=%8ph\n",
+		     c + 0);
+	netif_printk(nic, hw, KERN_DEBUG, nic->netdev, "[08-15]=%8ph\n",
+		     c + 8);
+	netif_printk(nic, hw, KERN_DEBUG, nic->netdev, "[16-23]=%8ph\n",
+		     c + 16);
 	return 0;
 }
 
-- 
1.7.11.7
