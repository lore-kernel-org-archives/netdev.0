From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] mac80211: cleanup kmalloc/memset -> kcalloc
Date: Thu, 15 Jan 2009 17:41:16 +0800
Message-ID: <496F04BC.3030703@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64382 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752537AbZAOJk4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 04:40:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Transform calls kmalloc/memset to a single kcalloc.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/mac80211/ht.c               |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/mac80211/ht.c b/net/mac80211/ht.c
index 5f510a1..743d530 100644
--- a/net/mac80211/ht.c
+++ b/net/mac80211/ht.c
@@ -949,7 +949,7 @@ void ieee80211_process_addba_request(struct ieee80211_local *local,
 
 	/* prepare reordering buffer */
 	tid_agg_rx->reorder_buf =
-		kmalloc(buf_size * sizeof(struct sk_buff *), GFP_ATOMIC);
+		kcalloc(buf_size, sizeof(struct sk_buff *), GFP_ATOMIC);
 	if (!tid_agg_rx->reorder_buf) {
 #ifdef CONFIG_MAC80211_HT_DEBUG
 		if (net_ratelimit())
@@ -959,8 +959,6 @@ void ieee80211_process_addba_request(struct ieee80211_local *local,
 		kfree(sta->ampdu_mlme.tid_rx[tid]);
 		goto end;
 	}
-	memset(tid_agg_rx->reorder_buf, 0,
-		buf_size * sizeof(struct sk_buff *));
 
 	if (local->ops->ampdu_action)
 		ret = local->ops->ampdu_action(hw, IEEE80211_AMPDU_RX_START,
-- 
1.6.0.3



