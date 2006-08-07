From: Jouni Malinen <jkm@devicescape.com>
Subject: [PATCH wireless-dev 2/6] d80211: Fix PS-Poll frame dropping
Date: Mon, 07 Aug 2006 16:16:10 -0700
Message-ID: <20060807231937.611726656@localhost>
References: <20060807231608.888744720@localhost>
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	jkm@devicescape.com, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-17.dex002.intermedia.net ([64.78.21.83]:50801 "EHLO
	dhost002-17.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751196AbWHGXYA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 19:24:00 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline; filename=ibss_drop.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed PS-Poll processing for STAs that are not authenticated or
associated:
- 80211.ko dropped these frames even though it should have sent them
  to hostapd (this was broken by addition of IBSS support)

Signed-off-by: Jouni Malinen <jkm@devicescape.com>

Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c
+++ wireless-dev/net/d80211/ieee80211.c
@@ -3074,8 +3074,9 @@ ieee80211_rx_h_check(struct ieee80211_tx
 		     rx->sdata->type != IEEE80211_IF_TYPE_IBSS &&
 		     (!rx->sta || !(rx->sta->flags & WLAN_STA_ASSOC)))) {
 		if ((!(rx->fc & IEEE80211_FCTL_FROMDS) &&
-		     !(rx->fc & IEEE80211_FCTL_TODS)) ||
-		    !rx->u.rx.ra_match) {
+		     !(rx->fc & IEEE80211_FCTL_TODS) &&
+		     (rx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA)
+		    || !rx->u.rx.ra_match) {
 			/* Drop IBSS frames and frames for other hosts
 			 * silently. */
 			return TXRX_DROP;

--
-- 
Jouni Malinen                                            PGP id EFC895FA
