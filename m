From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 03/14] r8152: replace some types from int to bool
Date: Tue, 18 Feb 2014 21:49:00 +0800
Message-ID: <1392731351-25502-4-git-send-email-hayeswang@realtek.com>
References: <1392731351-25502-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392731351-25502-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Modify the following functions.
 - r8153_u1u2en
 - r8153_u2p3en
 - r8153_power_cut_en

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 2d5e761..4888e4f 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1989,7 +1989,7 @@ static void r8153_hw_phy_cfg(struct r8152 *tp)
 	sram_write(tp, SRAM_10M_AMP2, data);
 }
 
-static void r8153_u1u2en(struct r8152 *tp, int enable)
+static void r8153_u1u2en(struct r8152 *tp, bool enable)
 {
 	u8 u1u2[8];
 
@@ -2001,7 +2001,7 @@ static void r8153_u1u2en(struct r8152 *tp, int enable)
 	usb_ocp_write(tp, USB_TOLERANCE, BYTE_EN_SIX_BYTES, sizeof(u1u2), u1u2);
 }
 
-static void r8153_u2p3en(struct r8152 *tp, int enable)
+static void r8153_u2p3en(struct r8152 *tp, bool enable)
 {
 	u32 ocp_data;
 
@@ -2013,7 +2013,7 @@ static void r8153_u2p3en(struct r8152 *tp, int enable)
 	ocp_write_word(tp, MCU_TYPE_USB, USB_U2P3_CTRL, ocp_data);
 }
 
-static void r8153_power_cut_en(struct r8152 *tp, int enable)
+static void r8153_power_cut_en(struct r8152 *tp, bool enable)
 {
 	u32 ocp_data;
 
@@ -2261,8 +2261,8 @@ static void rtl8152_down(struct r8152 *tp)
 
 static void rtl8153_down(struct r8152 *tp)
 {
-	r8153_u1u2en(tp, 0);
-	r8153_power_cut_en(tp, 0);
+	r8153_u1u2en(tp, false);
+	r8153_power_cut_en(tp, false);
 	r8153_disable_aldps(tp);
 	r8153_enter_oob(tp);
 	r8153_enable_aldps(tp);
@@ -2455,7 +2455,7 @@ static void r8153_init(struct r8152 *tp)
 	u32 ocp_data;
 	int i;
 
-	r8153_u1u2en(tp, 0);
+	r8153_u1u2en(tp, false);
 
 	for (i = 0; i < 500; i++) {
 		if (ocp_read_word(tp, MCU_TYPE_PLA, PLA_BOOT_CTRL) &
@@ -2471,7 +2471,7 @@ static void r8153_init(struct r8152 *tp)
 		msleep(20);
 	}
 
-	r8153_u2p3en(tp, 0);
+	r8153_u2p3en(tp, false);
 
 	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_WDT11_CTRL);
 	ocp_data &= ~TIMER11_EN;
@@ -2496,8 +2496,8 @@ static void r8153_init(struct r8152 *tp)
 	ocp_data |= SEN_VAL_NORMAL | SEL_RXIDLE;
 	ocp_write_word(tp, MCU_TYPE_USB, USB_AFE_CTRL2, ocp_data);
 
-	r8153_power_cut_en(tp, 0);
-	r8153_u1u2en(tp, 1);
+	r8153_power_cut_en(tp, false);
+	r8153_u1u2en(tp, true);
 
 	r8153_first_init(tp);
 
@@ -2677,7 +2677,7 @@ static void rtl8152_unload(struct r8152 *tp)
 
 static void rtl8153_unload(struct r8152 *tp)
 {
-	r8153_power_cut_en(tp, 1);
+	r8153_power_cut_en(tp, true);
 }
 
 static int rtl_ops_init(struct r8152 *tp, const struct usb_device_id *id)
-- 
1.8.4.2
