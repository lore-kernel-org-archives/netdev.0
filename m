From: Ian Coolidge <iancoolidge@gmail.com>
Subject: [PATCH v2 2/2] net: usb: cdc_eem: Fix rx skb allocation for 802.1Q VLANs
Date: Wed,  7 Nov 2012 16:39:19 -0800
Message-ID: <1352335159-8049-3-git-send-email-iancoolidge@gmail.com>
References: <1352335159-8049-1-git-send-email-iancoolidge@gmail.com>
Cc: Ian Coolidge <iancoolidge@gmail.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Felipe Balbi <balbi@ti.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:62658 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754632Ab2KHAiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 19:38:21 -0500
In-Reply-To: <1352335159-8049-1-git-send-email-iancoolidge@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cdc_eem frames might need to contain 802.1Q VLAN Ethernet frames.
URB/skb sizing from usbnet will default to the hard_mtu,
so account for the VLAN header by expanding that via hard_header_len

Signed-off-by: Ian Coolidge <iancoolidge@gmail.com>
---
 drivers/net/usb/cdc_eem.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/cdc_eem.c b/drivers/net/usb/cdc_eem.c
index c81e278..08d55b6 100644
--- a/drivers/net/usb/cdc_eem.c
+++ b/drivers/net/usb/cdc_eem.c
@@ -31,6 +31,7 @@
 #include <linux/usb/cdc.h>
 #include <linux/usb/usbnet.h>
 #include <linux/gfp.h>
+#include <linux/if_vlan.h>
 
 
 /*
@@ -92,7 +93,7 @@ static int eem_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	/* no jumbogram (16K) support for now */
 
-	dev->net->hard_header_len += EEM_HEAD + ETH_FCS_LEN;
+	dev->net->hard_header_len += EEM_HEAD + ETH_FCS_LEN + VLAN_HLEN;
 	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
 
 	return 0;
-- 
1.7.6.5
