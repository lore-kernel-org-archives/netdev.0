From: Colin King <colin.king@canonical.com>
Subject: [PATCH] cfg80211: fix missing break in NL8211_CHAN_WIDTH_80P80 case
Date: Sun, 17 Jul 2016 19:55:27 +0100
Message-ID: <1468781727-9906-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
	"David S . Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:34405 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174AbcGQS4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2016 14:56:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

The switch on chandef->width is missing a break on the
NL8211_CHAN_WIDTH_80P80 case; currently we get a WARN_ON when
center_freq2 is non-zero because of the missing break.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/wireless/chan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/wireless/chan.c b/net/wireless/chan.c
index b0e11b6..0f50622 100644
--- a/net/wireless/chan.c
+++ b/net/wireless/chan.c
@@ -513,6 +513,7 @@ static bool cfg80211_chandef_dfs_available(struct wiphy *wiphy,
 		r = cfg80211_get_chans_dfs_available(wiphy,
 						     chandef->center_freq2,
 						     width);
+		break;
 	default:
 		WARN_ON(chandef->center_freq2);
 		break;
-- 
2.8.1
