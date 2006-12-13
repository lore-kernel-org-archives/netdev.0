From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] d80211: Fix passing of invalid pointer
Date: Wed, 13 Dec 2006 18:52:33 +0100
Message-ID: <200612131852.33463.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:48427
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965057AbWLMRxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 12:53:05 -0500
To: Jiri Benc <jbenc@suse.cz>, John Linville <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ieee80211_hw pointers have to be passed to ops->set_key()
and ops->get_tsf().

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: jbenc-dscape.git/net/d80211/ieee80211_iface.c
===================================================================
--- jbenc-dscape.git.orig/net/d80211/ieee80211_iface.c	2006-12-13 13:23:56.000000000 +0100
+++ jbenc-dscape.git/net/d80211/ieee80211_iface.c	2006-12-13 18:46:33.000000000 +0100
@@ -228,8 +228,8 @@ void ieee80211_if_reinit(struct net_devi
 		 * really much point in disabling the keys at this point. */
 		memset(addr, 0xff, ETH_ALEN);
 		if (local->ops->set_key)
-			local->ops->set_key(dev, DISABLE_KEY, addr,
-					   local->keys[i], 0);
+			local->ops->set_key(local_to_hw(local), DISABLE_KEY, addr,
+					    local->keys[i], 0);
 #endif
 		ieee80211_key_free(sdata->keys[i]);
 	}
Index: jbenc-dscape.git/net/d80211/ieee80211_sta.c
===================================================================
--- jbenc-dscape.git.orig/net/d80211/ieee80211_sta.c	2006-12-13 18:42:47.000000000 +0100
+++ jbenc-dscape.git/net/d80211/ieee80211_sta.c	2006-12-13 18:50:14.000000000 +0100
@@ -1365,7 +1365,7 @@ static void ieee80211_rx_bss_info(struct
 		static unsigned long last_tsf_debug = 0;
 		u64 tsf;
 		if (local->ops->get_tsf)
-			tsf = local->ops->get_tsf(local->mdev);
+			tsf = local->ops->get_tsf(local_to_hw(local));
 		else
 			tsf = -1LLU;
 		if (time_after(jiffies, last_tsf_debug + 5 * HZ)) {

-- 
Greetings Michael.
