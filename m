From: David Lamparter <lists@diac24.net>
Subject: mac80211 ad-hoc: carrier not set up [was: Panic in ieee_80211_ibss_add_sta]
Date: Tue, 15 May 2007 21:33:09 +0200
Message-ID: <20070515193309.GA29184@charon.n2.diac24.net>
References: <20070515152842.GA26481@charon.n2.diac24.net> <20070515171202.GD15105@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 91-65-240-14-dynip.superkabel.de ([91.65.240.14]:43498 "EHLO
	charon.n2.diac24.net" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1756541AbXEOTdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 15:33:13 -0400
Content-Disposition: inline
In-Reply-To: <20070515171202.GD15105@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 15, 2007 at 01:12:02PM -0400, John W. Linville wrote:
> Patch below...does this work better?  Looks like upstream needs
> it too...

Yup, this fixes it. Thanks for the quick fix.

However, ad-hoc still does not work, since the network device's
carrier status does not seem to be properly set. (It remains
in NO-CARRIER even after "wlan0: Selected IBSS BSSID
92:68:a2:db:de:45 based on configured SSID". I dirtily hacked
around that with the following two-liner:

--- wireless-dev/net/mac80211/ieee80211_sta.c.orig	2007-05-15 20:19:55.000000000 +0200
+++ wireless-dev/net/mac80211/ieee80211_sta.c	2007-05-15 21:19:38.362587215 +0200
@@ -2448,6 +2448,7 @@
 	mod_timer(&ifsta->timer, jiffies + IEEE80211_IBSS_MERGE_INTERVAL);
 
 	ieee80211_rx_bss_put(dev, bss);
+	netif_carrier_on(dev);
 
 	return res;
 }
@@ -2648,6 +2649,7 @@
 
 	ifsta->ssid_set = len ? 1 : 0;
 	if (sdata->type == IEEE80211_IF_TYPE_IBSS && !ifsta->bssid_set) {
+		netif_carrier_off(dev);
 		ifsta->ibss_join_req = jiffies;
 		ifsta->state = IEEE80211_IBSS_SEARCH;
 		return ieee80211_sta_find_ibss(dev, ifsta);


However, I have NO CLUE WHAT I'M DOING THERE! Make a proper fix!
(Especially, I think it needs more netif_carrier_off calls in
different places.)


Anyway, thanks for my now-working wireless,

David Lamparter

