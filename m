From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/42] pktgen: Fix set-but-unused variable.
Date: Sun, 17 Apr 2011 17:32:47 -0700 (PDT)
Message-ID: <20110417.173247.112597531.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40536
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752549Ab1DRAdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:33:21 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 3BCD524C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:32:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


"iph" in pktgen_output_ipsec() is set but never actually
used.  Kill it off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/pktgen.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index aeeece7..2fa6fee 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2514,7 +2514,6 @@ static int pktgen_output_ipsec(struct sk_buff *skb, struct pktgen_dev *pkt_dev)
 {
 	struct xfrm_state *x = pkt_dev->flows[pkt_dev->curfl].x;
 	int err = 0;
-	struct iphdr *iph;
 
 	if (!x)
 		return 0;
@@ -2524,7 +2523,6 @@ static int pktgen_output_ipsec(struct sk_buff *skb, struct pktgen_dev *pkt_dev)
 		return 0;
 
 	spin_lock(&x->lock);
-	iph = ip_hdr(skb);
 
 	err = x->outer_mode->output(x, skb);
 	if (err)
-- 
1.7.4.3

