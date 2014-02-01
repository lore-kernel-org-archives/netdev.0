From: Olivier Langlois <olivier-VxAV575H0jR+kJTeVDPgHg@public.gmane.org>
Subject: [PATCH 2/2] rtlwifi: Fix incorrect return from rtl_ps_enable_nic()
Date: Sat,  1 Feb 2014 01:11:10 -0500
Message-ID: <1391235070-23180-2-git-send-email-olivier@trillion01.com>
References: <1391235070-23180-1-git-send-email-olivier@trillion01.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Olivier Langlois <olivier-VxAV575H0jR+kJTeVDPgHg@public.gmane.org>,
	Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1391235070-23180-1-git-send-email-olivier-VxAV575H0jR+kJTeVDPgHg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

rtl_ps_enable_nic() is called from loops that will loop until this function returns true or a
maximum number of retries is performed.

hw_init() returns non-zero on error. In that situation return false to
restore the original design intent to retry hw init when it fails.

Signed-off-by: Olivier Langlois <olivier-VxAV575H0jR+kJTeVDPgHg@public.gmane.org>
Cc: Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/ps.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/ps.c b/drivers/net/wireless/rtlwifi/ps.c
index 0d81f76..a56e9b3 100644
--- a/drivers/net/wireless/rtlwifi/ps.c
+++ b/drivers/net/wireless/rtlwifi/ps.c
@@ -48,7 +48,7 @@ bool rtl_ps_enable_nic(struct ieee80211_hw *hw)
 
 	/*<2> Enable Adapter */
 	if (rtlpriv->cfg->ops->hw_init(hw))
-		return 1;
+		return false;
 	RT_CLEAR_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC);
 
 	/*<3> Enable Interrupt */
-- 
1.8.5.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
