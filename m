From: Robert Olsson <robert@robur.slu.se>
Subject: [PATCH] pktgen random flow
Date: Tue, 5 Aug 2008 13:20:07 +0200
Message-ID: <18584.14183.573224.16934@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, robert@robur.slu.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:42163 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756267AbYHELa4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2008 07:30:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Hello, 

Random flow generation has not worked. This fixes it.

Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

Cheers.
				--ro


diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 3284605..755d08f 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2085,15 +2085,19 @@ static inline int f_pick(struct pktgen_dev *pkt_dev)
 		if (pkt_dev->flows[flow].count >= pkt_dev->lflow) {
 			/* reset time */
 			pkt_dev->flows[flow].count = 0;
+			pkt_dev->flows[flow].flags = 0;
 			pkt_dev->curfl += 1;
 			if (pkt_dev->curfl >= pkt_dev->cflows)
 				pkt_dev->curfl = 0; /*reset */
 		}
 	} else {
 		flow = random32() % pkt_dev->cflows;
+		pkt_dev->curfl = flow;
 
-		if (pkt_dev->flows[flow].count > pkt_dev->lflow)
-			pkt_dev->flows[flow].count = 0;
+		if (pkt_dev->flows[flow].count > pkt_dev->lflow) {
+			pkt_dev->flows[flow].count = 0; 
+			pkt_dev->flows[flow].flags = 0;
+		} 
 	}
 
 	return pkt_dev->curfl;
