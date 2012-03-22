From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH 2/2] usbnet: don't clear urb->dev in tx_complete
Date: Thu, 22 Mar 2012 21:22:38 +0800
Message-ID: <1332422558-6633-1-git-send-email-tom.leiming@gmail.com>
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Ming Lei <tom.leiming@gmail.com>, stable@kernel.org,
	Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oliver@neukum.org>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:41821 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096Ab2CVNW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 09:22:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

URB unlinking is always racing with its completion and tx_complete
may be called before or during running usb_unlink_urb, so tx_complete
must not clear urb->dev since it will be used in unlink path,
otherwise invalid memory accesses or usb device leak may be caused
inside usb_unlink_urb.

Cc: stable@kernel.org
Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Oliver Neukum <oliver@neukum.org>
Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
 drivers/net/usb/usbnet.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index febfdce..62f8b5c 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1037,7 +1037,6 @@ static void tx_complete (struct urb *urb)
 	}
 
 	usb_autopm_put_interface_async(dev->intf);
-	urb->dev = NULL;
 	entry->state = tx_done;
 	defer_bh(dev, skb, &dev->txq);
 }
-- 
1.7.9.1
