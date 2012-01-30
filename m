From: Andrea Shepard <andrea@persephoneslair.org>
Subject: [09/22] Cyclades PC300 driver: use kzalloc() so we don't have to memset()
Date: Sun, 29 Jan 2012 18:50:50 -0800
Message-ID: <20120130025050.GJ10262@cronus.persephoneslair.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: khc@pm.waw.pl, davem@davemloft.net, mmarek@suse.cz,
	jkosina@suse.cz, joe@perches.com, justinmattock@gmail.com,
	gregkh@suse.de, alan@linux.intel.com, jdmason@kudzu.us
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cronus.persephoneslair.org ([216.254.15.24]:58061 "EHLO
	cronus.persephoneslair.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754198Ab2A3CvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2012 21:51:23 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use kzalloc() and avoid a memset().

Signed-off-by: Andrea Shepard <andrea@persephoneslair.org>

diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index f6da796..a8f3184 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -234,6 +234,7 @@ static char rcsid[] =
 #include <linux/etherdevice.h>
 #include <linux/spinlock.h>
 #include <linux/if.h>
+#include <linux/slab.h>
 #include <net/arp.h>
 
 #include <asm/io.h>
@@ -3572,14 +3573,13 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 #endif
 	}
 
-	card = (pc300_t *) kmalloc(sizeof(pc300_t), GFP_KERNEL);
+	card = kzalloc(sizeof(pc300_t), GFP_KERNEL);
 	if (card == NULL) {
 		printk("PC300 found at RAM 0x%08lx, "
 		       "but could not allocate card structure.\n",
 		       pci_resource_start(pdev, 3));
 		return -ENOMEM;
 	}
-	memset(card, 0, sizeof(pc300_t));
 
 	/* read PCI configuration area */
 	device_id = ent->device;
