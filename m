From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net] r8152: wake up the device before dumping the hw counter
Date: Tue, 8 Jul 2014 14:49:28 +0800
Message-ID: <1394712342-15778-5-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The device should be waked up from runtime suspend before dumping
the hw counter.

Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/r8152.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 2543196..a795ecf 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3204,8 +3204,13 @@ static void rtl8152_get_ethtool_stats(struct net_device *dev,
 	struct r8152 *tp = netdev_priv(dev);
 	struct tally_counter tally;
 
+	if (usb_autopm_get_interface(tp->intf) < 0)
+		return;
+
 	generic_ocp_read(tp, PLA_TALLYCNT, sizeof(tally), &tally, MCU_TYPE_PLA);
 
+	usb_autopm_put_interface(tp->intf);
+
 	data[0] = le64_to_cpu(tally.tx_packets);
 	data[1] = le64_to_cpu(tally.rx_packets);
 	data[2] = le64_to_cpu(tally.tx_errors);
-- 
1.9.3

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
