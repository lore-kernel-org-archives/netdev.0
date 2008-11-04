From: Jonathan McDowell <noodles@earth.li>
Subject: [PATCH] hso should register as a WWAN rfkill device, not WLAN
Date: Tue, 4 Nov 2008 11:11:18 +0000
Message-ID: <20081104111118.GQ3162@earth.li>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcel Holtmann <marcel@holtmann.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from the.earth.li ([217.147.81.2]:47327 "EHLO the.earth.li"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752442AbYKDLLU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2008 06:11:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the hso driver registers a WLAN rfkill switch, which is
intended for 802.11 wireless network devices. Given that this driver
supports GSM/HSPA devices it's more appropriate to register a WWAN
rfkill switch type.

Signed-Off-By: Jonathan McDowell <noodles@earth.li>

-----
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 1164c52..3f49e83 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2188,7 +2188,7 @@ static void hso_create_rfkill(struct hso_device *hso_dev,
 	char *rfkn;
 
 	hso_net->rfkill = rfkill_allocate(&interface_to_usbdev(interface)->dev,
-				 RFKILL_TYPE_WLAN);
+				 RFKILL_TYPE_WWAN);
 	if (!hso_net->rfkill) {
 		dev_err(dev, "%s - Out of memory\n", __func__);
 		return;
-----

J.

-- 
Revd. Jonathan McDowell, ULC | Settle down, Beavis.
