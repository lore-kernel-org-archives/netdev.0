From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 2/3] r8152: clear the flag of SCHEDULE_TASKLET in tasklet
Date: Fri, 31 Oct 2014 14:03:55 +0800
Message-ID: <1394712342-15778-77-Taiwan-albertk@realtek.com>
References: <1394712342-15778-75-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:60880 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753002AbaJaGEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 02:04:31 -0400
In-Reply-To: <1394712342-15778-75-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clear the flag of SCHEDULE_TASKLET in bottom_half() to avoid
re-schedule the tasklet again by workqueue.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index ff54098..670279a 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1798,6 +1798,9 @@ static void bottom_half(unsigned long data)
 	if (!netif_carrier_ok(tp->netdev))
 		return;
 
+	if (test_bit(SCHEDULE_TASKLET, &tp->flags))
+		clear_bit(SCHEDULE_TASKLET, &tp->flags);
+
 	rx_bottom(tp);
 	tx_bottom(tp);
 }
-- 
1.9.3
