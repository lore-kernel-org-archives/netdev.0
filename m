From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 1/2 RESEND] r8152: call rtl_start_rx after netif_carrier_on
Date: Fri, 9 Jan 2015 10:26:35 +0800
Message-ID: <1394712342-15778-115-Taiwan-albertk@realtek.com>
References: <1394712342-15778-114-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-114-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove rtl_start_rx() from rtl_enable() and put it after calling
netif_carrier_on().

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 57ec23e..cd93388 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2059,7 +2059,7 @@ static int rtl_enable(struct r8152 *tp)
 
 	rxdy_gated_en(tp, false);
 
-	return rtl_start_rx(tp);
+	return 0;
 }
 
 static int rtl8152_enable(struct r8152 *tp)
@@ -2874,6 +2874,7 @@ static void set_carrier(struct r8152 *tp)
 			tp->rtl_ops.enable(tp);
 			set_bit(RTL8152_SET_RX_MODE, &tp->flags);
 			netif_carrier_on(netdev);
+			rtl_start_rx(tp);
 		}
 	} else {
 		if (tp->speed & LINK_STATUS) {
-- 
2.1.0
