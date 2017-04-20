From: Stefan Agner <stefan@agner.ch>
Subject: [PATCH] mac80211: fix enumeration type
Date: Thu, 20 Apr 2017 00:02:36 -0700
Message-ID: <20170420070236.8334-1-stefan@agner.ch>
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Stefan Agner <stefan@agner.ch>
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kmu-office.ch ([178.209.48.109]:44432 "EHLO
        mail.kmu-office.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942565AbdDTHBA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 03:01:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use enum nl80211_channel_type for cfg80211_chandef_create function
calls. This does not has an effect in practise since the enum values
are equal. This fixes a warning when compiling with clang:
  warning: implicit conversion from enumeration type 'enum nl80211_chan_width'
  to different enumeration type 'enum nl80211_channel_type'

Signed-off-by: Stefan Agner <stefan@agner.ch>
---
 net/mac80211/ibss.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/mac80211/ibss.c b/net/mac80211/ibss.c
index 98999d3d5262..5b748025147d 100644
--- a/net/mac80211/ibss.c
+++ b/net/mac80211/ibss.c
@@ -425,7 +425,7 @@ static void ieee80211_sta_join_ibss(struct ieee80211_sub_if_data *sdata,
 	case NL80211_CHAN_WIDTH_5:
 	case NL80211_CHAN_WIDTH_10:
 		cfg80211_chandef_create(&chandef, cbss->channel,
-					NL80211_CHAN_WIDTH_20_NOHT);
+					NL80211_CHAN_HT20);
 		chandef.width = sdata->u.ibss.chandef.width;
 		break;
 	case NL80211_CHAN_WIDTH_80:
@@ -437,7 +437,7 @@ static void ieee80211_sta_join_ibss(struct ieee80211_sub_if_data *sdata,
 	default:
 		/* fall back to 20 MHz for unsupported modes */
 		cfg80211_chandef_create(&chandef, cbss->channel,
-					NL80211_CHAN_WIDTH_20_NOHT);
+					NL80211_CHAN_HT20);
 		break;
 	}
 
-- 
2.12.2
