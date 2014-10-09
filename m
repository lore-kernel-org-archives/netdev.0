From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next v2 1/3] r8152: autoresume before setting feature
Date: Thu, 9 Oct 2014 18:00:24 +0800
Message-ID: <1394712342-15778-61-Taiwan-albertk@realtek.com>
References: <1394712342-15778-58-Taiwan-albertk@realtek.com>
 <1394712342-15778-60-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394712342-15778-60-Taiwan-albertk-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Resume the device before setting the feature.

Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/r8152.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 5cfd414..c5afe8c 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2145,6 +2145,11 @@ static int rtl8152_set_features(struct net_device *dev,
 {
 	netdev_features_t changed = features ^ dev->features;
 	struct r8152 *tp = netdev_priv(dev);
+	int ret;
+
+	ret = usb_autopm_get_interface(tp->intf);
+	if (ret < 0)
+		goto out;
 
 	if (changed & NETIF_F_HW_VLAN_CTAG_RX) {
 		if (features & NETIF_F_HW_VLAN_CTAG_RX)
@@ -2153,7 +2158,10 @@ static int rtl8152_set_features(struct net_device *dev,
 			rtl_rx_vlan_en(tp, false);
 	}
 
-	return 0;
+	usb_autopm_put_interface(tp->intf);
+
+out:
+	return ret;
 }
 
 #define WAKE_ANY (WAKE_PHY | WAKE_MAGIC | WAKE_UCAST | WAKE_BCAST | WAKE_MCAST)
-- 
1.9.3

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
