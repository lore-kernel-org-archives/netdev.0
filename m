From: Tore Anderson <tore-E6HoIfKRxug@public.gmane.org>
Subject: [PATCH] net: cdc_mbim: apply "NDP to end" quirk to HP lt4132
Date: Sat,  1 Jul 2017 15:20:02 +0200
Message-ID: <20170701132002.2891-1-tore@fud.no>
Cc: Tore Anderson <tore-E6HoIfKRxug@public.gmane.org>
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The HP lt4132 LTE/HSPA+ 4G Module (03f0:a31d) is a rebranded Huawei
ME906s-158 device. It, like the ME906s-158, requires the "NDP to end"
quirk for correct operation.

Signed-off-by: Tore Anderson <tore-E6HoIfKRxug@public.gmane.org>
---
 drivers/net/usb/cdc_mbim.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index a6b997cffd3b..07e2a7824a00 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -643,6 +643,13 @@ static const struct usb_device_id mbim_devs[] = {
 	  .driver_info = (unsigned long)&cdc_mbim_info_ndp_to_end,
 	},
 
+	/* The HP lt4132 (03f0:a31d) is a rebranded Huawei ME906s-158,
+	 * therefore it too requires the above "NDP to end" quirk.
+	 */
+	{ USB_DEVICE_AND_INTERFACE_INFO(0x03f0, 0xa31d, USB_CLASS_COMM, USB_CDC_SUBCLASS_MBIM, USB_CDC_PROTO_NONE),
+	  .driver_info = (unsigned long)&cdc_mbim_info_ndp_to_end,
+	},
+
 	/* Telit LE922A6 in MBIM composition */
 	{ USB_DEVICE_AND_INTERFACE_INFO(0x1bc7, 0x1041, USB_CLASS_COMM, USB_CDC_SUBCLASS_MBIM, USB_CDC_PROTO_NONE),
 	  .driver_info = (unsigned long)&cdc_mbim_info_avoid_altsetting_toggle,
-- 
2.13.0

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
