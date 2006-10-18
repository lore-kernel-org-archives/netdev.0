From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 2/18] d80211: add missing rtnl_unlock()
Date: Wed, 18 Oct 2006 17:49:25 +0200 (CEST)
Message-ID: <20061018154925.74ECF47F5F@silver.suse.cz>
References: <20061018174838.116675768.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:13474 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1161187AbWJRPs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 11:48:56 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061018174838.116675768.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add forgotten rtnl_unlock() in the error path of ieee80211_register_hw.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

693ca0e679ae17dd34f5392886f99ba36f68940c
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 3efba6a..036eca1 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4449,8 +4449,10 @@ int ieee80211_register_hw(struct net_dev
 	result = sysfs_create_link(&local->class_dev.kobj,
 				   &dev->class_dev.kobj,
 				   "master");
-	if (result < 0)
+	if (result < 0) {
+		rtnl_unlock();
 		goto fail_masterlink;
+	}
 	result = ieee80211_sysfs_add_netdevice(dev);
 	rtnl_unlock();
 	if (result < 0)
-- 
1.3.0

