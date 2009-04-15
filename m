From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 13/26] lib82596: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:52:47 +0400
Message-ID: <1239835980-22502-13-git-send-email-a.beregalov@gmail.com>
References: <1239835980-22502-1-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-2-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-3-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-4-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-5-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-6-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-7-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-8-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-9-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-10-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-11-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-12-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:35264 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754838AbZDOWxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:22 -0400
Received: by fxm2 with SMTP id 2so121445fxm.37
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:19 -0700 (PDT)
In-Reply-To: <1239835980-22502-12-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/lib82596.c |   23 ++++++++++++++---------
 1 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/drivers/net/lib82596.c b/drivers/net/lib82596.c
index 7415f51..070fa45 100644
--- a/drivers/net/lib82596.c
+++ b/drivers/net/lib82596.c
@@ -1036,6 +1036,19 @@ static void print_eth(unsigned char *add, char *str)
 	printk(KERN_DEBUG "i596 0x%p, %pM --> %pM %02X%02X, %s\n",
 	       add, add + 6, add, add[12], add[13], str);
 }
+static const struct net_device_ops i596_netdev_ops = {
+	.ndo_open		= i596_open,
+	.ndo_stop		= i596_close,
+	.ndo_start_xmit		= i596_start_xmit,
+	.ndo_set_multicast_list	= set_multicast_list,
+	.ndo_tx_timeout		= i596_tx_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= i596_poll_controller,
+#endif
+};
 
 static int __devinit i82596_probe(struct net_device *dev)
 {
@@ -1062,16 +1075,8 @@ static int __devinit i82596_probe(struct net_device *dev)
 		return -ENOMEM;
 	}
 
-	/* The 82596-specific entries in the device structure. */
-	dev->open = i596_open;
-	dev->stop = i596_close;
-	dev->hard_start_xmit = i596_start_xmit;
-	dev->set_multicast_list = set_multicast_list;
-	dev->tx_timeout = i596_tx_timeout;
+	dev->netdev_ops = &i596_netdev_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = i596_poll_controller;
-#endif
 
 	memset(dma, 0, sizeof(struct i596_dma));
 	lp->dma = dma;
-- 
1.6.2.3

