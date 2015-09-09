From: Sergei Trofimovich <slyich-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] net/mac80211/rate.c: fix wrong sizeof()
Date: Wed,  9 Sep 2015 21:56:54 +0100
Message-ID: <1441832214-6939-1-git-send-email-slyich@gmail.com>
Cc: Sergei Trofimovich <siarheit-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Lorenzo Bianconi <lorenzo.bianconi83-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sergei Trofimovich <siarheit-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Noticed by gcc-5.2.0:

    net/mac80211/rate.c: In function 'rate_control_cap_mask':
    net/mac80211/rate.c:719:25: warning: 'sizeof' on array function parameter 'mcs_mask' will return size of 'u8 * {aka unsigned char *}' [-Wsizeof-array-argument]
       for (i = 0; i < sizeof(mcs_mask); i++)
                             ^

CC: Lorenzo Bianconi <lorenzo.bianconi83-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
CC: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
CC: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
CC: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Sergei Trofimovich <siarheit-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 net/mac80211/rate.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mac80211/rate.c b/net/mac80211/rate.c
index 9857693..9ce8883 100644
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
2.5.0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
