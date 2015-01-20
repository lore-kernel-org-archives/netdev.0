From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH V2 for 3.19 4/7] rtlwifi: rtl8192ee: Fix TX hang due to failure to update TX write point
Date: Tue, 20 Jan 2015 11:01:23 -0600
Message-ID: <1421773286-1039-5-git-send-email-Larry.Finger@lwfinger.net>
References: <1421773286-1039-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Troy Tan <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1421773286-1039-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Troy Tan <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>

Initially, the routine to update the write point in the FIFO buffer was
coded to save CPU time by not doing the calculation every interrupt. This
was an error and results in TX hangs.

Signed-off-by: Troy Tan <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org> [V3.18]
---
 drivers/net/wireless/rtlwifi/rtl8192ee/trx.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c
index 0a006c4..1535680 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c
@@ -1049,8 +1049,7 @@ bool rtl92ee_is_tx_desc_closed(struct ieee80211_hw *hw, u8 hw_queue, u16 index)
 	static u8 stop_report_cnt;
 	struct rtl8192_tx_ring *ring = &rtlpci->tx_ring[hw_queue];
 
-	/*checking Read/Write Point each interrupt wastes CPU */
-	if (stop_report_cnt > 15 || !rtlpriv->link_info.busytraffic) {
+	{
 		u16 point_diff = 0;
 		u16 cur_tx_rp, cur_tx_wp;
 		u32 tmpu32 = 0;
-- 
2.1.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
