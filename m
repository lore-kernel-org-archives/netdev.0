From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH 2/4] mac80211: fix memory leak when defrag fragments
Date: Wed, 30 May 2007 14:28:58 -0400
Message-ID: <20070530182858.GE3610@tuxdriver.com>
References: <20070530182538.GB3610@tuxdriver.com> <20070530182807.GD3610@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3777 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755091AbXE3TBP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 15:01:15 -0400
Content-Disposition: inline
In-Reply-To: <20070530182807.GD3610@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hong Liu <hong.liu@intel.com>

We forget to free all the fragments when defraging them into one packet.

Signed-off-by: Hong Liu <hong.liu@intel.com>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 net/mac80211/ieee80211.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/mac80211/ieee80211.c b/net/mac80211/ieee80211.c
index 6e36df6..145604a 100644
--- a/net/mac80211/ieee80211.c
+++ b/net/mac80211/ieee80211.c
@@ -3278,8 +3278,10 @@ ieee80211_rx_h_defragment(struct ieee80211_txrx_data *rx)
 			return TXRX_DROP;
 		}
 	}
-	while ((skb = __skb_dequeue(&entry->skb_list)))
+	while ((skb = __skb_dequeue(&entry->skb_list))) {
 		memcpy(skb_put(rx->skb, skb->len), skb->data, skb->len);
+		dev_kfree_skb(skb);
+	}
 
 	/* Complete frame has been reassembled - process it now */
 	rx->fragmented = 1;
-- 
1.5.0.6

-- 
John W. Linville
linville@tuxdriver.com
