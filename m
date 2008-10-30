From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pppoe: Add missing sock_put() in pppoe_rcv()
Date: Thu, 30 Oct 2008 08:57:25 +0000
Message-ID: <20081030085725.GA15289@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:17828 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753070AbYJ3I5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 04:57:33 -0400
Received: by ey-out-2122.google.com with SMTP id 6so168396eyi.37
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 01:57:31 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pppoe: Add missing sock_put() in pppoe_rcv()

Add missing sock_put() in pppoe_rcv() (introduced by
commit 392fdb0e35055b96faa9c1cd6ab537805337cdce).

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
[needed for stables 2.6.26 and later]

 drivers/net/pppoe.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index fc6f4b8..c074276 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -403,8 +403,10 @@ static int pppoe_rcv(struct sk_buff *skb,
 	if (!po)
 		goto drop;
 
-	if (pskb_trim_rcsum(skb, len))
+	if (pskb_trim_rcsum(skb, len)) {
+		sock_put(sk_pppox(po));
 		goto drop;
+	}
 
 	return sk_receive_skb(sk_pppox(po), skb, 0);
 
