From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 2/2] fix some wireless ext stuff
Date: Wed, 13 Dec 2006 18:00:37 +0100 (CET)
Message-ID: <20061213170037.EFC3F3AA7F0@silver.suse.cz>
References: <20061213180032.241265000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:44739 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965034AbWLMQ4G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 11:56:06 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061213180032.241265000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>

This fixes compilation with d80211/cfg80211/wireless ext.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

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


