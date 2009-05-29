From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/10]: aoe: Remove superfluous clearing of skb fields in
 new_skb().
Date: Fri, 29 May 2009 01:40:00 -0700 (PDT)
Message-ID: <20090529.014000.143389316.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56914
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755019AbZE2IkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 04:40:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This code uses alloc_skb() which clears them out for us.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/block/aoe/aoecmd.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/block/aoe/aoecmd.c b/drivers/block/aoe/aoecmd.c
index 31693bc..965ece2 100644
--- a/drivers/block/aoe/aoecmd.c
+++ b/drivers/block/aoe/aoecmd.c
@@ -34,13 +34,6 @@ new_skb(ulong len)
 		skb_reset_mac_header(skb);
 		skb_reset_network_header(skb);
 		skb->protocol = __constant_htons(ETH_P_AOE);
-		skb->priority = 0;
-		skb->next = skb->prev = NULL;
-
-		/* tell the network layer not to perform IP checksums
-		 * or to get the NIC to do it
-		 */
-		skb->ip_summed = CHECKSUM_NONE;
 	}
 	return skb;
 }
-- 
1.6.3

