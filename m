From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 2/3] r8152: remove a netif_carrier_off in rtl8152_open function
Date: Thu, 7 Jul 2016 15:09:19 +0800
Message-ID: <1394712342-15778-212-Taiwan-albertk@realtek.com>
References: <1394712342-15778-210-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-210-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After commit 90186af404ad ("r8152: fix lockup when runtime PM is enabled"),
the autoresume wouldn't start the device before rtl8152_open() is finished.
Therefore, we don't have to reset the linking status before and after
autoresume. That is, one of netif_carrier_off() in rtl8152_open() could be
removed.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index e005ee6..f1c5020 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3111,8 +3111,6 @@ static int rtl8152_open(struct net_device *netdev)
 	if (res)
 		goto out;
 
-	netif_carrier_off(netdev);
-
 	res = usb_autopm_get_interface(tp->intf);
 	if (res < 0) {
 		free_all_mem(tp);
-- 
2.7.4
