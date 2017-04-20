From: Stefan Agner <stefan@agner.ch>
Subject: [PATCH] nl80211: fix enumeration type
Date: Wed, 19 Apr 2017 23:55:13 -0700
Message-ID: <20170420065513.1930-1-stefan@agner.ch>
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Stefan Agner <stefan@agner.ch>
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kmu-office.ch ([178.209.48.109]:44269 "EHLO
        mail.kmu-office.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942511AbdDTGyl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 02:54:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use type enum nl80211_rate_info for bitrate information. This fixes
a warning when compiling with clang:
  warning: implicit conversion from enumeration type 'enum nl80211_rate_info'
  to different enumeration type 'enum nl80211_attrs'

Signed-off-by: Stefan Agner <stefan@agner.ch>
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
2.12.2
