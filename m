From: Bing Zhao <bzhao@marvell.com>
Subject: [PATCH 3.14] mwifiex: rename usb driver name registerring to usb core
Date: Fri, 21 Feb 2014 12:23:00 -0800
Message-ID: <1393014180-16982-1-git-send-email-bzhao@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Yogesh Ashok Powar <yogeshp@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Frank Huang <frankh@marvell.com>, Bing Zhao <bzhao@marvell.com>
To: Fengguang Wu <fengguang.wu@intel.com>,
	<linux-wireless@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Both libertas USB driver and mwifiex_usb driver are registerring
with name 'usb8xxx'. The following conflict happens while trying
to load both drivers.

[6.211307] Error: Driver 'usb8xxx' is already registered...
[6.217261] mwifiex_usb: Driver register failed!

Fix it by renaming mwifiex_usb driver's name.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Bing Zhao <bzhao@marvell.com>
---
 drivers/net/wireless/mwifiex/usb.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/wireless/mwifiex/usb.c b/drivers/net/wireless/mwifiex/usb.c
index e8ebbd4..cb6b70a 100644
--- a/drivers/net/wireless/mwifiex/usb.c
+++ b/drivers/net/wireless/mwifiex/usb.c
@@ -22,8 +22,6 @@
 
 #define USB_VERSION	"1.0"
 
-static const char usbdriver_name[] = "usb8xxx";
-
 static struct mwifiex_if_ops usb_ops;
 static struct semaphore add_remove_card_sem;
 static struct usb_card_rec *usb_card;
@@ -567,7 +565,7 @@ static void mwifiex_usb_disconnect(struct usb_interface *intf)
 }
 
 static struct usb_driver mwifiex_usb_driver = {
-	.name = usbdriver_name,
+	.name = "mwifiex_usb",
 	.probe = mwifiex_usb_probe,
 	.disconnect = mwifiex_usb_disconnect,
 	.id_table = mwifiex_usb_table,
-- 
1.8.2.3
