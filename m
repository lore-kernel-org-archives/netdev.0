From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH net] mac80211: free netdev on dev_alloc_name() error
Date: Fri,  9 Jun 2017 21:33:09 +0200
Message-ID: <20170609193309.14972-1-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:59156 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751554AbdFITdN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Jun 2017 15:33:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

The change to remove free_netdev() from ieee80211_if_free()
erroneously didn't add the necessary free_netdev() for when
ieee80211_if_free() is called directly in one place, rather
than as the priv_destructor. Add the missing call.

Fixes: cf124db566e6 ("net: Fix inconsistent teardown and release of private netdev state.")
Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/mac80211/iface.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 915d7e1b4545..f5f50150ba1c 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1816,6 +1816,7 @@ int ieee80211_if_add(struct ieee80211_local *local, const char *name,
 		ret = dev_alloc_name(ndev, ndev->name);
 		if (ret < 0) {
 			ieee80211_if_free(ndev);
+			free_netdev(ndev);
 			return ret;
 		}
 
-- 
2.11.0
