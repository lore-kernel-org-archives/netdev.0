From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch 3/5] d80211: fix interface removal
Date: Tue, 22 Aug 2006 10:33:53 -0700
Message-ID: <20060822173353.GD12500@devicescape.com>
References: <20060822173241.313859000@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-62.dex002.intermedia.net ([64.78.20.11]:1437 "EHLO
	dhost002-62.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1750973AbWHVRdy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 13:33:54 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="remove-if-type.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Calls to ieee80211_if_remove() should use the ieee80211 interface types.
Convert interface type from hostapd to ieee80211 format.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/net/d80211/ieee80211_ioctl.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c
+++ wireless-dev/net/d80211/ieee80211_ioctl.c
@@ -1076,14 +1076,21 @@ static int ieee80211_ioctl_add_if(struct
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
+        return -EINVAL;
 	}
-	return ieee80211_if_remove(dev, param->u.if_info.name,
-				   param->u.if_info.type);
+
+	return ieee80211_if_remove(dev, param->u.if_info.name, type);
 }
 
 

--
