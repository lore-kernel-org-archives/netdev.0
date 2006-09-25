From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] ieee80211: quiet TKIP and CCMP replay messages for
 identical TSCs
Date: Mon, 25 Sep 2006 10:49:12 -0500
Message-ID: <4517FA78.mailH4P11L3ZE@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-smtp-01.rdc-kc.rr.com ([24.94.166.115]:64228 "EHLO
	ms-smtp-01.rdc-kc.rr.com") by vger.kernel.org with ESMTP
	id S1751051AbWIYPts (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Sep 2006 11:49:48 -0400
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When using TKIP and CCMP for wireless encryption with ieee80211, the logs get filled with useless
replay messages where the previous and received TSC are identical. This change deletes
the log message for this case, but still prints the message when there are major differences
in the TSC's.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

Index: wireless-2.6/net/ieee80211/ieee80211_crypt_tkip.c
===================================================================
--- wireless-2.6.orig/net/ieee80211/ieee80211_crypt_tkip.c
+++ wireless-2.6/net/ieee80211/ieee80211_crypt_tkip.c
@@ -394,7 +394,7 @@ static inline int tkip_replay_check(u32 
 				    u32 iv32_o, u16 iv16_o)
 {
 	if ((s32)iv32_n - (s32)iv32_o < 0 ||
-	    (iv32_n == iv32_o && iv16_n <= iv16_o))
+	    (iv32_n == iv32_o && iv16_n < iv16_o))
 		return 1;
 	return 0;
 }
Index: wireless-2.6/net/ieee80211/ieee80211_crypt_ccmp.c
===================================================================
--- wireless-2.6.orig/net/ieee80211/ieee80211_crypt_ccmp.c
+++ wireless-2.6/net/ieee80211/ieee80211_crypt_ccmp.c
@@ -287,7 +287,7 @@ static inline int ccmp_replay_check(u8 *
 	iv16_o = (pn_o[4] << 8) | pn_o[5];
 
 	if ((s32)iv32_n - (s32)iv32_o < 0 ||
-	    (iv32_n == iv32_o && iv16_n <= iv16_o))
+	    (iv32_n == iv32_o && iv16_n < iv16_o))
 		return 1;
 	return 0;
 }
