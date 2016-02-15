From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net] pppoe: fix reference counting in PPPoE proxy
Date: Mon, 15 Feb 2016 17:01:10 +0100
Message-ID: <20160215160110.GA1186@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:38909 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240AbcBOQBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 11:01:14 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drop reference on the relay_po socket when __pppoe_xmit() succeeds.
This is already handled correctly in the error path.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
No 'Fixes' tag, since this issue seems to predate git's history.

 drivers/net/ppp/pppoe.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index f3c6302..4ddae81 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -395,6 +395,8 @@ static int pppoe_rcv_core(struct sock *sk, struct sk_buff *skb)
 
 		if (!__pppoe_xmit(sk_pppox(relay_po), skb))
 			goto abort_put;
+
+		sock_put(sk_pppox(relay_po));
 	} else {
 		if (sock_queue_rcv_skb(sk, skb))
 			goto abort_kfree;
-- 
2.7.0
