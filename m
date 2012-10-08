From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net v2 2/6] ipv4: fix forwarding for strict source routes
Date: Tue,  9 Oct 2012 00:41:16 +0300
Message-ID: <1349732480-19978-3-git-send-email-ja@ssi.bg>
References: <1349732480-19978-1-git-send-email-ja@ssi.bg>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:44333 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751612Ab2JHVgC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2012 17:36:02 -0400
Received: from ja.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.14.4/8.14.4) with ESMTP id q98LfY8M020018
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2012 00:41:34 +0300
Received: (from root@localhost)
	by ja.ssi.bg (8.14.4/8.14.4/Submit) id q98LfYPV020017
	for netdev@vger.kernel.org; Tue, 9 Oct 2012 00:41:34 +0300
In-Reply-To: <1349732480-19978-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	After the change "Adjust semantics of rt->rt_gateway"
(commit f8126f1d51) rt_gateway can be 0 but ip_forward() compares
it directly with nexthop. What we want here is to check if traffic
is to directly connected nexthop and to fail if using gateway.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/ipv4/ip_forward.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index ab09b12..7f35ac2 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -85,7 +85,7 @@ int ip_forward(struct sk_buff *skb)
 
 	rt = skb_rtable(skb);
 
-	if (opt->is_strictroute && opt->nexthop != rt->rt_gateway)
+	if (opt->is_strictroute && rt->rt_gateway)
 		goto sr_failed;
 
 	if (unlikely(skb->len > dst_mtu(&rt->dst) && !skb_is_gso(skb) &&
-- 
1.7.3.4
