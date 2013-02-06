From: Cong Ding <dinggnu@gmail.com>
Subject: [PATCH] net: mac80211/cfg.c: fix error using of sizeof()
Date: Wed,  6 Feb 2013 17:23:45 +0100
Message-ID: <1360167826-29265-1-git-send-email-dinggnu@gmail.com>
Cc: Cong Ding <dinggnu@gmail.com>
To: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f47.google.com ([209.85.214.47]:39655 "EHLO
	mail-bk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756383Ab3BFQXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 11:23:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using 'sizeof' on array given as function argument returns size of a pointer
rather than the size of array.

Signed-off-by: Cong Ding <dinggnu@gmail.com>
---
 net/mac80211/cfg.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 661b878..af561d5 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -2058,7 +2058,8 @@ static int ieee80211_set_mcast_rate(struct wiphy *wiphy, struct net_device *dev,
 {
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
-	memcpy(sdata->vif.bss_conf.mcast_rate, rate, sizeof(rate));
+	memcpy(sdata->vif.bss_conf.mcast_rate, rate,
+			sizeof(int) * IEEE80211_NUM_BANDS);
 
 	return 0;
 }
-- 
1.7.9.5
