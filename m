From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 04/11] r8152: move the setting of rx aggregation
Date: Fri, 9 Jun 2017 17:11:41 +0800
Message-ID: <1394712342-15778-264-Taiwan-albertk@realtek.com>
References: <1394712342-15778-260-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-260-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the setting from r8153_first_init() to r8153_init(). It only needs to
be set once.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 9a794db..e569c48 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2961,11 +2961,6 @@ static void r8153_first_init(struct r8152 *tp)
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_RXFIFO_CTRL2, RXFIFO_THR3_NORMAL);
 	/* TX share fifo free credit full threshold */
 	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_TXFIFO_CTRL, TXFIFO_THR_NORMAL2);
-
-	/* rx aggregation */
-	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_USB_CTRL);
-	ocp_data &= ~(RX_AGG_DISABLE | RX_ZERO_EN);
-	ocp_write_word(tp, MCU_TYPE_USB, USB_USB_CTRL, ocp_data);
 }
 
 static void r8153_enter_oob(struct r8152 *tp)
@@ -3544,6 +3539,10 @@ static void r8153_init(struct r8152 *tp)
 	r8153_mac_clk_spd(tp, false);
 	usb_enable_lpm(tp->udev);
 
+	/* rx aggregation */
+	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_USB_CTRL);
+	ocp_data &= ~(RX_AGG_DISABLE | RX_ZERO_EN);
+	ocp_write_word(tp, MCU_TYPE_USB, USB_USB_CTRL, ocp_data);
 
 	rtl_tally_reset(tp);
 	r8153_u2p3en(tp, true);
-- 
2.7.4
