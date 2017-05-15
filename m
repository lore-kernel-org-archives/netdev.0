From: Oliver Neukum <oneukum@suse.com>
Subject: [PATCH] usbnet: no address filtering on RNDIS
Date: Mon, 15 May 2017 13:58:53 +0200
Message-ID: <20170515115853.32688-1-oneukum@suse.com>
Cc: Oliver Neukum <oneukum@suse.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:32999 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753875AbdEOMA1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 15 May 2017 08:00:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RNDIS does not do multicast filtering and the commands crash a few devices.
Make it conditional.

Fixes: b527caee1b91946db844b1dc63d4f726958891c8
Signed-off-by: Oliver Neukum <oneukum@suse.com>
Reported-by: "Ridgway, Keith" <kridgway@harris.com>
---
 drivers/net/usb/cdc_ether.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index f3ae88fdf332..64b1a6bdef98 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -313,9 +313,11 @@ int usbnet_generic_cdc_bind(struct usbnet *dev, struct usb_interface *intf)
 	/* Some devices don't initialise properly. In particular
 	 * the packet filter is not reset. There are devices that
 	 * don't do reset all the way. So the packet filter should
-	 * be set to a sane initial value.
+	 * be set to a sane initial value, if filtering is supported.
+	 * RNDIS does not support it.
 	 */
-	usbnet_cdc_update_filter(dev);
+	if (!rndis)
+		usbnet_cdc_update_filter(dev);
 
 	return 0;
 
-- 
2.12.0
