From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH v2] mac80211: Invoke TX LED in more code paths
Date: Sat, 27 May 2017 14:59:27 -0700
Message-ID: <20170527215927.7726-1-bjorn.andersson@linaro.org>
Cc: linux-wireless@vger.kernel.org (open list:MAC80211),
        netdev@vger.kernel.org (open list:NETWORKING [GENERAL]),
        linux-kernel@vger.kernel.org (open list),
        linux-arm-msm@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>,
        Johannes Berg <johannes@sipsolutions.net>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:33308 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750751AbdE0V7c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 17:59:32 -0400
Received: by mail-pg0-f45.google.com with SMTP id u187so7943214pgb.0
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 14:59:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ieee80211_tx_status() is only one of the possible ways a driver can
report a handled packet, some drivers call this for every packet while
others calls it rarely or never.

In order to invoke the TX LED in the non-status reporting cases this
patch pushes the call to ieee80211_led_tx() into
ieee80211_report_used_skb(), which is shared between the various code
paths.

Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 net/mac80211/status.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/mac80211/status.c b/net/mac80211/status.c
index be47ac5cd8c8..a9fa6ee57e8f 100644
--- a/net/mac80211/status.c
+++ b/net/mac80211/status.c
@@ -546,6 +546,8 @@ static void ieee80211_report_used_skb(struct ieee80211_local *local,
 		skb->wifi_acked_valid = 1;
 		skb->wifi_acked = acked;
 	}
+
+	ieee80211_led_tx(local);
 }
 
 /*
@@ -823,8 +825,6 @@ static void __ieee80211_tx_status(struct ieee80211_hw *hw,
 		}
 	}
 
-	ieee80211_led_tx(local);
-
 	/* SNMP counters
 	 * Fragments are passed to low-level drivers as separate skbs, so these
 	 * are actually fragments, not frames. Update frame counters only for
-- 
2.12.0
