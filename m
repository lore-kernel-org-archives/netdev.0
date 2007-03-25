From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw-mac80211: Fix NULL dereference on installer exit path
Date: Mon, 26 Mar 2007 00:18:39 +0100 (BST)
Message-ID: <20070325231839.AB6BA7B409F@zog.reactivated.net>
Cc: linux-wireless@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:9887 "EHLO
	mtaout03-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753367AbXCYXSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Mar 2007 19:18:44 -0400
Cc: netdev@vger.kernel.org
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When dealing with a DEVICE_INSTALLER, dev will be NULL when disconnect()
is called. This fixes a NULL dereference oops with such devices.

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 drivers/net/wireless/mac80211/zd1211rw/zd_usb.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c b/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
index 8867110..24d22dc 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
@@ -978,14 +978,17 @@ error:
 static void disconnect(struct usb_interface *intf)
 {
 	struct ieee80211_hw *dev = zd_intf_to_dev(intf);
-	struct zd_mac *mac = zd_dev_mac(dev);
-	struct zd_usb *usb = &mac->chip.usb;
+	struct zd_mac *mac;
+	struct zd_usb *usb;
 
 	/* Either something really bad happened, or we're just dealing with
 	 * a DEVICE_INSTALLER. */
 	if (dev == NULL)
 		return;
 
+	mac = zd_dev_mac(dev);
+	usb = &mac->chip.usb;
+
 	dev_dbg_f(zd_usb_dev(usb), "\n");
 
 	ieee80211_unregister_hw(dev);
-- 
1.5.0.5

