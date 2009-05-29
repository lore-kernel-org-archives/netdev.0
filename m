From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/10]: rtl8187: Remove pointless check in rtl8187_rx_cb().
Date: Fri, 29 May 2009 01:40:11 -0700 (PDT)
Message-ID: <20090529.014011.244789664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56920
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756788AbZE2IkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 04:40:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


First of all, it exposes the SKB list implementation.

Second of all it's not needed.  If we get called here, we
successfully enqueued the URB with the linked SKB and
such a completion only gets called one time on such an
SKB.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/wireless/rtl818x/rtl8187_dev.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/rtl818x/rtl8187_dev.c b/drivers/net/wireless/rtl818x/rtl8187_dev.c
index 6499ccc..3f22cc0 100644
--- a/drivers/net/wireless/rtl818x/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8187_dev.c
@@ -321,12 +321,7 @@ static void rtl8187_rx_cb(struct urb *urb)
 	unsigned long f;
 
 	spin_lock_irqsave(&priv->rx_queue.lock, f);
-	if (skb->next)
-		__skb_unlink(skb, &priv->rx_queue);
-	else {
-		spin_unlock_irqrestore(&priv->rx_queue.lock, f);
-		return;
-	}
+	__skb_unlink(skb, &priv->rx_queue);
 	spin_unlock_irqrestore(&priv->rx_queue.lock, f);
 	skb_put(skb, urb->actual_length);
 
-- 
1.6.3

