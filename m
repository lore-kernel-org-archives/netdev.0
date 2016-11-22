From: Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] mac80211: Remove unused 'rates_idx' variable
Date: Mon, 21 Nov 2016 22:04:46 -0800
Message-ID: <20161122060446.GA26548@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Commit f027c2aca0cf introduced 'rates_idx' in
ieee80211_tx_status_noskb but did not use it. Compiling with W=1
gives the following warning, fix it.

mac80211/status.c: In function ‘ieee80211_tx_status_noskb’:
mac80211/status.c:636:6: warning: variable ‘rates_idx’ set but not used [-Wunused-but-set-variable]

This is a harmless warning, and is only being fixed to reduce the
noise generated with W=1.

Fixes: f027c2aca0cf ("mac80211: add ieee80211_tx_status_noskb")
Cc: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Signed-off-by: Kirtika Ruchandani <kirtika-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 net/mac80211/status.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/mac80211/status.c b/net/mac80211/status.c
index ddf71c6..f7c5ae5 100644
--- a/net/mac80211/status.c
+++ b/net/mac80211/status.c
@@ -633,10 +633,9 @@ void ieee80211_tx_status_noskb(struct ieee80211_hw *hw,
 	struct ieee80211_local *local = hw_to_local(hw);
 	struct ieee80211_supported_band *sband;
 	int retry_count;
-	int rates_idx;
 	bool acked, noack_success;

-	rates_idx = ieee80211_tx_get_rates(hw, info, &retry_count);
+	ieee80211_tx_get_rates(hw, info, &retry_count);

 	sband = hw->wiphy->bands[info->band];

--
2.8.0.rc3.226.g39d4020
