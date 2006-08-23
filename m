From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 19/21] d80211: fix multiple device support
Date: Wed, 23 Aug 2006 21:24:28 +0200 (CEST)
Message-ID: <20060823192428.7B8AE483B8@silver.suse.cz>
References: <20060823212316.333159079.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:30928 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965146AbWHWTY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 15:24:28 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060823212316.333159079.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Kimdon <david.kimdon@devicescape.com>

Fix interpretation of dev_alloc_name() return value.  dev_alloc_name()
returns the number of the unit assigned or a negative errno code.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_iface.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

a13193956bee479d72bad1bc1ccbcb831182b3d3
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 9a9d730..bdff4cd 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -64,7 +64,7 @@ int ieee80211_if_add(struct net_device *
 		} while (i < 10000);
 	} else if (format) {
 		ret = dev_alloc_name(ndev, name);
-		if (ret)
+		if (ret < 0)
 			goto fail;
 	} else {
 		snprintf(ndev->name, IFNAMSIZ, "%s", name);
-- 
1.3.0

