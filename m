From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next] net: cdc_ncm: demote "unexpected notification" to debug level
Date: Mon,  8 Apr 2013 20:26:23 +0200
Message-ID: <1365445583-15124-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Alexey Orishko <alexey.orishko@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:50425 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756173Ab3DHS0o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Apr 2013 14:26:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Receiving unhandled notifications is most certainly not an error
and should not be logged as one.  Knowing that the device sends
notifications we don't handle is useful for developers, but there
is very little a user can do about this.  The message is therefore
just annoying noise to most users with devices sending unhandled
notifications like e.g. USB_CDC_NOTIFY_RESPONSE_AVAILABLE

Cc: Alexey Orishko <alexey.orishko@stericsson.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 44a989c..67012cb 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1124,8 +1124,9 @@ static void cdc_ncm_status(struct usbnet *dev, st=
ruct urb *urb)
 		break;
=20
 	default:
-		dev_err(&dev->udev->dev, "NCM: unexpected "
-			"notification 0x%02x!\n", event->bNotificationType);
+		dev_dbg(&dev->udev->dev,
+			"NCM: unexpected notification 0x%02x!\n",
+			event->bNotificationType);
 		break;
 	}
 }
--=20
1.7.10.4
