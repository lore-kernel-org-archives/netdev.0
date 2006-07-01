From: Gertjan van Wingerde <gwingerde@kpnplanet.nl>
Subject: [PATCH] d80211: Take lowlevel driver's channel change time into account
 during scanning.
Date: Sat, 01 Jul 2006 22:40:38 +0200
Message-ID: <44A6DDC6.1040005@kpnplanet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, jkmaline@cc.hut.fi,
	linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from CPEXFE-VOIP04.KPNplanet.nl ([194.151.105.222]:56167 "EHLO
	cpexfe-voip04.KPNplanet.nl") by vger.kernel.org with ESMTP
	id S1751924AbWGAUiG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Jul 2006 16:38:06 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the dscape stack take the driver-supplied channel change time into 
account when actively scanning for networks.
This particularly has been a problem in the rt2x00 driver, where 
configuration changes are done via a work-queue, and
the subsequent channel changes failed due to the dscape stack scheduling 
a channel update while the previous one had not
been performed yet, resulting in failed scans.

Signed-off-by: Gertjan van Wingerde <gwingerde@kpnplanet.nl>

diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 37d40aa..9f8653d 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -2503,7 +2503,8 @@ #endif
                        break;
                }

-               local->scan_timer.expires = jiffies + IEEE80211_PROBE_DELAY;
+               local->scan_timer.expires = jiffies + IEEE80211_PROBE_DELAY +
+                             usecs_to_jiffies(local->hw->channel_change_time);
                local->scan_state = SCAN_SEND_PROBE;
                break;
        case SCAN_SEND_PROBE:




