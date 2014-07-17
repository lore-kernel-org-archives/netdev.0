From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net,stable] net: huawei_cdc_ncm: add "subclass 3" devices
Date: Thu, 17 Jul 2014 13:34:09 +0200
Message-ID: <1405596849-11800-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Huawei's usage of the subclass and protocol fields is not 100%
clear to us, but there appears to be a very strict system.

A device with the "shared" device ID 12d1:1506 and this NCM
function was recently reported (showing only default altsetting):

    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        1
      bAlternateSetting       0
      bNumEndpoints           1
      bInterfaceClass       255 Vendor Specific Class
      bInterfaceSubClass      3
      bInterfaceProtocol     22
      iInterface              8 CDC Network Control Model (NCM)
      ** UNRECOGNIZED:  05 24 00 10 01
      ** UNRECOGNIZED:  06 24 1a 00 01 1f
      ** UNRECOGNIZED:  0c 24 1b 00 01 00 04 10 14 dc 05 20
      ** UNRECOGNIZED:  0d 24 0f 0a 0f 00 00 00 ea 05 03 00 01
      ** UNRECOGNIZED:  05 24 06 01 01
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x85  EP 5 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0010  1x 16 bytes
        bInterval               9

Cc: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/huawei_cdc_ncm.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/usb/huawei_cdc_ncm.c b/drivers/net/usb/huawei_=
cdc_ncm.c
index 5d95a13dbe2a..735f7dadb9a0 100644
--- a/drivers/net/usb/huawei_cdc_ncm.c
+++ b/drivers/net/usb/huawei_cdc_ncm.c
@@ -194,6 +194,9 @@ static const struct usb_device_id huawei_cdc_ncm_de=
vs[] =3D {
 	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x02, 0x76),
 	  .driver_info =3D (unsigned long)&huawei_cdc_ncm_info,
 	},
+	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x03, 0x16),
+	  .driver_info =3D (unsigned long)&huawei_cdc_ncm_info,
+	},
=20
 	/* Terminating entry */
 	{
--=20
2.0.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
