From: Rabin Vincent <rabin-66gdRtMMWGc@public.gmane.org>
Subject: [PATCH] net: usb: cdc_eem: fix mtu
Date: Thu, 29 Mar 2012 22:45:15 +0530
Message-ID: <1333041315-4303-1-git-send-email-rabin@rab.in>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Rabin Vincent <rabin-66gdRtMMWGc@public.gmane.org>
To: oliver-Q6YOFhsQ4GZ7tPAFqOLdPg@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Make CDC EEM recalculate the hard_mtu after adjusting the
hard_header_len.

Without this, usbnet adjusts the MTU down to 1494 bytes, and the host is
unable to receive standard 1500-byte frames from the device.

Tested with the Linux USB Ethernet gadget.

Cc: Oliver Neukum <oliver-Q6YOFhsQ4GZ7tPAFqOLdPg@public.gmane.org>
Signed-off-by: Rabin Vincent <rabin-66gdRtMMWGc@public.gmane.org>
---
 drivers/net/usb/cdc_eem.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/cdc_eem.c b/drivers/net/usb/cdc_eem.c
index 882f53f..82d43b2 100644
--- a/drivers/net/usb/cdc_eem.c
+++ b/drivers/net/usb/cdc_eem.c
@@ -93,6 +93,7 @@ static int eem_bind(struct usbnet *dev, struct usb_interface *intf)
 	/* no jumbogram (16K) support for now */
 
 	dev->net->hard_header_len += EEM_HEAD + ETH_FCS_LEN;
+	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
 
 	return 0;
 }
-- 
1.7.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
