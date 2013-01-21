From: Wei Shuai <cpuwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/2] cdc_ncm: add support FLAG_NOARP for Infineon  modem platform
Date: Tue, 22 Jan 2013 00:00:32 +0800
Message-ID: <1358784032-3897-2-git-send-email-cpuwolf@gmail.com>
References: <1358784032-3897-1-git-send-email-cpuwolf@gmail.com>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Wei Shuai <cpuwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	peter-Y+HMSxxDrH8@public.gmane.org, oneukum-l3A5Bk7waGM@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org, bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1358784032-3897-1-git-send-email-cpuwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Infineon(now Intel) HSPA Modem platform NCM cannot support ARP.
we can define a new common structure wwan_noarp_info.
Then more similiar NO ARP devices can be handled easily


Signed-off-by: Wei Shuai <cpuwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 71b6e92..2d699b6 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1155,6 +1155,20 @@ static const struct driver_info wwan_info = {
 	.tx_fixup = cdc_ncm_tx_fixup,
 };
 
+/* Same as wwan_info, but with FLAG_NOARP  */
+static const struct driver_info wwan_noarp_info = {
+	.description = "Mobile Broadband Network Device (NO ARP)",
+	.flags = FLAG_POINTTOPOINT | FLAG_NO_SETINT | FLAG_MULTI_PACKET
+			| FLAG_WWAN | FLAG_NOARP,
+	.bind = cdc_ncm_bind,
+	.unbind = cdc_ncm_unbind,
+	.check_connect = cdc_ncm_check_connect,
+	.manage_power = usbnet_manage_power,
+	.status = cdc_ncm_status,
+	.rx_fixup = cdc_ncm_rx_fixup,
+	.tx_fixup = cdc_ncm_tx_fixup,
+};
+
 static const struct usb_device_id cdc_devs[] = {
 	/* Ericsson MBM devices like F5521gw */
 	{ .match_flags = USB_DEVICE_ID_MATCH_INT_INFO
@@ -1194,6 +1208,13 @@ static const struct usb_device_id cdc_devs[] = {
 	  .driver_info = (unsigned long)&wwan_info,
 	},
 
+	/* Infineon(now Intel) HSPA Modem platform */
+	{ USB_DEVICE_AND_INTERFACE_INFO(0x1519, 0x0443,
+		USB_CLASS_COMM,
+		USB_CDC_SUBCLASS_NCM, USB_CDC_PROTO_NONE),
+	  .driver_info = (unsigned long)&wwan_noarp_info,
+	},
+
 	/* Generic CDC-NCM devices */
 	{ USB_INTERFACE_INFO(USB_CLASS_COMM,
 		USB_CDC_SUBCLASS_NCM, USB_CDC_PROTO_NONE),
-- 
1.7.6.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
