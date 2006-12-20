From: Hong Liu <hong.liu@intel.com>
Subject: [PATCH] d80211: fix softlockup in hw_scan card when rmmod
Date: Wed, 20 Dec 2006 14:43:51 +0800
Message-ID: <1166597031.22413.11.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14466 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964924AbWLTGyP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Dec 2006 01:54:15 -0500
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The local->scan_work.data is not clear after scan is completed.

This will cause softlockup when removing driver module because 
the local->scan_work is not initialized for hw_scan card
and we are trying to cancel the scan_work with an uninitialized timer_list.



Signed-off-by: Hong Liu <hong.liu@intel.com>

diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 507d071..3b55427 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -3641,6 +3641,7 @@ void ieee80211_scan_completed(struct iee
 	printk(KERN_DEBUG "%s: scan completed\n", dev->name);
 	spin_lock_bh(&local->ifsta_data_lock);
 	local->sta_scanning = 0;
+	local->scan_work.data = NULL;
 	local->last_scan_completed = jiffies;
 	spin_unlock_bh(&local->ifsta_data_lock);
 
