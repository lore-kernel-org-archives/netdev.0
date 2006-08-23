From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 2/21] d80211: master link
Date: Wed, 23 Aug 2006 21:24:10 +0200 (CEST)
Message-ID: <20060823192410.BB0D44839E@silver.suse.cz>
References: <20060823212316.333159079.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:27088 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965114AbWHWTYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 15:24:10 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060823212316.333159079.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>

This patch adds a link from the wiphy to the master device in sysfs.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

a648a95b7eb82496b6a2148105228cbc1724e2f1
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 11804d5..0b3c886 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4462,6 +4462,11 @@ int ieee80211_register_hw(struct net_dev
 		rtnl_unlock();
 		goto fail_dev;
 	}
+	result = sysfs_create_link(&local->class_dev.kobj,
+				   &dev->class_dev.kobj,
+				   "master");
+	if (result < 0)
+		goto fail_masterlink;
 	result = ieee80211_sysfs_add_netdevice(dev);
 	rtnl_unlock();
 	if (result < 0)
@@ -4507,6 +4512,8 @@ fail_rate_attrs:
 fail_rate:
 	ieee80211_sysfs_remove_netdevice(dev);
 fail_if_sysfs:
+	sysfs_remove_link(&local->class_dev.kobj, "master");
+fail_masterlink:
 	unregister_netdev(dev);
 fail_dev:
 	sta_info_stop(local);
@@ -4563,6 +4570,8 @@ void ieee80211_unregister_hw(struct net_
 	if (local->apdev)
 		ieee80211_if_del_mgmt(local->apdev);
 
+	sysfs_remove_link(&local->class_dev.kobj, "master");
+
 	list_for_each_safe(ptr, n, &local->sub_if_list) {
 		struct ieee80211_sub_if_data *sdata =
 			list_entry(ptr, struct ieee80211_sub_if_data, list);
-- 
1.3.0

