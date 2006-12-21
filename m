From: David Kimdon <david.kimdon@devicescape.com>
Subject: d80211: inhibit duplicate authentication requests when setting bssid
Date: Thu, 21 Dec 2006 14:33:06 -0800
Message-ID: <20061221223306.GB22697@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:52620 "EHLO
	mail.devicescape.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423126AbWLUWdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Dec 2006 17:33:08 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="auth.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If we are already authenticating don't send another authentication
request.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/net/d80211/ieee80211_sta.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_sta.c
+++ wireless-dev/net/d80211/ieee80211_sta.c
@@ -2392,7 +2392,7 @@ int ieee80211_sta_set_bssid(struct net_d
 		ifsta->bssid_set = 0;
 	else
 		ifsta->bssid_set = 1;
-	if (ifsta->ssid_set)
+	if (ifsta->ssid_set && ifsta->state != IEEE80211_AUTHENTICATE)
 		ieee80211_sta_new_auth(dev, ifsta);
 
 	return 0;

--
