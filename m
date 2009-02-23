From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] hso: remove claiming and releasing of USB interface
Date: Mon, 23 Feb 2009 17:39:34 +0200
Message-ID: <20090223153932.8953.70790.stgit@Programuotojas>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: D.Barow@option.com
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-7-68-229.static.zebra.lt ([81.7.68.229]:37985 "EHLO
	teltonika.lt" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754928AbZBWPjj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Feb 2009 10:39:39 -0500
Received: from unknown (HELO [127.0.0.1]) (paulius.zaleckas@[217.147.39.138])
          (envelope-sender <paulius.zaleckas@teltonika.lt>)
          by teltonika.lt (qmail-ldap-1.03) with SMTP
          for <netdev@vger.kernel.org>; 23 Feb 2009 15:39:34 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to reclaim the same USB interface beeing probed.
Releasing interface does nothing also.

This is already in for a long time in off-kernel hso driver
and no regresions were noticed for this change.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Cc: Denis Joseph Barrow <D.Barow@option.com>
---

 drivers/net/usb/hso.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)


diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index fe98aca..a6bf488 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2979,8 +2979,6 @@ static int hso_probe(struct usb_interface *interface,
 		goto exit;
 	}
 
-	usb_driver_claim_interface(&hso_driver, interface, hso_dev);
-
 	/* save our data pointer in this device */
 	usb_set_intfdata(interface, hso_dev);
 
@@ -2998,8 +2996,6 @@ static void hso_disconnect(struct usb_interface *interface)
 
 	/* remove reference of our private data */
 	usb_set_intfdata(interface, NULL);
-
-	usb_driver_release_interface(&hso_driver, interface);
 }
 
 static void async_get_intf(struct work_struct *data)

