From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Use skb_queue_walk() in zd1211 driver.
Date: Tue, 23 Sep 2008 00:24:10 -0700 (PDT)
Message-ID: <20080923.002410.260333553.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60599
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753223AbYIWHYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 03:24:22 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 92949C8C181
	for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 00:24:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


zd1211: Use skb_queue_walk() instead of by-hand implementation.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/wireless/zd1211rw/zd_mac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index a3da014..fe1867b 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -611,7 +611,7 @@ static int filter_ack(struct ieee80211_hw *hw, struct ieee80211_hdr *rx_hdr,
 
 	q = &zd_hw_mac(hw)->ack_wait_queue;
 	spin_lock_irqsave(&q->lock, flags);
-	for (skb = q->next; skb != (struct sk_buff *)q; skb = skb->next) {
+	skb_queue_walk(q, skb) {
 		struct ieee80211_hdr *tx_hdr;
 
 		tx_hdr = (struct ieee80211_hdr *)skb->data;
-- 
1.5.6.5

