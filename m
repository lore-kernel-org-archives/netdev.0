From: oliver@neukum.org
Subject: [PATCH] usbnet: fix deadlock in resume
Date: Mon, 27 Aug 2012 08:41:38 +0200
Message-ID: <1346049698-10740-1-git-send-email-oliver@neukum.org>
Cc: Oliver Neukum <oliver@neukum.org>, Oliver Neukum <oneukum@suse.de>,
	stable@kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org, ming.lei@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:37388 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896Ab2H0Gm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2012 02:42:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oliver@neukum.org>

A usbnet device can share a multifunction device
with a storage device. If the storage device is autoresumed
the usbnet devices also needs to be autoresumed. Allocating
memory with GFP_KERNEL can deadlock in this case.

This should go back into all kernels that have
commit 65841fd5132c3941cdf5df09e70df3ed28323212
That is 3.5

Signed-off-by: Oliver Neukum <oneukum@suse.de>
CC: stable@kernel.org
---
 drivers/net/usb/usbnet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 8531c1c..fd4b26d 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1573,7 +1573,7 @@ int usbnet_resume (struct usb_interface *intf)
 				netif_device_present(dev->net) &&
 				!timer_pending(&dev->delay) &&
 				!test_bit(EVENT_RX_HALT, &dev->flags))
-					rx_alloc_submit(dev, GFP_KERNEL);
+					rx_alloc_submit(dev, GFP_NOIO);
 
 			if (!(dev->txq.qlen >= TX_QLEN(dev)))
 				netif_tx_wake_all_queues(dev->net);
-- 
1.7.7
