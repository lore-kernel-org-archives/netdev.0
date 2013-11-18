From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 2/3] rtlwifi: rtl8192cu: Bring rtl92cu_phy_bb_config() up to date
Date: Mon, 18 Nov 2013 13:06:56 -0600
Message-ID: <1384801617-22920-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1384801617-22920-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mark Cave-Ayland <mark.cave-ayland-r2/yp8inhXLQXOPxS62xeg@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1384801617-22920-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Mark Cave-Ayland <mark.cave-ayland-r2/yp8inhXLQXOPxS62xeg@public.gmane.org>

The latest vendor driver contains some changes not in the kernel version.

Signed-off-by: Mark Cave-Ayland <mark.cave-ayland-r2/yp8inhXLQXOPxS62xeg@public.gmane.org>
Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/rtl8192cu/phy.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c b/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c
index 34e5630..0c09240 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c
@@ -120,6 +120,7 @@ bool rtl92cu_phy_bb_config(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	u16 regval;
+	u32 regval32;
 	u8 b_reg_hwparafile = 1;
 
 	_rtl92c_phy_init_bb_rf_register_definition(hw);
@@ -135,8 +136,11 @@ bool rtl92cu_phy_bb_config(struct ieee80211_hw *hw)
 	} else if (IS_HARDWARE_TYPE_8192CU(rtlhal)) {
 		rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN, FEN_USBA | FEN_USBD |
 			       FEN_BB_GLB_RSTn | FEN_BBRSTB);
-		rtl_write_byte(rtlpriv, REG_LDOHCI12_CTRL, 0x0f);
 	}
+	regval32 = rtl_read_dword(rtlpriv, 0x87c);
+	rtl_write_dword(rtlpriv, 0x87c, regval32 & (~BIT(31)));
+	if (IS_HARDWARE_TYPE_8192CU(rtlhal))
+		rtl_write_byte(rtlpriv, REG_LDOHCI12_CTRL, 0x0f);
 	rtl_write_byte(rtlpriv, REG_AFE_XTAL_CTRL + 1, 0x80);
 	if (b_reg_hwparafile == 1)
 		rtstatus = _rtl92c_phy_bb8192c_config_parafile(hw);
-- 
1.8.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
