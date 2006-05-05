From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH wireless-dev] d80211: Don't discriminate against 802.11b drivers
Date: Thu, 4 May 2006 22:32:35 -0400
Message-ID: <200605042232.35446.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, "Jouni Malinen" <jkm@devicescape.com>,
	netdev@vger.kernel.org, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:29540 "EHLO
	annwn14.rutgers.edu") by vger.kernel.org with ESMTP id S932444AbWEECcc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 22:32:32 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This makes the current hack used to prevent 802.11g cards from scanning with 
802.11b channels not break scanning in 802.11b drivers.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>

diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 2720f1d..5c8fe22 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -2566,7 +2566,7 @@ int ieee80211_sta_req_scan(struct net_de
 		memcpy(local->scan_ssid, ssid, ssid_len);
 	} else
 		local->scan_ssid_len = 0;
-	local->scan_skip_11b = 1; /* FIX: clear this is 11g is not supported */
+	local->scan_skip_11b = local->hw->num_modes > 1;
 	local->scan_state = SCAN_SET_CHANNEL;
 	local->scan_hw_mode_idx = 0;
 	local->scan_channel_idx = 0;
