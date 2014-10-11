From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH V3.18] rtlwifi: rtl8192ee: Prevent log spamming for switch statements
Date: Sat, 11 Oct 2014 12:59:53 -0500
Message-ID: <1413050393-6257-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The driver logs a message when the default branch of switch statements are
taken. Such information is useful when debugging, but these log items should
not be seen for standard usage.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/rtl8192ee/hw.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ee/hw.c
index dfdc9b2..1a87edc 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/hw.c
@@ -362,7 +362,7 @@ void rtl92ee_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		}
 		break;
 	default:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_DMESG,
 			 "switch case not process %x\n", variable);
 		break;
 	}
@@ -591,7 +591,7 @@ void rtl92ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 				acm_ctrl &= (~ACMHW_BEQEN);
 				break;
 			default:
-				RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+				RT_TRACE(rtlpriv, COMP_ERR, DBG_DMESG,
 					 "switch case not process\n");
 				break;
 			}
@@ -710,7 +710,7 @@ void rtl92ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		}
 		break;
 	default:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_DMESG,
 			 "switch case not process %x\n", variable);
 		break;
 	}
@@ -2424,7 +2424,7 @@ void rtl92ee_set_key(struct ieee80211_hw *hw, u32 key_index,
 			enc_algo = CAM_AES;
 			break;
 		default:
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_DMESG,
 				 "switch case not process\n");
 			enc_algo = CAM_TKIP;
 			break;
-- 
1.8.4.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
