From: Aleksander Morgado <aleksander@aleksander.es>
Subject: [PATCH v2] cdc_ncm: flag the u-blox TOBY-L4 as wwan
Date: Fri, 25 Aug 2017 15:39:16 +0200
Message-ID: <20170825133916.13948-1-aleksander@aleksander.es>
References: <20170825125946.12812-1-aleksander@aleksander.es>
Cc: stefano.godeas@u-blox.com, marco.demarco@u-blox.com,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org,
        Aleksander Morgado <aleksander@aleksander.es>
To: oliver@neukum.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170825125946.12812-1-aleksander@aleksander.es>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The u-blox TOBY-L4 is a LTE Advanced (Cat 6) module with HSPA+ and 2G
fallback.

Unlike the TOBY-L2, this module has one single USB layout and exposes
several TTYs for control and a NCM interface for data. Connecting this
module may be done just by activating the desired PDP context with
'AT+CGACT=1,<cid>' and then running DHCP on the NCM interface.

Signed-off-by: Aleksander Morgado <aleksander@aleksander.es>
---
 drivers/net/usb/cdc_ncm.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 811b18215cae..47cab1bde065 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1758,6 +1758,13 @@ static const struct usb_device_id cdc_devs[] = {
 	  .driver_info = (unsigned long)&wwan_noarp_info,
 	},

+	/* u-blox TOBY-L4 */
+	{ USB_DEVICE_AND_INTERFACE_INFO(0x1546, 0x1010,
+		USB_CLASS_COMM,
+		USB_CDC_SUBCLASS_NCM, USB_CDC_PROTO_NONE),
+	  .driver_info = (unsigned long)&wwan_info,
+	},
+
 	/* Generic CDC-NCM devices */
 	{ USB_INTERFACE_INFO(USB_CLASS_COMM,
 		USB_CDC_SUBCLASS_NCM, USB_CDC_PROTO_NONE),
--
2.14.1
