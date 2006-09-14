From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch] d80211: allow vlan interfaces to receive ToDS frames
Date: Thu, 14 Sep 2006 07:33:56 -0700
Message-ID: <20060914143356.GB1962@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-4.dex002.intermedia.net ([64.78.21.18]:17991 "EHLO
	dhost002-4.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1750825AbWINOfU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Sep 2006 10:35:20 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="if_type_vlan_tods.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Interfaces of type IEEE80211_IF_TYPE_VLAN are similar to AP
interfaces. One difference is stations are bound to a particular
vlan interface after authentication/association based on
management policy (for example a radius server).

Interfaces of type IEEE80211_IF_TYPE_VLAN need to be able to
receive ToDS frames.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c
+++ wireless-dev/net/d80211/ieee80211.c
@@ -2353,7 +2353,8 @@ ieee80211_rx_h_data(struct ieee80211_txr
 		memcpy(dst, hdr->addr3, ETH_ALEN);
 		memcpy(src, hdr->addr2, ETH_ALEN);
 
-		if (unlikely(sdata->type != IEEE80211_IF_TYPE_AP)) {
+		if (unlikely(sdata->type != IEEE80211_IF_TYPE_AP &&
+			     sdata->type != IEEE80211_IF_TYPE_VLAN)) {
 			printk(KERN_DEBUG "%s: dropped ToDS frame (BSSID="
 			       MAC_FMT " SA=" MAC_FMT " DA=" MAC_FMT ")\n",
 			       dev->name, MAC_ARG(hdr->addr1),

--
