From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] mac80211: directly return ieee80211_vif_use_reserved_context()
Date: Thu,  9 Oct 2014 20:36:22 +0200
Message-ID: <1412879782-8818-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No need to store ieee80211_vif_use_reserved_context result and test it before returning.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/mac80211/cfg.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index fb6a150..c76b457 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -2850,11 +2850,7 @@ static int __ieee80211_csa_finalize(struct ieee80211_sub_if_data *sdata)
 		if (sdata->reserved_ready)
 			return 0;
 
-		err = ieee80211_vif_use_reserved_context(sdata);
-		if (err)
-			return err;
-
-		return 0;
+		return ieee80211_vif_use_reserved_context(sdata);
 	}
 
 	if (!cfg80211_chandef_identical(&sdata->vif.bss_conf.chandef,
-- 
1.9.3
