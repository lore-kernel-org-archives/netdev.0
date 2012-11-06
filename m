From: Ian Coolidge <iancoolidge@gmail.com>
Subject: [PATCH 2/2] net: usb: cdc_eem: Fix rx skb allocation for 802.1Q VLANs
Date: Tue,  6 Nov 2012 13:00:11 -0800
Message-ID: <1352235611-13066-3-git-send-email-iancoolidge@gmail.com>
References: <1352235611-13066-1-git-send-email-iancoolidge@gmail.com>
Cc: Ian Coolidge <iancoolidge@gmail.com>
To: Oliver Neukum <oliver@neukum.name>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Felipe Balbi <balbi@ti.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:59714 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870Ab2KFU7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 15:59:23 -0500
In-Reply-To: <1352235611-13066-1-git-send-email-iancoolidge@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cdc_eem frames might need to contain 802.1Q VLAN Ethernet frames.
Provide this information as an override to usbnet->rx_urb_size

Signed-off-by: Ian Coolidge <iancoolidge@gmail.com>
---
 drivers/net/usb/cdc_eem.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/cdc_eem.c b/drivers/net/usb/cdc_eem.c
index 439690b..63c38dc 100644
--- a/drivers/net/usb/cdc_eem.c
+++ b/drivers/net/usb/cdc_eem.c
@@ -31,6 +31,7 @@
 #include <linux/usb/cdc.h>
 #include <linux/usb/usbnet.h>
 #include <linux/gfp.h>
+#include <linux/if_vlan.h>
 
 
 /*
@@ -94,6 +95,9 @@ static int eem_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	dev->net->hard_header_len += EEM_HEAD + ETH_FCS_LEN;
 
+	/* octets we need to rx for a single ethernet frame */
+	dev->rx_urb_size = EEM_HEAD + ETH_FCS_LEN + VLAN_ETH_FRAME_LEN;
+
 	return 0;
 }
 
-- 
1.7.6.5
