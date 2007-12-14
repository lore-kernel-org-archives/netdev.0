From: Joe Perches <joe@perches.com>
Subject: [PATCH 01/11] drivers/net/ax88796.c: Use print_mac
Date: Fri, 14 Dec 2007 14:34:02 -0800
Message-ID: <1197671652-32492-1-git-send-email-joe@perches.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Paul Gortmaker <p_gortmaker@yahoo.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4979 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752502AbXLNWeP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 17:34:15 -0500
Message-Id: <9fc484fc034428ab68ecb2711c8456df9e98d56d.1197671367.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ax88796.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
index 7495a9e..107c11f 100644
--- a/drivers/net/ax88796.c
+++ b/drivers/net/ax88796.c
@@ -750,14 +750,10 @@ static int ax_init_dev(struct net_device *dev, int first_init)
 	ax_NS8390_init(dev, 0);
 
 	if (first_init) {
-		printk("AX88796: %dbit, irq %d, %lx, MAC: ",
-		       ei_status.word16 ? 16:8, dev->irq, dev->base_addr);
-
-		for (i = 0; i < ETHER_ADDR_LEN; i++)
-			printk("%2.2x%c", dev->dev_addr[i],
-			       (i < (ETHER_ADDR_LEN-1) ? ':' : ' '));
-
-		printk("\n");
+		DECLARE_MAC_BUF(mac);
+		printk("AX88796: %dbit, irq %d, %lx, MAC: %s\n",
+		       ei_status.word16 ? 16:8, dev->irq, dev->base_addr,
+		       print_mac(mac, dev->dev_addr));
 	}
 
 	ret = register_netdev(dev);
-- 
1.5.3.7.949.g2221a6

