From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] d80211: constify ieee80211_ops pointer
Date: Sat, 16 Dec 2006 23:57:03 +0100
Message-ID: <200612162357.03541.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:55311
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422751AbWLPW6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Dec 2006 17:58:08 -0500
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

const-ify the ieee80211_ops pointer to allow
* The compiler to do opimizations
* The drivers to declare this structure const.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: jbenc-dscape/include/net/d80211.h
===================================================================
--- jbenc-dscape.orig/include/net/d80211.h	2006-12-16 23:52:35.000000000 +0100
+++ jbenc-dscape/include/net/d80211.h	2006-12-16 23:53:51.000000000 +0100
@@ -740,7 +740,7 @@ struct ieee80211_ops {
  * priv_data_len.
  */
 struct ieee80211_hw *ieee80211_alloc_hw(size_t priv_data_len,
-					struct ieee80211_ops *ops);
+					const struct ieee80211_ops *ops);
 
 /* Register hardware device to the IEEE 802.11 code and kernel. Low-level
  * drivers must call this function before using any other IEEE 802.11
Index: jbenc-dscape/net/d80211/ieee80211.c
===================================================================
--- jbenc-dscape.orig/net/d80211/ieee80211.c	2006-12-16 23:52:35.000000000 +0100
+++ jbenc-dscape/net/d80211/ieee80211.c	2006-12-16 23:54:19.000000000 +0100
@@ -4392,7 +4392,7 @@ static void rate_control_deinitialize(st
 }
 
 struct ieee80211_hw *ieee80211_alloc_hw(size_t priv_data_len,
-					      struct ieee80211_ops *ops)
+					const struct ieee80211_ops *ops)
 {
 	struct net_device *mdev;
         struct ieee80211_local *local;
Index: jbenc-dscape/net/d80211/ieee80211_i.h
===================================================================
--- jbenc-dscape.orig/net/d80211/ieee80211_i.h	2006-12-16 23:52:35.000000000 +0100
+++ jbenc-dscape/net/d80211/ieee80211_i.h	2006-12-16 23:54:32.000000000 +0100
@@ -333,7 +333,7 @@ struct ieee80211_local {
 	 * it first anyway so they become a no-op */
 	struct ieee80211_hw hw;
 
-	struct ieee80211_ops *ops;
+	const struct ieee80211_ops *ops;
 
 	/* List of registered struct ieee80211_hw_mode */
 	struct list_head modes_list;


-- 
Greetings Michael.
