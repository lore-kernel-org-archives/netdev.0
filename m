From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] sctp: Correct byte order of access to skb->{network, transport}_header
Date: Thu, 13 Jun 2013 16:04:33 +0900
Message-ID: <1371107073-26440-1-git-send-email-horms@verge.net.au>
Cc: Simon Horman <horms@verge.net.au>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:54635 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762Ab3FMHEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 03:04:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corrects an byte order conflict introduced by
158874cac61245b84e939c92c53db7000122b7b0
("sctp: Correct access to skb->{network, transport}_header").
The values in question are host byte order.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/sctp/ipv6.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 8ee553b..fffc7b6 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -153,7 +153,7 @@ SCTP_STATIC void sctp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	struct sctp_association *asoc;
 	struct sctp_transport *transport;
 	struct ipv6_pinfo *np;
-	__be16 saveip, savesctp;
+	__u16 saveip, savesctp;
 	int err;
 	struct net *net = dev_net(skb->dev);
 
-- 
1.8.2.1
