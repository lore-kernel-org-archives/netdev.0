From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 9/14] d80211: allow vlan interfaces to receive ToDS frames
Date: Wed, 27 Sep 2006 17:50:54 +0200 (CEST)
Message-ID: <20060927155054.14C483BA253@silver.suse.cz>
References: <20060927175006.637430015.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:50316 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964972AbWI0Pts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 11:49:48 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060927175006.637430015.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Kimdon <david.kimdon@devicescape.com>

Interfaces of type IEEE80211_IF_TYPE_VLAN are similar to AP
interfaces. One difference is stations are bound to a particular
vlan interface after authentication/association based on
management policy (for example a radius server).

Interfaces of type IEEE80211_IF_TYPE_VLAN need to be able to
receive ToDS frames.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

c220ae6162f23935ebc141b6734ecad1ab435294
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 76ecad8..4fee86c 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -2374,7 +2374,8 @@ ieee80211_rx_h_data(struct ieee80211_txr
 		memcpy(dst, hdr->addr3, ETH_ALEN);
 		memcpy(src, hdr->addr2, ETH_ALEN);
 
-		if (unlikely(sdata->type != IEEE80211_IF_TYPE_AP)) {
+		if (unlikely(sdata->type != IEEE80211_IF_TYPE_AP &&
+			     sdata->type != IEEE80211_IF_TYPE_VLAN)) {
 			printk(KERN_DEBUG "%s: dropped ToDS frame (BSSID="
 			       MAC_FMT " SA=" MAC_FMT " DA=" MAC_FMT ")\n",
 			       dev->name, MAC_ARG(hdr->addr1),
-- 
1.3.0

