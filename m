From: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] mac80211: Do not use sizeof() on pointer type
Date: Wed, 26 Aug 2015 12:22:14 +0200
Message-ID: <1440584534-27251-1-git-send-email-thierry.reding@gmail.com>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>

The rate_control_cap_mask() function takes a parameter mcs_mask, which
GCC will take to be u8 * even though it was declared with a fixed size.
This causes the following warning:

	net/mac80211/rate.c: In function 'rate_control_cap_mask':
	net/mac80211/rate.c:719:25: warning: 'sizeof' on array function parameter 'mcs_mask' will return size of 'u8 * {aka unsigned char *}' [-Wsizeof-array-argument]
	   for (i = 0; i < sizeof(mcs_mask); i++)
	                         ^
	net/mac80211/rate.c:684:10: note: declared here
	       u8 mcs_mask[IEEE80211_HT_MCS_MASK_LEN],
	          ^

This can be easily fixed by using the IEEE80211_HT_MCS_MASK_LEN directly
within the loop condition.

Signed-off-by: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
---
 net/mac80211/rate.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mac80211/rate.c b/net/mac80211/rate.c
index 9857693b91ec..9ce8883d5f44 100644
--- a/net/mac80211/rate.c
+++ b/net/mac80211/rate.c
@@ -716,7 +716,7 @@ static bool rate_control_cap_mask(struct ieee80211_sub_if_data *sdata,
 
 		/* Filter out rates that the STA does not support */
 		*mask &= sta->supp_rates[sband->band];
-		for (i = 0; i < sizeof(mcs_mask); i++)
+		for (i = 0; i < IEEE80211_HT_MCS_MASK_LEN; i++)
 			mcs_mask[i] &= sta->ht_cap.mcs.rx_mask[i];
 
 		sta_vht_cap = sta->vht_cap.vht_mcs.rx_mcs_map;
-- 
2.4.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
