From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch 5/5] d80211: allow wireless vlan interface to have same MAC an AP interface
Date: Tue, 3 Oct 2006 11:12:33 -0700
Message-ID: <20061003181233.GE19403@devicescape.com>
References: <20061003181118.537800000@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-66.dex002.intermedia.net ([64.78.20.24]:58412 "EHLO
	DHOST002-66.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751023AbWJCSMp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 14:12:45 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="vlan-macaddr.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wireless vlan interfaces need to have the same mac address as
AP interfaces.  The STA must not see the change when it is bound to
a specific vlan, so the address of the vlan interface must be the same
as the address of the AP interface the station associated with.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>
 
Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c
+++ wireless-dev/net/d80211/ieee80211.c
@@ -2092,7 +2092,12 @@ static inline int identical_mac_addr_all
 		 type2 == IEEE80211_IF_TYPE_WDS) ||
 		(type1 == IEEE80211_IF_TYPE_WDS &&
 		 (type2 == IEEE80211_IF_TYPE_WDS ||
-		  type2 == IEEE80211_IF_TYPE_AP)));
+		  type2 == IEEE80211_IF_TYPE_AP)) ||
+		(type1 == IEEE80211_IF_TYPE_AP &&
+		 type2 == IEEE80211_IF_TYPE_VLAN) ||
+		(type1 == IEEE80211_IF_TYPE_VLAN &&
+		 (type2 == IEEE80211_IF_TYPE_AP ||
+		  type2 == IEEE80211_IF_TYPE_VLAN)));
 }
 
 static int ieee80211_master_open(struct net_device *dev)

--
