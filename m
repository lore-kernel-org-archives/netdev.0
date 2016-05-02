From: Wang YanQing <udknight-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] rtlwifi:rtl_lps_enter: fix double check cnt_after_linked
Date: Mon, 2 May 2016 14:11:02 +0800
Message-ID: <20160502061102.GB12832@udknight>
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

We have checked cnt_after_linked in below code:
"
/*sleep after linked 10s, to let DHCP and 4-way handshake ok enough!! */
if (mac->cnt_after_linked < 5)
        return;
"
So the second check isn't necessary.

This patch delete second check code.

Signed-off-by: Wang YanQing <udknight-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/realtek/rtlwifi/ps.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/ps.c b/drivers/net/wireless/realtek/rtlwifi/ps.c
index b69321d..9d73581c 100644
--- a/drivers/net/wireless/realtek/rtlwifi/ps.c
+++ b/drivers/net/wireless/realtek/rtlwifi/ps.c
@@ -443,14 +443,11 @@ void rtl_lps_enter(struct ieee80211_hw *hw)
 
 	spin_lock_irqsave(&rtlpriv->locks.lps_lock, flag);
 
-	/* Idle for a while if we connect to AP a while ago. */
-	if (mac->cnt_after_linked >= 2) {
-		if (ppsc->dot11_psmode == EACTIVE) {
-			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-				 "Enter 802.11 power save mode...\n");
+	if (ppsc->dot11_psmode == EACTIVE) {
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+			"Enter 802.11 power save mode...\n");
 
-			rtl_lps_set_psmode(hw, EAUTOPS);
-		}
+		rtl_lps_set_psmode(hw, EAUTOPS);
 	}
 
 	spin_unlock_irqrestore(&rtlpriv->locks.lps_lock, flag);
-- 
1.8.5.6.2.g3d8a54e.dirty
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
