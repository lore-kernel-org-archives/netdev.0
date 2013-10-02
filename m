From: "Dr. H. Nikolaus Schaller" <hns@goldelico.com>
Subject: [PATCH 1/1] hso: fix problem with wrong status code sent by OPTION GTM601 during RING indication
Date: Wed, 2 Oct 2013 09:00:18 +0200
Message-ID: <B1808224-5850-41E3-9A8F-0F350F84FF89@goldelico.com>
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Belisko Marek <marek.belisko@gmail.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jan Dumon <j.dumon@option.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jan,

we are using a GTM601 modem (Firmware 1.7) for a while and have spotted an
issue that under some conditions the modem sends a packed wIndex over USB
that is rejected by the hso driver making troubles afterwards. Not rejecting makes
it work fine.

BR,
Nikolaus Schaller

---

>From f5c7e15b61f2ce4fe3105ff914f6bfaf5d74af0d Mon Sep 17 00:00:00 2001
From: "H. Nikolaus Schaller" <hns@goldelico.com>
Date: Thu, 15 Nov 2012 14:40:57 +0100
Subject: [PATCH 1/1] hso: fix problem with wrong status code sent by OPTION
 GTM601 during RING indication

 It has been observed that the GTM601 with 1.7 firmware sometimes sends a value
 wIndex that has bit 0x04 set instead of being reset as the code expects. So we
 mask it for the error check.
 
 See http://lists.goldelico.com/pipermail/gta04-owner/2012-February/001643.html

Signed-off-by: NeilBrown <neilb@suse.de>
Signed-off-by: H. Nikolaus Schaller <hns@goldelico.de>
---
 drivers/net/usb/hso.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index cba1d46..d146e26 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -1503,7 +1503,8 @@ static void tiocmget_intr_callback(struct urb *urb)
 	if (serial_state_notification->bmRequestType != BM_REQUEST_TYPE ||
 	    serial_state_notification->bNotification != B_NOTIFICATION ||
 	    le16_to_cpu(serial_state_notification->wValue) != W_VALUE ||
-	    le16_to_cpu(serial_state_notification->wIndex) != W_INDEX ||
+	    (le16_to_cpu(serial_state_notification->wIndex) & ~0x4) !=
+		W_INDEX ||
 	    le16_to_cpu(serial_state_notification->wLength) != W_LENGTH) {
 		dev_warn(&usb->dev,
 			 "hso received invalid serial state notification\n");
-- 
1.7.7.4
