From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next] r8152: reduce the number of Tx
Date: Thu, 28 Aug 2014 10:17:35 +0800
Message-ID: <1394712342-15778-23-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:39946 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932352AbaH1CRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 22:17:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because the Tx has the features of stopping queue and aggregation,
We don't need many tx buffers. Change the tx number from 10 to 4
to reduce the usage of the memory. This could save 16K * 10 bytes
memory.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 33dcc97..cc64dc0 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -424,7 +424,7 @@ enum rtl_register_content {
 	FULL_DUP	= 0x01,
 };
 
-#define RTL8152_MAX_TX		10
+#define RTL8152_MAX_TX		4
 #define RTL8152_MAX_RX		10
 #define INTBUFSIZE		2
 #define CRC_SIZE		4
-- 
1.9.3
