From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next] net: cdc_ether: silence sparse __CHECK_ENDIAN__ warning
Date: Wed, 17 Apr 2013 10:12:13 +0200
Message-ID: <1366186333-5378-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Ming Lei <ming.lei@canonical.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:43586 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965860Ab3DQIMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Apr 2013 04:12:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove warning introduced by commit 418fc57 ("usbnet: cdc-ether: apply
usbnet_link_change"):

   CHECK   .../drivers/net/usb/cdc_ether.c
 .../drivers/net/usb/cdc_ether.c:409:46: warning: incorrect type in arg=
ument 2 (different base types)
 .../drivers/net/usb/cdc_ether.c:409:46:    expected bool [unsigned] [u=
sertype] <noident>
 .../drivers/net/usb/cdc_ether.c:409:46:    got restricted __le16 [user=
type] wValue

Cc: Ming Lei <ming.lei@canonical.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ether.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index e965806..4ff71d6 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -406,7 +406,7 @@ void usbnet_cdc_status(struct usbnet *dev, struct u=
rb *urb)
 	case USB_CDC_NOTIFY_NETWORK_CONNECTION:
 		netif_dbg(dev, timer, dev->net, "CDC: carrier %s\n",
 			  event->wValue ? "on" : "off");
-		usbnet_link_change(dev, event->wValue, 0);
+		usbnet_link_change(dev, !!event->wValue, 0);
 		break;
 	case USB_CDC_NOTIFY_SPEED_CHANGE:	/* tx/rx rates */
 		netif_dbg(dev, timer, dev->net, "CDC: speed change (len %d)\n",
--=20
1.7.10.4
