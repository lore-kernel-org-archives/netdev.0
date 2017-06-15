From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 1/3] r8152: support new chip 8050
Date: Thu, 15 Jun 2017 14:44:02 +0800
Message-ID: <1394712342-15778-279-Taiwan-albertk@realtek.com>
References: <1394712342-15778-278-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-278-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The settings of the new chip are the same with RTL8152, except that
its product ID is 0x8050.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 5a02053..2744405 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -659,6 +659,7 @@ enum rtl_version {
 	RTL_VER_04,
 	RTL_VER_05,
 	RTL_VER_06,
+	RTL_VER_07,
 	RTL_VER_MAX
 };
 
@@ -4183,6 +4184,7 @@ static int rtl8152_get_coalesce(struct net_device *netdev,
 	switch (tp->version) {
 	case RTL_VER_01:
 	case RTL_VER_02:
+	case RTL_VER_07:
 		return -EOPNOTSUPP;
 	default:
 		break;
@@ -4202,6 +4204,7 @@ static int rtl8152_set_coalesce(struct net_device *netdev,
 	switch (tp->version) {
 	case RTL_VER_01:
 	case RTL_VER_02:
+	case RTL_VER_07:
 		return -EOPNOTSUPP;
 	default:
 		break;
@@ -4301,6 +4304,7 @@ static int rtl8152_change_mtu(struct net_device *dev, int new_mtu)
 	switch (tp->version) {
 	case RTL_VER_01:
 	case RTL_VER_02:
+	case RTL_VER_07:
 		dev->mtu = new_mtu;
 		return 0;
 	default:
@@ -4370,6 +4374,7 @@ static int rtl_ops_init(struct r8152 *tp)
 	switch (tp->version) {
 	case RTL_VER_01:
 	case RTL_VER_02:
+	case RTL_VER_07:
 		ops->init		= r8152b_init;
 		ops->enable		= rtl8152_enable;
 		ops->disable		= rtl8152_disable;
@@ -4448,6 +4453,9 @@ static u8 rtl_get_version(struct usb_interface *intf)
 	case 0x5c30:
 		version = RTL_VER_06;
 		break;
+	case 0x4800:
+		version = RTL_VER_07;
+		break;
 	default:
 		version = RTL_VER_UNKNOWN;
 		dev_info(&intf->dev, "Unknown version 0x%04x\n", ocp_data);
@@ -4493,6 +4501,7 @@ static int rtl8152_probe(struct usb_interface *intf,
 	switch (version) {
 	case RTL_VER_01:
 	case RTL_VER_02:
+	case RTL_VER_07:
 		tp->mii.supports_gmii = 0;
 		break;
 	default:
@@ -4627,6 +4636,7 @@ static void rtl8152_disconnect(struct usb_interface *intf)
 
 /* table of devices that work with this driver */
 static struct usb_device_id rtl8152_table[] = {
+	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8050)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8152)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8153)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_MICROSOFT, 0x07ab)},
-- 
2.7.4
