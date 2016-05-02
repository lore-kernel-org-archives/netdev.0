From: Wang YanQing <udknight-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] rtlwifi:rtl_watchdog_wq_callback: fix calling
 rtl_lps_enter|rtl_lps_leave in opposite condition
Date: Mon, 2 May 2016 13:37:54 +0800
Message-ID: <20160502053754.GA30313@udknight>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Commit a269913c52ad37952a4d9953bb6d748f7299c304
("rtlwifi: Rework rtl_lps_leave() and rtl_lps_enter() to use work queue")
make a mistake, change the meaning of num_tx|rx_inperiod comparison test.

Commit fd09ff958777cf583d7541f180991c0fc50bd2f7
("rtlwifi: Remove extra workqueue for enter/leave power state")
follow previous mistake, bring us to current code.

This patch fix it.

Signed-off-by: Wang YanQing <udknight-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 I think this patch should be ported back to stable kernels, 3.10+.
 In my machine, I will lost wifi connection after minutes if I enable
 fwlps.
 
 drivers/net/wireless/realtek/rtlwifi/base.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/base.c b/drivers/net/wireless/realtek/rtlwifi/base.c
index c74eb13..264466f 100644
--- a/drivers/net/wireless/realtek/rtlwifi/base.c
+++ b/drivers/net/wireless/realtek/rtlwifi/base.c
@@ -1660,9 +1660,9 @@ void rtl_watchdog_wq_callback(void *data)
 		if (((rtlpriv->link_info.num_rx_inperiod +
 		      rtlpriv->link_info.num_tx_inperiod) > 8) ||
 		    (rtlpriv->link_info.num_rx_inperiod > 2))
-			rtl_lps_enter(hw);
-		else
 			rtl_lps_leave(hw);
+		else
+			rtl_lps_enter(hw);
 	}
 
 	rtlpriv->link_info.num_rx_inperiod = 0;
-- 
1.8.5.6.2.g3d8a54e.dirty
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
