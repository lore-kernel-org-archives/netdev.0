From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 3/3] r8152: remove cancel_delayed_work_sync in rtl8152_set_speed
Date: Thu, 7 Jul 2016 15:09:20 +0800
Message-ID: <1394712342-15778-213-Taiwan-albertk@realtek.com>
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

There is no conflict between the work_queue function and
rtl8152_set_speed(), so we don't have to cancel the delayed work in
rtl8152_set_speed().

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index f1c5020..168a8e2 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2829,7 +2829,6 @@ static int rtl8152_set_speed(struct r8152 *tp, u8 autoneg, u16 speed, u8 duplex)
 	u16 bmcr, anar, gbcr;
 	int ret = 0;
 
-	cancel_delayed_work_sync(&tp->schedule);
 	anar = r8152_mdio_read(tp, MII_ADVERTISE);
 	anar &= ~(ADVERTISE_10HALF | ADVERTISE_10FULL |
 		  ADVERTISE_100HALF | ADVERTISE_100FULL);
-- 
2.7.4
