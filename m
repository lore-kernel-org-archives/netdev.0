From: David Miller <davem@davemloft.net>
Subject: [PATCH net-next-2.6] chelsio: Fix build warning.
Date: Tue, 13 Apr 2010 03:08:43 -0700 (PDT)
Message-ID: <20100413.030843.144389683.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51967
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751946Ab0DMKIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 06:08:39 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 0D49F24C08F
	for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 03:08:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


GCC warns that:

drivers/net/chelsio/sge.c:463:11: warning: operation on 's->port' may be undefined

Better to eliminate the side effects in the calculation and
express what was intended here.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/chelsio/sge.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index 475304f..a8ffc1e 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -460,7 +460,7 @@ static struct sk_buff *sched_skb(struct sge *sge, struct sk_buff *skb,
 
 again:
 	for (i = 0; i < MAX_NPORTS; i++) {
-		s->port = ++s->port & (MAX_NPORTS - 1);
+		s->port = (s->port + 1) & (MAX_NPORTS - 1);
 		skbq = &s->p[s->port].skbq;
 
 		skb = skb_peek(skbq);
-- 
1.7.0.4

