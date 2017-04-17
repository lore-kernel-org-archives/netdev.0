From: Matthias Kaehlcke <mka@chromium.org>
Subject: [PATCH] nl80211: Fix enum type of variable in nl80211_put_sta_rate()
Date: Mon, 17 Apr 2017 15:59:52 -0700
Message-ID: <20170417225952.106468-1-mka@chromium.org>
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
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33872 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753810AbdDQXAB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 19:00:01 -0400
Received: by mail-pf0-f182.google.com with SMTP id c198so71833458pfc.1
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 16:00:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rate_flg is of type 'enum nl80211_attrs', however it is assigned with
'enum nl80211_rate_info' values. Change the type of rate_flg accordingly.

Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
---
 net/wireless/nl80211.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 2312dc2ffdb9..9af21a21ea6b 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -4151,7 +4151,7 @@ static bool nl80211_put_sta_rate(struct sk_buff *msg, struct rate_info *info,
 	struct nlattr *rate;
 	u32 bitrate;
 	u16 bitrate_compat;
-	enum nl80211_attrs rate_flg;
+	enum nl80211_rate_info rate_flg;
 
 	rate = nla_nest_start(msg, attr);
 	if (!rate)
-- 
2.12.2.762.g0e3151a226-goog
