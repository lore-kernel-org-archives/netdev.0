From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net] r8152: fix the checking of the usb speed
Date: Thu, 24 Jul 2014 16:37:43 +0800
Message-ID: <1394712342-15778-15-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, <andrey.krieger.utkin@gmail.com>,
	Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the usb speed of the RTL8152 is not high speed, the USB_DEV_STAT[2:1]
should be equal to [0 1]. That is, the STAT_SPEED_FULL should be equal
to 2.

There is a easy way to check the usb speed by the speed field of the
struct usb_device. Use it to replace the original metheod.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
Spotted-by: Andrey Utkin <andrey.krieger.utkin@gmail.com>
---
 drivers/net/usb/r8152.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 7bad2d3..3eab74c 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -282,7 +282,7 @@
 /* USB_DEV_STAT */
 #define STAT_SPEED_MASK		0x0006
 #define STAT_SPEED_HIGH		0x0000
-#define STAT_SPEED_FULL		0x0001
+#define STAT_SPEED_FULL		0x0002
 
 /* USB_TX_AGG */
 #define TX_AGG_MAX_THRESHOLD	0x03
@@ -2292,9 +2292,8 @@ static void r8152b_exit_oob(struct r8152 *tp)
 	/* rx share fifo credit full threshold */
 	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RXFIFO_CTRL0, RXFIFO_THR1_NORMAL);
 
-	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_DEV_STAT);
-	ocp_data &= STAT_SPEED_MASK;
-	if (ocp_data == STAT_SPEED_FULL) {
+	if (tp->udev->speed == USB_SPEED_FULL ||
+	    tp->udev->speed == USB_SPEED_LOW) {
 		/* rx share fifo credit near full threshold */
 		ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RXFIFO_CTRL1,
 				RXFIFO_THR2_FULL);
-- 
1.9.3
