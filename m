From: Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [2.6 patch] net/mac80211/rx.c: fix off-by-one
Date: Wed, 23 Apr 2008 12:51:28 +0300
Message-ID: <20080423095128.GY28933@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch fixes an off-by-one in net/mac80211/rx.c introduced by
commit 8318d78a44d49ac1edf2bdec7299de3617c4232e
(cfg80211 API for channels/bitrates, mac80211 and driver conversion)
and spotted by the Coverity checker.

Signed-off-by: Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

---
--- linux-2.6/net/mac80211/rx.c.old	2008-04-22 02:23:40.000000000 +0300
+++ linux-2.6/net/mac80211/rx.c	2008-04-22 02:24:23.000000000 +0300
@@ -2168,11 +2168,11 @@ void __ieee80211_rx(struct ieee80211_hw 
 	u32 pkt_load;
 	struct ieee80211_rate *rate = NULL;
 	struct ieee80211_supported_band *sband;
 
 	if (status->band < 0 ||
-	    status->band > IEEE80211_NUM_BANDS) {
+	    status->band >= IEEE80211_NUM_BANDS) {
 		WARN_ON(1);
 		return;
 	}
 
 	sband = local->hw.wiphy->bands[status->band];

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
