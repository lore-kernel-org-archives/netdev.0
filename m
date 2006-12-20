From: Hong Liu <hong.liu@intel.com>
Subject: [PATCH] d80211: fix get_tsf call
Date: Wed, 20 Dec 2006 16:04:25 +0800
Message-ID: <1166601865.22609.1.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10469 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964921AbWLTIOu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Dec 2006 03:14:50 -0500
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

get_tsf passes the wrong pointer to driver.


Signed-off-by: Hong Liu <hong.liu@intel.com>

diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 3b55427..e48295e 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -2482,7 +2482,7 @@ #ifdef CONFIG_D80211_IBSS_DEBUG
 		static unsigned long last_tsf_debug = 0;
 		u64 tsf;
 		if (local->ops->get_tsf)
-			tsf = local->ops->get_tsf(local->mdev);
+			tsf = local->ops->get_tsf(local_to_hw(local));
 		else
 			tsf = -1LLU;
 		if (time_after(jiffies, last_tsf_debug + 5 * HZ)) {
