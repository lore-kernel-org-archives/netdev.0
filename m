From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net] r8152: remove the setting of LAN_WAKE_EN
Date: Wed, 6 Jul 2016 17:03:29 +0800
Message-ID: <1394712342-15778-208-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The LAN_WAKE_EN is not used to determine if the device could support
WOL. It is used to sigal a GPIO pin when a WOL event occurs. The WOL
still works even though it is disabled.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 0da72d3..419f4ce 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2296,10 +2296,6 @@ static u32 __rtl_get_wol(struct r8152 *tp)
 	u32 ocp_data;
 	u32 wolopts = 0;
 
-	ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_CONFIG5);
-	if (!(ocp_data & LAN_WAKE_EN))
-		return 0;
-
 	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_CONFIG34);
 	if (ocp_data & LINK_ON_WAKE_EN)
 		wolopts |= WAKE_PHY;
@@ -2332,15 +2328,13 @@ static void __rtl_set_wol(struct r8152 *tp, u32 wolopts)
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_CONFIG34, ocp_data);
 
 	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_CONFIG5);
-	ocp_data &= ~(UWF_EN | BWF_EN | MWF_EN | LAN_WAKE_EN);
+	ocp_data &= ~(UWF_EN | BWF_EN | MWF_EN);
 	if (wolopts & WAKE_UCAST)
 		ocp_data |= UWF_EN;
 	if (wolopts & WAKE_BCAST)
 		ocp_data |= BWF_EN;
 	if (wolopts & WAKE_MCAST)
 		ocp_data |= MWF_EN;
-	if (wolopts & WAKE_ANY)
-		ocp_data |= LAN_WAKE_EN;
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_CONFIG5, ocp_data);
 
 	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR, CRWECR_NORAML);
-- 
2.7.4
