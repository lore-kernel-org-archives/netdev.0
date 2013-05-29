From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 6/7] sctp: Correct access to skb->{network,transport}_header
Date: Wed, 29 May 2013 14:27:47 +0900
Message-ID: <1369805268-6291-7-git-send-email-horms@verge.net.au>
References: <1369805268-6291-1-git-send-email-horms@verge.net.au>
Cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:46194 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753320Ab3E2F1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 01:27:10 -0400
In-Reply-To: <1369805268-6291-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This corrects an regression introduced by "net: Use 16bits for *_headers
fields of struct skbuff" when NET_SKBUFF_DATA_USES_OFFSET is not set. In
that case sk_buff_data_t will be a pointer, however,
skb->{network,transport}_header is now __u16.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/sctp/input.c |    2 +-
 net/sctp/ipv6.c  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index 4b2c831..e328fe8 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -589,7 +589,7 @@ void sctp_v4_err(struct sk_buff *skb, __u32 info)
 	struct sctp_association *asoc = NULL;
 	struct sctp_transport *transport;
 	struct inet_sock *inet;
-	sk_buff_data_t saveip, savesctp;
+	__be16 saveip, savesctp;
 	int err;
 	struct net *net = dev_net(skb->dev);
 
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 391a245..8ee553b 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -153,7 +153,7 @@ SCTP_STATIC void sctp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	struct sctp_association *asoc;
 	struct sctp_transport *transport;
 	struct ipv6_pinfo *np;
-	sk_buff_data_t saveip, savesctp;
+	__be16 saveip, savesctp;
 	int err;
 	struct net *net = dev_net(skb->dev);
 
-- 
1.7.10.4
