From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] wireless-dev: relax sysfs permissions
Date: Wed, 16 Aug 2006 15:49:45 +0200
Message-ID: <1155736186.3600.29.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:40407 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751179AbWHPNuR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 09:50:17 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sysfs attributes add_iface and remove_iface both check for
CAP_NET_ADMIN whenever something is written. Hence, permissions for the
files should be relaxed so that someone who is not root but happens to
have CAP_NET_ADMIN can do things.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/ieee80211_sysfs.c	2006-08-16 15:45:41.000000000 +0200
+++ wireless-dev/net/d80211/ieee80211_sysfs.c	2006-08-16 15:46:05.000000000 +0200
@@ -195,8 +195,8 @@
 __IEEE80211_LOCAL_SHOW(rate_ctrl_alg);
 
 static struct class_device_attribute ieee80211_class_dev_attrs[] = {
-	__ATTR(add_iface, S_IWUSR, NULL, store_add_iface),
-	__ATTR(remove_iface, S_IWUSR, NULL, store_remove_iface),
+	__ATTR(add_iface, S_IWUGO, NULL, store_add_iface),
+	__ATTR(remove_iface, S_IWUGO, NULL, store_remove_iface),
 	__ATTR(channel, S_IRUGO, ieee80211_local_show_channel, NULL),
 	__ATTR(frequency, S_IRUGO, ieee80211_local_show_frequency, NULL),
 	__ATTR(radar_detect, S_IRUGO, ieee80211_local_show_radar_detect, NULL),

