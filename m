From: Matthias Kaehlcke <mka@chromium.org>
Subject: [PATCH] mac80211: ibss: Fix channel type enum in ieee80211_sta_join_ibss()
Date: Mon, 17 Apr 2017 13:59:53 -0700
Message-ID: <20170417205953.4719-1-mka@chromium.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Grant Grundler <grundler@chromium.org>,
        Greg Hackmann <ghackmann@google.com>,
        Michael Davidson <md@google.com>,
        Matthias Kaehlcke <mka@chromium.org>
To: Johannes Berg <johannes@sipsolutions.net>,
        "David S . Miller" <davem@davemloft.net>,
        Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:33937 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754219AbdDQVAk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 17:00:40 -0400
Received: by mail-pg0-f45.google.com with SMTP id z127so13511443pgb.1
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 14:00:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cfg80211_chandef_create() expects an 'enum nl80211_channel_type' as
channel type however in ieee80211_sta_join_ibss()
NL80211_CHAN_WIDTH_20_NOHT is passed in two occasions, which is of
the enum type 'nl80211_chan_width'. Change the value to NL80211_CHAN_NO_HT
(20 MHz, non-HT channel) of the channel type enum.

Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
---
 net/mac80211/ibss.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/mac80211/ibss.c b/net/mac80211/ibss.c
index 98999d3d5262..e957351976a2 100644
--- a/net/mac80211/ibss.c
+++ b/net/mac80211/ibss.c
@@ -425,7 +425,7 @@ static void ieee80211_sta_join_ibss(struct ieee80211_sub_if_data *sdata,
 	case NL80211_CHAN_WIDTH_5:
 	case NL80211_CHAN_WIDTH_10:
 		cfg80211_chandef_create(&chandef, cbss->channel,
-					NL80211_CHAN_WIDTH_20_NOHT);
+					NL80211_CHAN_NO_HT);
 		chandef.width = sdata->u.ibss.chandef.width;
 		break;
 	case NL80211_CHAN_WIDTH_80:
@@ -437,7 +437,7 @@ static void ieee80211_sta_join_ibss(struct ieee80211_sub_if_data *sdata,
 	default:
 		/* fall back to 20 MHz for unsupported modes */
 		cfg80211_chandef_create(&chandef, cbss->channel,
-					NL80211_CHAN_WIDTH_20_NOHT);
+					NL80211_CHAN_NO_HT);
 		break;
 	}
 
-- 
2.12.2.762.g0e3151a226-goog
