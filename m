From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 20/21] d80211: fix interface removal
Date: Wed, 23 Aug 2006 21:24:29 +0200 (CEST)
Message-ID: <20060823192429.835F9483B9@silver.suse.cz>
References: <20060823212316.333159079.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:31184 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965148AbWHWTY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 15:24:29 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060823212316.333159079.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Kimdon <david.kimdon@devicescape.com>

Calls to ieee80211_if_remove() should use the ieee80211 interface types.
Convert interface type from hostapd to ieee80211 format.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_ioctl.c |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

6014cc141587c2c7e73abb985f7741dc7e24c105
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 53b7841..89a58e3 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -1070,14 +1070,21 @@ #endif
 static int ieee80211_ioctl_remove_if(struct net_device *dev,
 				     struct prism2_hostapd_param *param)
 {
-	if (param->u.if_info.type != HOSTAP_IF_WDS &&
-	    param->u.if_info.type != HOSTAP_IF_VLAN &&
-	    param->u.if_info.type != HOSTAP_IF_BSS &&
-	    param->u.if_info.type != HOSTAP_IF_STA) {
-                return -EINVAL;
+	unsigned int type;
+
+	if (param->u.if_info.type == HOSTAP_IF_WDS) {
+		type = IEEE80211_IF_TYPE_WDS;
+	} else if (param->u.if_info.type == HOSTAP_IF_VLAN) {
+		type = IEEE80211_IF_TYPE_VLAN;
+	} else if (param->u.if_info.type == HOSTAP_IF_BSS) {
+		type = IEEE80211_IF_TYPE_AP;
+	} else if (param->u.if_info.type == HOSTAP_IF_STA) {
+		type = IEEE80211_IF_TYPE_STA;
+	} else {
+		return -EINVAL;
 	}
-	return ieee80211_if_remove(dev, param->u.if_info.name,
-				   param->u.if_info.type);
+
+	return ieee80211_if_remove(dev, param->u.if_info.name, type);
 }
 
 
-- 
1.3.0

