From: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
Subject: [PATCH 02/14] [cdc_ether] Hardwire CDC descriptors when missing
Date: Sat, 26 Jan 2008 00:50:44 +0200
Message-ID: <20080125225044.11716.75749.stgit@fate.lan>
References: <20080125225032.11716.77713.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bjd-a1rhEgazXTw@public.gmane.org, david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080125225032.11716.77713.stgit-q/85JClnwdg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Bjorge Dijkstra <bjd-a1rhEgazXTw@public.gmane.org>

Just as ActiveSync devices, some regular RNDIS devices also lack
the CDC descriptors (e.g. devices based on BCM4320 WLAN chip).
This patch hardwires the CDC descriptors for all RNDIS style devices
when they are missing.

Signed-off-by: Bjorge Dijkstra <bjd-a1rhEgazXTw@public.gmane.org>
Signed-off-by: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
---

 drivers/net/usb/cdc_ether.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index a42acc3..97c17bb 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -228,15 +228,16 @@ next_desc:
 		buf += buf [0];
 	}
 
-	/* Microsoft ActiveSync based RNDIS devices lack the CDC descriptors,
-	 * so we'll hard-wire the interfaces and not check for descriptors.
+	/* Microsoft ActiveSync based and some regular RNDIS devices lack the
+	 * CDC descriptors, so we'll hard-wire the interfaces and not check
+	 * for descriptors.
 	 */
-	if (is_activesync(&intf->cur_altsetting->desc) && !info->u) {
+	if (rndis && !info->u) {
 		info->control = usb_ifnum_to_if(dev->udev, 0);
 		info->data = usb_ifnum_to_if(dev->udev, 1);
 		if (!info->control || !info->data) {
 			dev_dbg(&intf->dev,
-				"activesync: master #0/%p slave #1/%p\n",
+				"rndis: master #0/%p slave #1/%p\n",
 				info->control,
 				info->data);
 			goto bad_desc;
@@ -316,7 +317,6 @@ void usbnet_cdc_unbind(struct usbnet *dev, struct usb_interface *intf)
 }
 EXPORT_SYMBOL_GPL(usbnet_cdc_unbind);
 
-
 /*-------------------------------------------------------------------------
  *
  * Communications Device Class, Ethernet Control model
