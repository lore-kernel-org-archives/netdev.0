From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] rtlwifi: rtl8192cu: Fix NULL dereference BUG when using new_id
Date: Tue,  5 Feb 2013 18:00:23 -0600
Message-ID: <1360108823-5141-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:43244 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053Ab3BFAAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 19:00:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the new_id entry is used for a foreign USB device, rtlwifi BUGS with
a NULL pointer dereference.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>
---

John,

Although this patch should be backported to stable kernels, the new_id
feature is rarely used, thus the patch should not have any particular
priority.

Larry
---

 drivers/net/wireless/rtlwifi/usb.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlwifi/usb.c
index d42bbe2..77a7517 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -977,6 +977,9 @@ int rtl_usb_probe(struct usb_interface *intf,
 	rtl_dbgp_flag_init(hw);
 	/* Init IO handler */
 	_rtl_usb_io_handler_init(&udev->dev, hw);
+	if (!rtlpriv->cfg || !rtlpriv->cfg->ops ||
+	    !rtlpriv->cfg->ops->read_chip_version)
+		return -ENODEV;
 	rtlpriv->cfg->ops->read_chip_version(hw);
 	/*like read eeprom and so on */
 	rtlpriv->cfg->ops->read_eeprom_info(hw);
-- 
1.8.1
