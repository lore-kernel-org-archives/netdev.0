From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] fix some wireless ext stuff
Date: Wed, 06 Dec 2006 12:43:46 +0100
Message-ID: <1165405426.4409.4.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:46071 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760611AbWLFNsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 08:48:51 -0500
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes compilation with d80211/cfg80211/wireless ext.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- linux-2.6-git.orig/net/core/net-sysfs.c	2006-12-06 12:31:04.247283692 +0100
+++ linux-2.6-git/net/core/net-sysfs.c	2006-12-06 12:31:11.865215130 +0100
@@ -329,7 +329,7 @@
 	.attrs  = netstat_attrs,
 };
 
-#ifdef WIRELESS_EXT
+#ifdef CONFIG_WIRELESS_EXT
 /* helper function that does all the locking etc for wireless stats */
 static ssize_t wireless_show(struct class_device *cd, char *buf,
 			     ssize_t (*format)(const struct iw_statistics *,
@@ -462,7 +462,7 @@
 	if (net->get_stats)
 		*groups++ = &netstat_group;
 
-#ifdef WIRELESS_EXT
+#ifdef CONFIG_WIRELESS_EXT
 	if (net->wireless_handlers && net->wireless_handlers->get_wireless_stats)
 		*groups++ = &wireless_group;
 #endif
--- linux-2.6-git.orig/net/d80211/Kconfig	2006-12-06 12:31:58.903791779 +0100
+++ linux-2.6-git/net/d80211/Kconfig	2006-12-06 12:32:07.355715711 +0100
@@ -3,6 +3,7 @@
 	select CRYPTO
 	select CRYPTO_ARC4
 	select CRYPTO_AES
+	select WIRELESS_EXT
 	---help---
 	This option enables the hardware independent IEEE 802.11
 	networking stack.
--- linux-2.6-git.orig/net/wireless/Makefile	2006-12-06 12:35:58.838632346 +0100
+++ linux-2.6-git/net/wireless/Makefile	2006-12-06 12:36:03.541590019 +0100
@@ -12,5 +12,5 @@
 
 # this needs to be compiled in...
 obj-$(CONFIG_CFG80211_WEXT_COMPAT) += wext-compat.o
-obj-$(CONFIG_CFG80211_WEXTNL_COMPAT)$(CONFIG_NET_WIRELESS) += wext-common.o
+obj-$(CONFIG_CFG80211_WEXT_COMPAT)$(CONFIG_NET_WIRELESS) += wext-common.o
 obj-y += $(obj-yy) $(obj-yn) $(obj-ny)


