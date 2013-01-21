From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 03/19] ndisc: Use skb_linearize() instead of pskb_may_pull(skb,
 skb->len).
Date: Tue, 22 Jan 2013 01:48:03 +0900
Message-ID: <50FD7143.3090001@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:50336 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752397Ab3AUQsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 11:48:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suggested by Eric Dumazet <edumazet@google.com>.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 82ccf0a..539b2ec 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1509,7 +1509,7 @@ int ndisc_rcv(struct sk_buff *skb)
 {
 	struct nd_msg *msg;
 
-	if (!pskb_may_pull(skb, skb->len))
+	if (skb_linearize(skb))
 		return 0;
 
 	msg = (struct nd_msg *)skb_transport_header(skb);
-- 
1.7.9.5
