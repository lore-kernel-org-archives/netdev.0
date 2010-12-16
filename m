From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ifb: fix a lockdep splat
Date: Thu, 16 Dec 2010 10:52:55 +0100
Message-ID: <1292493175.2883.56.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: changli Gao <xiaosuo@gmail.com>, netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60275 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122Ab0LPJxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 04:53:00 -0500
Received: by wwa36 with SMTP id 36so2229923wwa.1
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 01:52:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After recent ifb changes, we must use lockless __skb_dequeue() since
lock is not anymore initialized.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jamal Hadi Salim <hadi@cyberus.ca>
Cc: Changli Gao <xiaosuo@gmail.com>
---
 drivers/net/ifb.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index bfa03db..8bcacd7 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -71,7 +71,7 @@ static void ri_tasklet(unsigned long dev)
 		}
 	}
 
-	while ((skb = skb_dequeue(&dp->tq)) != NULL) {
+	while ((skb = __skb_dequeue(&dp->tq)) != NULL) {
 		u32 from = G_TC_FROM(skb->tc_verd);
 
 		skb->tc_verd = 0;


