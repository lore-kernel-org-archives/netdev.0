From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] cfg80211: fix initialisation if built-in
Date: Mon, 10 Sep 2007 13:44:45 +0200
Message-ID: <1189424685.4506.63.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Rob Hussey <robjhussey@gmail.com>, stable@kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:49253 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932308AbXIJLnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 07:43:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When cfg80211 is built into the kernel it needs to init earlier
so that device registrations are run after it has initialised.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

---
 net/wireless/core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- wireless-dev.orig/net/wireless/core.c	2007-09-10 13:00:18.567257487 +0200
+++ wireless-dev/net/wireless/core.c	2007-09-10 13:00:59.837219347 +0200
@@ -363,7 +363,7 @@ out_fail_notifier:
 out_fail_sysfs:
 	return err;
 }
-module_init(cfg80211_init);
+subsys_initcall(cfg80211_init);
 
 static void cfg80211_exit(void)
 {


