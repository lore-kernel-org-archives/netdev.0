From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 1/3] d80211: do not receive through master interface
Date: Fri, 23 Jun 2006 20:16:34 +0200 (CEST)
Message-ID: <20060623181634.56509483AB@silver.suse.cz>
References: <20060623201604.835047000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mbuesch@freenet.de>,
	Alexander Tsvyashchenko <lists@ndl.kiev.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:51370 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1751868AbWFWSPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 14:15:11 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060623201604.835047000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arrived packets should not go into master interface - it leads to duplicate
packets reception.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---
 net/d80211/ieee80211.c |    4 ++++
 1 files changed, 4 insertions(+)

--- dscape.orig/net/d80211/ieee80211.c
+++ dscape/net/d80211/ieee80211.c
@@ -3586,6 +3586,10 @@ void __ieee80211_rx(struct net_device *d
 					   !ieee80211_bssid_match(bssid,
 							sdata->dev->dev_addr))
 					continue;
+				if (sdata->dev == sdata->master)
+					/* do not receive anything via
+					 * master device */
+					continue;
 				break;
 			case IEEE80211_IF_TYPE_WDS:
 				if (bssid ||
