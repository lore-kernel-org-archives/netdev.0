From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] Changes to ieee80211.h for user space regulatory daemon
Date: Tue, 30 May 2006 11:55:42 -0500
Message-ID: <447C790E.1030702@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:35071 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S932327AbWE3Qzq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 May 2006 12:55:46 -0400
To: netdev@vger.kernel.org, John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Attached are two small patches for include/net/ieee80211.h to prepare for later submission of code 
to implement a user-space daemon that supplies 802.11 regulatory information.

The first change adds a bit indicating that 802.11h rules are to be applied to a channel. As 
discussed earlier in this list, a single bit is unlikely to be sufficient; however, at this time I 
have been unable to find any regulations implementing differences between 802.11a and 802.11h other 
than DFS, radar detection and passive scanning. A single bit is thus sufficient to convey to the 
driver that these rules should be obeyed.

The second change adds comments to the freq and max_power fields of struct ieee80211_channel to 
indicate the units that are used.

Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>

index 293e920..6a2f60c 100644
--- a/include/net/ieee80211.h
+++ b/include/net/ieee80211.h
@@ -968,6 +968,7 @@ #define IEEE80211_52GHZ_CHANNELS (IEEE80

  enum {
	IEEE80211_CH_PASSIVE_ONLY = (1 << 0),
+	IEEE80211_CH_80211H_RULES = (1 << 1),
	IEEE80211_CH_B_ONLY = (1 << 2),
	IEEE80211_CH_NO_IBSS = (1 << 3),
	IEEE80211_CH_UNIFORM_SPREADING = (1 << 4),
@@ -976,10 +977,10 @@ enum {
  };

  struct ieee80211_channel {
-	u32 freq;
+	u32 freq;	/* in MHz */
	u8 channel;
	u8 flags;
-	u8 max_power;
+	u8 max_power;	/* in dBm */
  };

  struct ieee80211_geo {
