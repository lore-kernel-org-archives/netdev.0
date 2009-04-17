From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH -next 1/2] wan/pc300_drv: convert to net_device_ops
Date: Fri, 17 Apr 2009 05:23:02 +0400
Message-ID: <1239931383-30525-1-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:32483 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757370AbZDQBXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 21:23:07 -0400
Received: by fg-out-1718.google.com with SMTP id e12so223620fga.17
        for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 18:23:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/wan/pc300_drv.c |   22 ++++++++++++++--------
 1 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index c23fde0..df10a4c 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -225,6 +225,7 @@ static char rcsid[] =
 #include <linux/skbuff.h>
 #include <linux/if_arp.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/spinlock.h>
 #include <linux/if.h>
 #include <net/arp.h>
@@ -3246,6 +3247,18 @@ static inline void show_version(void)
 		rcsvers, rcsdate, __DATE__, __TIME__);
 }				/* show_version */
 
+static const struct net_device_ops cpc_netdev_ops = {
+	.ndo_init		= NULL,
+	.ndo_open		= cpc_open,
+	.ndo_stop		= cpc_close,
+	.ndo_tx_timeout		= cpc_tx_timeout,
+	.ndo_set_multicast_list	= NULL,
+	.ndo_set_mac_address	= NULL,
+	.ndo_change_mtu		= cpc_change_mtu,
+	.ndo_do_ioctl		= cpc_ioctl,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static void cpc_init_card(pc300_t * card)
 {
 	int i, devcount = 0;
@@ -3357,18 +3370,11 @@ static void cpc_init_card(pc300_t * card)
 		dev->mem_start = card->hw.ramphys;
 		dev->mem_end = card->hw.ramphys + card->hw.ramsize - 1;
 		dev->irq = card->hw.irq;
-		dev->init = NULL;
 		dev->tx_queue_len = PC300_TX_QUEUE_LEN;
 		dev->mtu = PC300_DEF_MTU;
 
-		dev->open = cpc_open;
-		dev->stop = cpc_close;
-		dev->tx_timeout = cpc_tx_timeout;
+		dev->netdev_ops = &cpc_netdev_ops;
 		dev->watchdog_timeo = PC300_TX_TIMEOUT;
-		dev->set_multicast_list = NULL;
-		dev->set_mac_address = NULL;
-		dev->change_mtu = cpc_change_mtu;
-		dev->do_ioctl = cpc_ioctl;
 
 		if (register_hdlc_device(dev) == 0) {
 			printk("%s: Cyclades-PC300/", dev->name);
-- 
1.6.2.3

