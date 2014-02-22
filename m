From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 1/1] rtlwifi: Convert drivers to use new API for ieee80211_is_robust_mgmt_frame()
Date: Sat, 22 Feb 2014 11:17:13 -0600
Message-ID: <1393089433-28270-18-git-send-email-Larry.Finger@lwfinger.net>
References: <1393089433-28270-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1393089433-28270-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Drivers rtl8188ee, rtl8192ce, rtl8192se, and rtl8723ae all use this routine.
In addition, all callers of ieee80211_is_robust_mgmt_frame() have access to the
skb. Thus, it is trivial to use the new API rather than the underscored old version.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
---

Johannes,

I think this patch removes all callers of the old API.

Larry
---

 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c | 2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c | 2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c | 2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c | 4 ++--
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
index 27ace30..384245f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
@@ -452,7 +452,7 @@ bool rtl88ee_rx_query_desc(struct ieee80211_hw *hw,
 			/* During testing, hdr was NULL */
 			return false;
 		}
-		if ((_ieee80211_is_robust_mgmt_frame(hdr)) &&
+		if ((ieee80211_is_robust_mgmt_frame(skb)) &&
 		    (ieee80211_has_protected(hdr->frame_control)))
 			rx_status->flag &= ~RX_FLAG_DECRYPTED;
 		else
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
index 114858d..0d05bac 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
@@ -393,7 +393,7 @@ bool rtl92ce_rx_query_desc(struct ieee80211_hw *hw,
 			/* In testing, hdr was NULL here */
 			return false;
 		}
-		if ((_ieee80211_is_robust_mgmt_frame(hdr)) &&
+		if ((ieee80211_is_robust_mgmt_frame(skb)) &&
 		    (ieee80211_has_protected(hdr->frame_control)))
 			rx_status->flag &= ~RX_FLAG_DECRYPTED;
 		else
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
index 163a681..af1bb3d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
@@ -310,7 +310,7 @@ bool rtl92se_rx_query_desc(struct ieee80211_hw *hw, struct rtl_stats *stats,
 			/* during testing, hdr was NULL here */
 			return false;
 		}
-		if ((_ieee80211_is_robust_mgmt_frame(hdr)) &&
+		if ((ieee80211_is_robust_mgmt_frame(skb)) &&
 			(ieee80211_has_protected(hdr->frame_control)))
 			rx_status->flag &= ~RX_FLAG_DECRYPTED;
 		else
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
index 721162c..8f20226 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
@@ -334,8 +334,8 @@ bool rtl8723ae_rx_query_desc(struct ieee80211_hw *hw,
 			/* during testing, hdr could be NULL here */
 			return false;
 		}
-		if ((_ieee80211_is_robust_mgmt_frame(hdr)) &&
-			(ieee80211_has_protected(hdr->frame_control)))
+		if ((ieee80211_is_robust_mgmt_frame(skb)) &&
+		    (ieee80211_has_protected(hdr->frame_control)))
 			rx_status->flag &= ~RX_FLAG_DECRYPTED;
 		else
 			rx_status->flag |= RX_FLAG_DECRYPTED;
-- 
1.8.4.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
