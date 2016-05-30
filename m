From: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
Subject: [PATCH v2 05/10] nl80211: Fix checkpatch.pl NULL comparison warning
Date: Sun, 29 May 2016 19:52:48 -0700
Message-ID: <cc580aa7b55b9546c71185b6b4e07aba00367e72.1464576022.git.kirtika.ruchandani@gmail.com>
References: <cover.1464576022.git.kirtika.ruchandani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, ruchandani.tina@gmail.com,
	netdev@vger.kernel.org, Julian.Calaby@gmail.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36639 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753188AbcE3Cwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 May 2016 22:52:55 -0400
Content-Disposition: inline
In-Reply-To: <cover.1464576022.git.kirtika.ruchandani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the warning - "comparison to NULL (foo == NULL)
could be written as (!foo)"

Signed-off-by: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
---
 net/wireless/nl80211.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 945405d..11cbf0b 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -928,7 +928,7 @@ static struct ieee80211_channel *nl80211_get_valid_chan(struct wiphy *wiphy,
 {
 	struct ieee80211_channel *chan;

-	if (tb == NULL)
+	if (!tb)
 		return NULL;
 	chan = ieee80211_get_channel(wiphy, nla_get_u32(tb));
 	if (!chan || chan->flags & IEEE80211_CHAN_DISABLED)
@@ -8575,7 +8575,7 @@ static int nl80211_set_tx_bitrate_mask(struct sk_buff *skb,
 		if (band < 0 || band >= NUM_NL80211_BANDS)
 			return -EINVAL;
 		sband = rdev->wiphy.bands[band];
-		if (sband == NULL)
+		if (!sband)
 			return -EINVAL;
 		err = nla_parse(tb, NL80211_TXRATE_MAX, nla_data(tx_rates),
 				nla_len(tx_rates), nl80211_txattr_policy);
