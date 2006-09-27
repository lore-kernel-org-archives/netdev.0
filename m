From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 6/14] d80211: fix multiple device ap support
Date: Wed, 27 Sep 2006 17:50:50 +0200 (CEST)
Message-ID: <20060927155050.F21F33BA24B@silver.suse.cz>
References: <20060927175006.637430015.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:50060 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964976AbWI0Ptq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 11:49:46 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060927175006.637430015.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Kimdon <david.kimdon@devicescape.com>

Another fix to the interpretation of dev_alloc_name() return value.
dev_alloc_name() returns the number of the unit assigned or a negative
errno code.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_iface.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

51539cf2d4fd958fa9a5ea282a9b7272353d0a49
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index bdff4cd..0a10c86 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -122,7 +122,7 @@ int ieee80211_if_add_mgmt(struct net_dev
 	if (!ndev)
 		return -ENOMEM;
 	ret = dev_alloc_name(ndev, "wmgmt%d");
-	if (ret)
+	if (ret < 0)
 		goto fail;
 
 	ndev->ieee80211_ptr = local;
-- 
1.3.0

