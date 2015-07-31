From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next] r8152: disable the capability of zero length
Date: Fri, 31 Jul 2015 11:23:39 +0800
Message-ID: <1394712342-15778-165-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The UEFI driver would enable zero length, and the Linux driver doesn't
need it. Zero length let the hw complete the transfer with length 0,
when there is no received packet. It would add the load of USB host
controller and reduce the performance.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 57b72ec..348652a 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -339,6 +339,7 @@
 
 /* USB_USB_CTRL */
 #define RX_AGG_DISABLE		0x0010
+#define RX_ZERO_EN		0x0080
 
 /* USB_U2P3_CTRL */
 #define U2P3_ENABLE		0x0001
@@ -2705,7 +2706,7 @@ static void r8153_first_init(struct r8152 *tp)
 
 	/* rx aggregation */
 	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_USB_CTRL);
-	ocp_data &= ~RX_AGG_DISABLE;
+	ocp_data &= ~(RX_AGG_DISABLE | RX_ZERO_EN);
 	ocp_write_word(tp, MCU_TYPE_USB, USB_USB_CTRL, ocp_data);
 }
 
@@ -3227,7 +3228,7 @@ static void r8152b_init(struct r8152 *tp)
 
 	/* enable rx aggregation */
 	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_USB_CTRL);
-	ocp_data &= ~RX_AGG_DISABLE;
+	ocp_data &= ~(RX_AGG_DISABLE | RX_ZERO_EN);
 	ocp_write_word(tp, MCU_TYPE_USB, USB_USB_CTRL, ocp_data);
 }
 
-- 
2.4.2
