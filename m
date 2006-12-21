From: David Kimdon <david.kimdon@devicescape.com>
Subject: d80211: clear ifsta->associated flag when authentication starts
Date: Thu, 21 Dec 2006 14:32:08 -0800
Message-ID: <20061221223208.GA22697@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:52563 "EHLO
	mail.devicescape.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423109AbWLUWcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Dec 2006 17:32:14 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="auth-state-clear.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 'associated' flag might be set if a previous association did not
end cleanly.  If the 'associated' flag is left set here then when
association succeeds ieee80211_set_associated() will think there is
nothing to report and will not inform userspace of the event.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/net/d80211/ieee80211_sta.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_sta.c
+++ wireless-dev/net/d80211/ieee80211_sta.c
@@ -1960,7 +1960,7 @@ static void ieee80211_sta_new_auth(struc
 	printk(KERN_DEBUG "%s: Initial auth_alg=%d\n", dev->name,
 	       ifsta->auth_alg);
 	ifsta->auth_transaction = -1;
-	ifsta->auth_tries = ifsta->assoc_tries = 0;
+	ifsta->associated = ifsta->auth_tries = ifsta->assoc_tries = 0;
 	ieee80211_authenticate(dev, ifsta);
 }
 

--
