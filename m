From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] can: usb: PCAN-USB Pro: fix mem leaks in pcan_usb_pro_init()
 on error paths
Date: Wed, 11 Apr 2012 23:23:41 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1204112320310.2137@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephane Grosjean <s.grosjean@peak-system.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If either call to pcan_usb_pro_send_req() in
drivers/net/can/usb/peak_usb/pcan_usb_pro.c::pcan_usb_pro_init()
fails, we'll leak the memory we allocated to 'usb_if' with kzalloc()
when the 'usb_if' variable goes out of scope without having been
assigned to anything as we 'return err;'.
Fix this by adding appropriate kfree(usb_if) calls to the error paths.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/can/usb/peak_usb/pcan_usb_pro.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_pro.c b/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
index 5234586..629c4ba 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
@@ -875,6 +875,7 @@ static int pcan_usb_pro_init(struct peak_usb_device *dev)
 					    PCAN_USBPRO_INFO_FW,
 					    &fi, sizeof(fi));
 		if (err) {
+			kfree(usb_if);
 			dev_err(dev->netdev->dev.parent,
 				"unable to read %s firmware info (err %d)\n",
 				pcan_usb_pro.name, err);
@@ -885,6 +886,7 @@ static int pcan_usb_pro_init(struct peak_usb_device *dev)
 					    PCAN_USBPRO_INFO_BL,
 					    &bi, sizeof(bi));
 		if (err) {
+			kfree(usb_if);
 			dev_err(dev->netdev->dev.parent,
 				"unable to read %s bootloader info (err %d)\n",
 				pcan_usb_pro.name, err);
-- 
1.7.10



(please CC me on replies)


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

