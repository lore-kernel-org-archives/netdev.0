From: Oliver Neukum <oneukum@suse.com>
Subject: [PATCH 1/2] kaweth: fix firmware download
Date: Wed, 17 Aug 2016 11:59:28 +0200
Message-ID: <1471427969-2355-1-git-send-email-oneukum@suse.com>
Cc: Oliver Neukum <oneukum@suse.com>
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, stern@rowland.harvard.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:52540 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751032AbcHQKGW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Aug 2016 06:06:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes the oops discovered by the Umap2 project and Alan Stern.
The intf member needs to be set before the firmware is downloaded.

Signed-off-by: Oliver Neukum <oneukum@suse.com>
---
 drivers/net/usb/kaweth.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index 770212b..37bf715 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -1029,6 +1029,7 @@ static int kaweth_probe(
 	kaweth = netdev_priv(netdev);
 	kaweth->dev = udev;
 	kaweth->net = netdev;
+	kaweth->intf = intf;
 
 	spin_lock_init(&kaweth->device_lock);
 	init_waitqueue_head(&kaweth->term_wait);
@@ -1139,8 +1140,6 @@ err_fw:
 
 	dev_dbg(dev, "Initializing net device.\n");
 
-	kaweth->intf = intf;
-
 	kaweth->tx_urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!kaweth->tx_urb)
 		goto err_free_netdev;
-- 
2.1.4
