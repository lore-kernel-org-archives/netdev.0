From: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>
Subject: [PATCH] net: pktgen: Remove unused 'allocated_skbs' field
Date: Wed, 29 Jul 2015 12:47:16 +0300
Message-ID: <1438163236-12593-1-git-send-email-bogdan.hamciuc@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0141.outbound.protection.outlook.com ([157.56.110.141]:45637
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751985AbbG2LUI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2015 07:20:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Field pktgen_dev.allocated_skbs had been written to, but never read
from. The number of allocated skbs can be deduced anyway, from the total
number of sent packets and the 'clone_skb' param.

Signed-off-by: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>
---
 net/core/pktgen.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 5961da6..0e0fb30 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -273,7 +273,6 @@ struct pktgen_dev {
 
 	/* runtime counters relating to clone_skb */
 
-	__u64 allocated_skbs;
 	__u32 clone_count;
 	int last_ok;		/* Was last skb sent?
 				 * Or a failed transmit of some sort?
@@ -3398,7 +3397,6 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 			return;
 		}
 		pkt_dev->last_pkt_size = pkt_dev->skb->len;
-		pkt_dev->allocated_skbs++;
 		pkt_dev->clone_count = 0;	/* reset counter */
 	}
 
-- 
1.8.3.1
