From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] d80211: remove calib_int
Date: Sun, 19 Nov 2006 01:04:44 +0100
Message-ID: <1163894684.15473.8.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:59306 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1755448AbWKSAaS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Nov 2006 19:30:18 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1163802439.3392.47.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The calibration interval is far too hardware dependent to be useful as a
generic stack setting and some hardware doesn't even have that parameter.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

---
Again, applies after my other patches.. I think we want this one and
probably some way to have driver-private settings later.

 include/net/d80211.h         |    2 --
 net/d80211/ieee80211.c       |    1 -
 net/d80211/ieee80211_ioctl.c |   10 ----------
 net/d80211/ieee80211_sysfs.c |    2 --
 4 files changed, 15 deletions(-)

--- wireless-dev.orig/include/net/d80211.h	2006-11-19 00:54:57.539520302 +0100
+++ wireless-dev/include/net/d80211.h	2006-11-19 00:55:03.229520302 +0100
@@ -259,8 +259,6 @@ struct ieee80211_conf {
 			  		 *	1 = Ant0,
 					 *	2 = Ant1 */
 
-	int calib_int;			/* hw/radio calibration interval in
-					 * seconds */
         int antenna_def;
         int antenna_mode;
 
--- wireless-dev.orig/net/d80211/ieee80211.c	2006-11-19 00:55:21.929520302 +0100
+++ wireless-dev/net/d80211/ieee80211.c	2006-11-19 00:55:36.679520302 +0100
@@ -4473,7 +4473,6 @@ struct ieee80211_wiphy *ieee80211_alloc_
 	local->fragmentation_threshold = IEEE80211_MAX_FRAG_THRESHOLD;
 	local->short_retry_limit = 7;
 	local->long_retry_limit = 4;
-	local->wiphy.conf.calib_int = 60;
 	local->wiphy.conf.radio_enabled = 1;
 	local->rate_ctrl_num_up = RATE_CONTROL_NUM_UP;
 	local->rate_ctrl_num_down = RATE_CONTROL_NUM_DOWN;
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c	2006-11-19 00:55:22.049520302 +0100
+++ wireless-dev/net/d80211/ieee80211_ioctl.c	2006-11-19 00:55:49.879520302 +0100
@@ -2480,12 +2480,6 @@ static int ieee80211_ioctl_prism2_param(
 			ret = -EINVAL;
 		break;
 
-	case PRISM2_PARAM_CALIB_INT:
-		local->wiphy.conf.calib_int = value;
-		if (ieee80211_hw_config(local))
-			ret = -EINVAL;
-		break;
-
 	case PRISM2_PARAM_ANTENNA_MODE:
 		local->wiphy.conf.antenna_mode = value;
 		if (ieee80211_hw_config(local))
@@ -2687,10 +2681,6 @@ static int ieee80211_ioctl_get_prism2_pa
 		*param = local->wiphy.conf.antenna_sel;
 		break;
 
-	case PRISM2_PARAM_CALIB_INT:
-		*param = local->wiphy.conf.calib_int;
-		break;
-
 	case PRISM2_PARAM_ANTENNA_MODE:
 		*param = local->wiphy.conf.antenna_mode;
 		break;
--- wireless-dev.orig/net/d80211/ieee80211_sysfs.c	2006-11-19 00:55:22.169520302 +0100
+++ wireless-dev/net/d80211/ieee80211_sysfs.c	2006-11-19 00:55:58.189520302 +0100
@@ -154,7 +154,6 @@ IEEE80211_LOCAL_SHOW(channel, wiphy.conf
 IEEE80211_LOCAL_SHOW(frequency, wiphy.conf.freq, "%d");
 IEEE80211_LOCAL_SHOW(radar_detect, wiphy.conf.radar_detect, "%d");
 IEEE80211_LOCAL_SHOW(antenna_sel, wiphy.conf.antenna_sel, "%d");
-IEEE80211_LOCAL_SHOW(calib_int, wiphy.conf.calib_int, "%d");
 IEEE80211_LOCAL_SHOW(bridge_packets, bridge_packets, "%d");
 IEEE80211_LOCAL_SHOW(key_tx_rx_threshold, key_tx_rx_threshold, "%d");
 IEEE80211_LOCAL_SHOW(rts_threshold, rts_threshold, "%d");
@@ -220,7 +219,6 @@ static struct class_device_attribute iee
 	__ATTR(frequency, S_IRUGO, ieee80211_local_show_frequency, NULL),
 	__ATTR(radar_detect, S_IRUGO, ieee80211_local_show_radar_detect, NULL),
 	__ATTR(antenna_sel, S_IRUGO, ieee80211_local_show_antenna_sel, NULL),
-	__ATTR(calib_int, S_IRUGO, ieee80211_local_show_calib_int, NULL),
 	__ATTR(bridge_packets, S_IRUGO, ieee80211_local_show_bridge_packets, NULL),
 	__ATTR(key_tx_rx_threshold, S_IRUGO, ieee80211_local_show_key_tx_rx_threshold, NULL),
 	__ATTR(rts_threshold, S_IRUGO, ieee80211_local_show_rts_threshold, NULL),


