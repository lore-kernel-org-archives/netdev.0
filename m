From: Luca Coelho <luca@coelho.fi>
Subject: [PATCH] mac80211: disable CSA client with channel contexts for all drivers
Date: Mon, 18 Aug 2014 11:58:23 +0300
Message-ID: <1408352303-8354-1-git-send-email-luca@coelho.fi>
Cc: johannes@sipsolutions.net, michal.kazior@tieto.com,
	torvalds@linux-foundation.org, emmanuel.grumbach@intel.com,
	linux-wireless@vger.kernel.org, ilw@linux.intel.com,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dedo.coelho.fi ([88.198.205.34]:41529 "EHLO dedo.coelho.fi"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752677AbaHRI6t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Aug 2014 04:58:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luciano Coelho <luciano.coelho@intel.com>

The channel switch announcement code has some serious problems at the
moment.  Disable it for all drivers until it has been tested and
finalized properly.

Signed-off-by: Luciano Coelho <luciano.coelho@intel.com>
---
 net/mac80211/main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index e0ab432..4b8eee8 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -758,6 +758,12 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 	netdev_features_t feature_whitelist;
 	struct cfg80211_chan_def dflt_chandef = {};
 
+	/* The CSA client code is not very stable yet and seems to be
+	 * causing trouble.  Disable it for all drivers until
+	 * everything has been fixed and tested properly.
+	 */
+	hw->flags &= ~IEEE80211_HW_CHANCTX_STA_CSA;
+
 	if (hw->flags & IEEE80211_HW_QUEUE_CONTROL &&
 	    (local->hw.offchannel_tx_hw_queue == IEEE80211_INVAL_HW_QUEUE ||
 	     local->hw.offchannel_tx_hw_queue >= local->hw.queues))
-- 
2.0.1
