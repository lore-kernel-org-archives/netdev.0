From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCH net] sunvnet: set queue mapping when doing packet copies
Date: Thu, 29 Jan 2015 11:46:30 -0500
Message-ID: <54CA63E6.3020603@oracle.com>
References: <54C90AED.7040404@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:37992 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842AbbA2Qqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 11:46:34 -0500
In-Reply-To: <54C90AED.7040404@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[resending this since it never appeared on netdev yesterday]

This patch fixes a bug where vnet_skb_shape() didn't set the already-selected
 queue mapping when a packet copy was required. This results in using the
 wrong queue index for stops/starts, hung tx queues and watchdog timeouts
 under heavy load.

Signed-off-by: David L Stevens <david.stevens@oracle.com>
Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 2b719cc..2b10b85 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -1123,6 +1123,7 @@ static inline struct sk_buff *vnet_skb_shape(struct sk_buff *skb, int ncookies)
 			skb_shinfo(nskb)->gso_size = skb_shinfo(skb)->gso_size;
 			skb_shinfo(nskb)->gso_type = skb_shinfo(skb)->gso_type;
 		}
+		nskb->queue_mapping = skb->queue_mapping;
 		dev_kfree_skb(skb);
 		skb = nskb;
 	}
