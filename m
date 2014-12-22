From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 1/2] r8152: call rtl_start_rx after netif_carrier_on
Date: Mon, 22 Dec 2014 14:52:55 +0800
Message-ID: <1394712342-15778-111-Taiwan-albertk@realtek.com>
References: <1394712342-15778-107-Taiwan-albertk@realtek.com>
 <1394712342-15778-110-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:57362 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753184AbaLVGx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 01:53:29 -0500
In-Reply-To: <1394712342-15778-110-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove rtl_start_rx() from rtl_enable() and put it after calling
netif_carrier_on().

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 2d1c77e..cbe450c 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2043,7 +2043,7 @@ static int rtl_enable(struct r8152 *tp)
 
 	rxdy_gated_en(tp, false);
 
-	return rtl_start_rx(tp);
+	return 0;
 }
 
 static int rtl8152_enable(struct r8152 *tp)
@@ -2858,6 +2858,7 @@ static void set_carrier(struct r8152 *tp)
 			tp->rtl_ops.enable(tp);
 			set_bit(RTL8152_SET_RX_MODE, &tp->flags);
 			netif_carrier_on(netdev);
+			rtl_start_rx(tp);
 		}
 	} else {
 		if (tp->speed & LINK_STATUS) {
-- 
2.1.0
