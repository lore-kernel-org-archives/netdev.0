From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH 4/4] mac80211: avoid null ptr deref in ieee80211_ibss_add_sta
Date: Wed, 30 May 2007 14:30:33 -0400
Message-ID: <20070530183033.GG3610@tuxdriver.com>
References: <20070530182538.GB3610@tuxdriver.com> <20070530182807.GD3610@tuxdriver.com> <20070530182858.GE3610@tuxdriver.com> <20070530182946.GF3610@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3780 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755164AbXE3TBU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 15:01:20 -0400
Content-Disposition: inline
In-Reply-To: <20070530182946.GF3610@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John W. Linville <linville@tuxdriver.com>

avoid sdata null pointer dereference in ieee80211_ibss_add_sta.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 net/mac80211/ieee80211_sta.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index dbac858..9f30ae4 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -2997,7 +2997,7 @@ struct sta_info * ieee80211_ibss_add_sta(struct net_device *dev,
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct sta_info *sta;
-	struct ieee80211_sub_if_data *sdata = NULL;
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
 	/* TODO: Could consider removing the least recently used entry and
 	 * allow new one to be added. */
-- 
1.5.0.6

-- 
John W. Linville
linville@tuxdriver.com
