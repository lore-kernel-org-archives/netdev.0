From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 12/13] d80211: remove calib_int
Date: Sun, 19 Nov 2006 20:32:16 +0100
Message-ID: <1163964736.15473.63.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
	 <1163963898.15473.36.camel@johannes.berg>
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
Received: from crystal.sipsolutions.net ([195.210.38.204]:36028 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S933072AbWKSTfi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 14:35:38 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1163963898.15473.36.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The calibration interval is far too hardware dependent to be useful as a
generic stack setting and some hardware doesn't even have that parameter.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/include/net/d80211.h	2006-11-19 20:14:02.289275208 +0100
+++ wireless-dev/include/net/d80211.h	2006-11-19 20:14:02.959275208 +0100
@@ -259,8 +259,6 @@ struct ieee80211_conf {
 			  		 *	1 = Ant0,
 					 *	2 = Ant1 */
 
-	int calib_int;			/* hw/radio calibration interval in
-					 * seconds */
         int antenna_def;
         int antenna_mode;
 
--- wireless-dev.orig/net/d80211/ieee80211.c	2006-11-19 20:14:02.299275208 +0100
+++ wireless-dev/net/d80211/ieee80211.c	2006-11-19 20:14:02.959275208 +0100
@@ -4473,7 +4473,6 @@ struct ieee80211_hw *ieee80211_alloc_hw(
 	local->fragmentation_threshold = IEEE80211_MAX_FRAG_THRESHOLD;
 	local->short_retry_limit = 7;
 	local->long_retry_limit = 4;
-	local->hw.conf.calib_int = 60;
 	local->hw.conf.radio_enabled = 1;
 	local->rate_ctrl_num_up = RATE_CONTROL_NUM_UP;
 	local->rate_ctrl_num_down = RATE_CONTROL_NUM_DOWN;
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c	2006-11-19 20:14:02.299275208 +0100
+++ wireless-dev/net/d80211/ieee80211_ioctl.c	2006-11-19 20:14:02.969275208 +0100
@@ -2480,12 +2480,6 @@ static int ieee80211_ioctl_prism2_param(
 			ret = -EINVAL;
 		break;
 
-	case PRISM2_PARAM_CALIB_INT:
-		local->hw.conf.calib_int = value;
-		if (ieee80211_hw_config(local))
-			ret = -EINVAL;
-		break;
-
 	case PRISM2_PARAM_ANTENNA_MODE:
 		local->hw.conf.antenna_mode = value;
 		if (ieee80211_hw_config(local))
@@ -2687,10 +2681,6 @@ static int ieee80211_ioctl_get_prism2_pa
 		*param = local->hw.conf.antenna_sel;
 		break;
 
-	case PRISM2_PARAM_CALIB_INT:
-		*param = local->hw.conf.calib_int;
-		break;
-
 	case PRISM2_PARAM_ANTENNA_MODE:
 		*param = local->hw.conf.antenna_mode;
 		break;
--- wireless-dev.orig/net/d80211/ieee80211_sysfs.c	2006-11-19 20:13:58.059275208 +0100
+++ wireless-dev/net/d80211/ieee80211_sysfs.c	2006-11-19 20:14:02.969275208 +0100
@@ -154,7 +154,6 @@ IEEE80211_LOCAL_SHOW(channel, hw.conf.ch
 IEEE80211_LOCAL_SHOW(frequency, hw.conf.freq, "%d");
 IEEE80211_LOCAL_SHOW(radar_detect, hw.conf.radar_detect, "%d");
 IEEE80211_LOCAL_SHOW(antenna_sel, hw.conf.antenna_sel, "%d");
-IEEE80211_LOCAL_SHOW(calib_int, hw.conf.calib_int, "%d");
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


