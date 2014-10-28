From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 2/2] r8152: support nway_reset of ethtool
Date: Tue, 28 Oct 2014 14:05:52 +0800
Message-ID: <1394712342-15778-68-Taiwan-albertk@realtek.com>
References: <1394712342-15778-66-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-66-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Support the nway_reset() function for ethtool.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index fdea194..e1810bc 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3558,11 +3558,33 @@ out:
 	return ret;
 }
 
+static int rtl8152_nway_reset(struct net_device *dev)
+{
+	struct r8152 *tp = netdev_priv(dev);
+	int ret;
+
+	ret = usb_autopm_get_interface(tp->intf);
+	if (ret < 0)
+		goto out;
+
+	mutex_lock(&tp->control);
+
+	ret = mii_nway_restart(&tp->mii);
+
+	mutex_unlock(&tp->control);
+
+	usb_autopm_put_interface(tp->intf);
+
+out:
+	return ret;
+}
+
 static struct ethtool_ops ops = {
 	.get_drvinfo = rtl8152_get_drvinfo,
 	.get_settings = rtl8152_get_settings,
 	.set_settings = rtl8152_set_settings,
 	.get_link = ethtool_op_get_link,
+	.nway_reset = rtl8152_nway_reset,
 	.get_msglevel = rtl8152_get_msglevel,
 	.set_msglevel = rtl8152_set_msglevel,
 	.get_wol = rtl8152_get_wol,
-- 
1.9.3
