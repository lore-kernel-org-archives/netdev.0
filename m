From: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: [PATCH] usbnet: fix status interrupt urb handling
Date: Tue, 12 Nov 2013 16:34:41 +0100
Message-ID: <1384270481-30972-1-git-send-email-nbd@openwrt.org>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Since commit 7b0c5f21f348a66de495868b8df0284e8dfd6bbf
"sierra_net: keep status interrupt URB active", sierra_net triggers
status interrupt polling before the net_device is opened (in order to
properly receive the sync message response).

To be able to receive further interrupts, the interrupt urb needs to be
re-submitted, so this patch removes the bogus check for netif_running().

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
---
 drivers/net/usb/usbnet.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 90a429b..8494bb5 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -204,9 +204,6 @@ static void intr_complete (struct urb *urb)
 		break;
 	}
 
-	if (!netif_running (dev->net))
-		return;
