From: Wang YanQing <udknight-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2] rtlwifi: Fix logic error in enter/exit power-save mode
Date: Tue, 3 May 2016 00:38:36 +0800
Message-ID: <20160502163835.GA10925@udknight>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In commit a269913c52ad ("rtlwifi: Rework rtl_lps_leave() and
rtl_lps_enter() to use work queue"), the tests for enter/exit
power-save mode were inverted. With this change applied, the
wifi connection becomes much more stable.

Fixes: a269913c52ad ("rtlwifi: Rework rtl_lps_leave() and rtl_lps_enter() to use work queue")
Signed-off-by: Wang YanQing <udknight-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
CC: Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org> [3.10+]
---
 Hi, Larry!

 Because commit a269913c52ad is the first commit bring this problem, 
 so maybe use above commit message is ok, right? And stable kernels
 3.10-3.18 don't have commit fd09ff958777, but have a269913c52ad.

 Thanks for suggestion concerning to good subject and commit message
 writing, it is harder than coding sometimes:)

 Changes:
 v1-v2:
 1: Fix subject and commit message.

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
