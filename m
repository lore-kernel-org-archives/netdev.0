From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 14/18] d80211: allow wireless vlan interface to have same MAC an AP interface
Date: Wed, 18 Oct 2006 17:49:38 +0200 (CEST)
Message-ID: <20061018154938.08BBD481DD@silver.suse.cz>
References: <20061018174838.116675768.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:15778 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1161208AbWJRPtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 11:49:09 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061018174838.116675768.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Kimdon <david.kimdon@devicescape.com>

Wireless vlan interfaces need to have the same mac address as
AP interfaces.  The STA must not see the change when it is bound to
a specific vlan, so the address of the vlan interface must be the same
as the address of the AP interface the station associated with.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

afff04d301dabfe05bb9bc5e4bb378c1b9223d45
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 2614514..86062c9 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -2096,7 +2096,12 @@ static inline int identical_mac_addr_all
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
1.3.0

