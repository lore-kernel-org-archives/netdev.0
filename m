From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v3 5/7] r8152: support the new chip 8050
Date: Tue, 28 Jun 2016 20:28:40 +0800
Message-ID: <1394712342-15778-203-Taiwan-albertk@realtek.com>
References: <1394712342-15778-184-Taiwan-albertk@realtek.com>
 <1394712342-15778-198-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-198-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Support a new chip which has the product ID 0x8050.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index df370e5..7227931 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -647,6 +647,7 @@ enum rtl_version {
 	RTL_VER_04,
 	RTL_VER_05,
 	RTL_VER_06,
+	RTL_VER_07,
 	RTL_VER_MAX
 };
 
@@ -3921,6 +3922,7 @@ static int rtl8152_get_coalesce(struct net_device *netdev,
 	switch (tp->version) {
 	case RTL_VER_01:
 	case RTL_VER_02:
+	case RTL_VER_07:
 		return -EOPNOTSUPP;
 	default:
 		break;
@@ -3940,6 +3942,7 @@ static int rtl8152_set_coalesce(struct net_device *netdev,
 	switch (tp->version) {
 	case RTL_VER_01:
 	case RTL_VER_02:
+	case RTL_VER_07:
 		return -EOPNOTSUPP;
 	default:
 		break;
@@ -4039,6 +4042,7 @@ static int rtl8152_change_mtu(struct net_device *dev, int new_mtu)
 	switch (tp->version) {
 	case RTL_VER_01:
 	case RTL_VER_02:
+	case RTL_VER_07:
 		return eth_change_mtu(dev, new_mtu);
 	default:
 		break;
@@ -4110,6 +4114,9 @@ static void r8152b_get_version(struct r8152 *tp)
 		tp->version = RTL_VER_06;
 		tp->mii.supports_gmii = 1;
 		break;
+	case 0x4800:
+		tp->version = RTL_VER_07;
+		break;
 	default:
 		netif_info(tp, probe, tp->netdev,
 			   "Unknown version 0x%04x\n", version);
@@ -4142,6 +4149,7 @@ static int rtl_ops_init(struct r8152 *tp)
 	switch (tp->version) {
 	case RTL_VER_01:
 	case RTL_VER_02:
+	case RTL_VER_07:
 		ops->init		= r8152b_init;
 		ops->enable		= rtl8152_enable;
 		ops->disable		= rtl8152_disable;
@@ -4339,6 +4347,7 @@ static void rtl8152_disconnect(struct usb_interface *intf)
 
 /* table of devices that work with this driver */
 static struct usb_device_id rtl8152_table[] = {
+	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8050)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8152)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8153)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_SAMSUNG, 0xa101)},
-- 
2.4.11
