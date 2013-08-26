From: Rob Gardner <robmatic@gmail.com>
Subject: [PATCH net,stable] net: usb: Add HP hs2434 device to ZLP exception
 table
Date: Sun, 25 Aug 2013 18:29:13 -0600
Message-ID: <20130825182913.2865aa1a8cefe329ab9c7a85@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org,
	=?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	Oliver Neukum <oliver@neukum.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:51706 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754162Ab3HZA3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Aug 2013 20:29:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 018343ce2e679d97283fb51da25c43aa876d087a Mon Sep 17 00:00:00 2001
From: Rob Gardner <robmatic@gmail.com>
Date: Sun, 25 Aug 2013 16:02:23 -0600
Subject: [PATCH net,stable] net: usb: Add HP hs2434 device to ZLP exception table

This patch adds another entry (HP hs2434 Mobile Broadband) to the list
of exceptional devices that require a zero length packet in order to
function properly. This list was added in commit 844e88f0. The hs2434
is manufactured by Sierra Wireless, who also produces the MC7710,
which the ZLP exception list was created for in the first place. So
hopefully it is just this one producer's devices that will need this
workaround.

Tested on a DM1-4310NR HP notebook, which does not function without this
change.

Signed-off-by: Rob Gardner <robmatic@gmail.com>
---
 drivers/net/usb/cdc_mbim.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index 8728198..25ba7ec 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -399,8 +399,12 @@ static const struct usb_device_id mbim_devs[] = {
 	/* Sierra Wireless MC7710 need ZLPs */
 	{ USB_DEVICE_AND_INTERFACE_INFO(0x1199, 0x68a2, USB_CLASS_COMM, USB_CDC_SUBCLASS_MBIM, USB_CDC_PROTO_NONE),
 	  .driver_info = (unsigned long)&cdc_mbim_info_zlp,
 	},
+	/* HP hs2434 Mobile Broadband Module needs ZLPs */
+	{ USB_DEVICE_AND_INTERFACE_INFO(0x3f0, 0x4b1d, USB_CLASS_COMM, USB_CDC_SUBCLASS_MBIM, USB_CDC_PROTO_NONE),
+	  .driver_info = (unsigned long)&cdc_mbim_info_zlp,
+	},
 	{ USB_INTERFACE_INFO(USB_CLASS_COMM, USB_CDC_SUBCLASS_MBIM, USB_CDC_PROTO_NONE),
 	  .driver_info = (unsigned long)&cdc_mbim_info,
 	},
 	{
-- 
1.7.9.5
