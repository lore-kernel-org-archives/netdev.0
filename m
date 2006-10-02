From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 1/8] d80211: add missing rtnl_unlock()
Date: Mon,  2 Oct 2006 20:26:05 +0200 (CEST)
Message-ID: <20061002182605.1210E47F2C@silver.suse.cz>
References: <20061002202530.235763132.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:40135 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965241AbWJBSYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 14:24:52 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20061002202530.235763132.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add forgotten rtnl_unlock() in the error path of ieee80211_register_hw.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

a0ed5768c0c3b9481dda8b59f6a183e000451acf
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

