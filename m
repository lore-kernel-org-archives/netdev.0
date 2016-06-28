From: Yaniv Machani <yanivma@ti.com>
Subject: [PATCH] mac80211: rx: frames received out of order
Date: Tue, 28 Jun 2016 14:15:03 +0300
Message-ID: <20160628111510.8857-1-yanivma@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Meirav Kama <meiravk@ti.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>
To: <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:33457 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751673AbcF1LQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 07:16:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Meirav Kama <meiravk@ti.com>

MP received data frames from another MP. Frames are forwarded
from Rx to Tx to be transmitted to a third MP.
Upon cloning the skb, the tx_info was zeroed, and the
hw_queue wasn't set correctly, causing frames to be
inserted to queue 0 (VOICE). If re-queue occurred for some
reason, frame will be inserted to correct queue 2 (BE).
In this case frames are now dequeued from 2 different queues and
sent out of order.

Signed-off-by: Meirav Kama <meiravk@ti.com>
Acked-by: Yaniv Machani <yanivma@ti.com>
---
 net/mac80211/rx.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 9a1eb70..88dc744 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -2392,6 +2392,7 @@ ieee80211_rx_h_mesh_fwding(struct ieee80211_rx_data *rx)
 	info->flags |= IEEE80211_TX_INTFL_NEED_TXPROCESSING;
 	info->control.vif = &rx->sdata->vif;
 	info->control.jiffies = jiffies;
+	info->hw_queue = q;
 	if (is_multicast_ether_addr(fwd_hdr->addr1)) {
 		IEEE80211_IFSTA_MESH_CTR_INC(ifmsh, fwded_mcast);
 		memcpy(fwd_hdr->addr2, sdata->vif.addr, ETH_ALEN);
-- 
2.9.0
