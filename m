From: Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH] rtlwifi/rtl8192de: remove redundant else if check
Date: Tue, 13 Jan 2015 14:07:34 +0000
Message-ID: <1421158054-22566-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

The else if check condition checks for the opposite of the
if check, hence the else if check is redundant and can be
replaced with a simple else:

if (rtlpriv->rtlhal.macphymode == SINGLEMAC_SINGLEPHY) {
	..
} else if (rtlpriv->rtlhal.macphymode != SINGLEMAC_SINGLEPHY) {
	..
}

replaced with:

if (rtlpriv->rtlhal.macphymode == SINGLEMAC_SINGLEPHY) {
	..
} else {
	..
}

Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
index 280c3da..01bcc2d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
@@ -546,7 +546,7 @@ static bool _rtl92de_llt_table_init(struct ieee80211_hw *hw)
 		txpktbuf_bndy = 246;
 		value8 = 0;
 		value32 = 0x80bf0d29;
-	} else if (rtlpriv->rtlhal.macphymode != SINGLEMAC_SINGLEPHY) {
+	} else {
 		maxPage = 127;
 		txpktbuf_bndy = 123;
 		value8 = 0;
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
