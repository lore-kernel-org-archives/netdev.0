From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next] r8152: nway reset after setting eee
Date: Thu, 2 Oct 2014 16:01:22 +0800
Message-ID: <1394712342-15778-54-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Restart autonegotiation is necessary after setting EEE.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index a4d4c4a..e4dcfc1 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3480,6 +3480,9 @@ rtl_ethtool_set_eee(struct net_device *net, struct ethtool_eee *edata)
 
 	ret = tp->rtl_ops.eee_set(tp, edata);
 
+	if (ret == 0)
+		ret = mii_nway_restart(&tp->mii);
+
 	usb_autopm_put_interface(tp->intf);
 
 out:
-- 
1.9.3
