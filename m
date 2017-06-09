From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 02/11] r8152: adjust lpm settings for RTL8153
Date: Fri, 9 Jun 2017 17:11:39 +0800
Message-ID: <1394712342-15778-262-Taiwan-albertk@realtek.com>
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

Enable lpm after r8153_init() and remove other enable/disable lpm.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 9239dfb..b8c904f 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2263,7 +2263,6 @@ static int rtl8153_enable(struct r8152 *tp)
 	if (test_bit(RTL8152_UNPLUG, &tp->flags))
 		return -ENODEV;
 
-	usb_disable_lpm(tp->udev);
 	set_tx_qlen(tp);
 	rtl_set_eee_plus(tp);
 	r8153_set_rx_early_timeout(tp);
@@ -3003,7 +3002,6 @@ static void rtl8153_disable(struct r8152 *tp)
 	rtl_disable(tp);
 	rtl_reset_bmu(tp);
 	r8153_aldps_en(tp, true);
-	usb_enable_lpm(tp->udev);
 }
 
 static int rtl8152_set_speed(struct r8152 *tp, u8 autoneg, u16 speed, u8 duplex)
@@ -3127,7 +3125,6 @@ static void rtl8153_up(struct r8152 *tp)
 	r8153_aldps_en(tp, true);
 	r8153_u2p3en(tp, true);
 	r8153_u1u2en(tp, true);
-	usb_enable_lpm(tp->udev);
 }
 
 static void rtl8153_down(struct r8152 *tp)
@@ -3457,7 +3454,6 @@ static void r8153_init(struct r8152 *tp)
 
 	data = r8153_phy_status(tp, PHY_STAT_LAN_ON);
 
-	usb_disable_lpm(tp->udev);
 	r8153_u2p3en(tp, false);
 
 	if (tp->version == RTL_VER_04) {
@@ -3517,6 +3513,7 @@ static void r8153_init(struct r8152 *tp)
 
 	r8153_power_cut_en(tp, false);
 	r8153_u1u2en(tp, true);
+	usb_enable_lpm(tp->udev);
 
 	/* MAC clock speed down */
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MAC_PWR_CTRL, 0);
-- 
2.7.4
