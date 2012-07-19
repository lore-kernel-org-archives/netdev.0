From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipv4: optimize fib_compute_spec_dst call in ip_options_echo
Date: Thu, 19 Jul 2012 10:34:24 +0300
Message-ID: <1342683264-3523-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:47774 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751014Ab2GSH1f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2012 03:27:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Move fib_compute_spec_dst at the only place where it
is needed.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/ipv4/ip_options.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index a19d647..1dc01f9 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -93,7 +93,6 @@ int ip_options_echo(struct ip_options *dopt, struct sk_buff *skb)
 	unsigned char *sptr, *dptr;
 	int soffset, doffset;
 	int	optlen;
-	__be32	daddr;
 
 	memset(dopt, 0, sizeof(struct ip_options));
 
@@ -105,8 +104,6 @@ int ip_options_echo(struct ip_options *dopt, struct sk_buff *skb)
 	sptr = skb_network_header(skb);
 	dptr = dopt->__data;
 
-	daddr = fib_compute_spec_dst(skb);
-
 	if (sopt->rr) {
 		optlen  = sptr[sopt->rr+1];
 		soffset = sptr[sopt->rr+2];
@@ -180,6 +177,8 @@ int ip_options_echo(struct ip_options *dopt, struct sk_buff *skb)
 				doffset -= 4;
 		}
 		if (doffset > 3) {
+			__be32 daddr = fib_compute_spec_dst(skb);
+
 			memcpy(&start[doffset-1], &daddr, 4);
 			dopt->faddr = faddr;
 			dptr[0] = start[0];
-- 
1.7.3.4
