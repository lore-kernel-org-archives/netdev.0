From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v3 2/3] r8152: clear the flag of SCHEDULE_TASKLET in tasklet
Date: Wed, 12 Nov 2014 10:05:04 +0800
Message-ID: <1394712342-15778-93-Taiwan-albertk@realtek.com>
References: <1394712342-15778-79-Taiwan-albertk@realtek.com>
 <1394712342-15778-91-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-91-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Clear the flag of SCHEDULE_TASKLET in bottom_half() to avoid
re-schedule the tasklet again by workqueue.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index a300467..ad9dd7d 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1797,6 +1797,8 @@ static void bottom_half(unsigned long data)
 	if (!netif_carrier_ok(tp->netdev))
 		return;
 
+	clear_bit(SCHEDULE_TASKLET, &tp->flags);
+
 	rx_bottom(tp);
 	tx_bottom(tp);
 }
-- 
1.9.3
