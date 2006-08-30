From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] d80211: use BUILD_BUG_ON
Date: Wed, 30 Aug 2006 10:39:30 +0200
Message-ID: <1156927170.4013.50.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>,
	Jouni Malinen <jkm@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:26335 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750700AbWH3Ij1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 04:39:27 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes d80211 use BUILD_BUG_ON instead of checking at module
initialisation time. This check really is only interesting while you
hack since if the module was built, then it's either an 'always true' or
'always false' comparison, hence useless to do it at runtime.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/ieee80211.c	2006-08-25 17:53:16.488836518 +0200
+++ wireless-dev/net/d80211/ieee80211.c	2006-08-25 18:01:59.148836518 +0200
@@ -4833,13 +4833,8 @@ static int __init ieee80211_init(void)
 	struct sk_buff *skb;
 	int ret;
 
-	if (sizeof(struct ieee80211_tx_packet_data) > (sizeof(skb->cb))) {
-		printk("80211: ieee80211_tx_packet_data is bigger "
-		       "than the skb->cb (%d > %d)\n",
-		       (int) sizeof(struct ieee80211_tx_packet_data),
-		       (int) sizeof(skb->cb));
-		return -EINVAL;
-	}
+	BUILD_BUG_ON(sizeof(struct ieee80211_tx_packet_data) > sizeof(skb->cb));
+
 	if ((ret = ieee80211_sysfs_init())) {
 		printk(KERN_WARNING "ieee80211_init: sysfs initialization "
 		       "failed\n");

