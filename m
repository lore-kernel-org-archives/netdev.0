From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipv4: fix address selection in fib_compute_spec_dst
Date: Thu, 19 Jul 2012 10:35:03 +0300
Message-ID: <1342683303-3557-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:47777 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751946Ab2GSH2A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2012 03:28:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	ip_options_compile can be called for forwarded packets,
make sure the specific-destionation address is a local one as
specified in RFC 1812, 4.2.2.2 Addresses in Options

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/ipv4/fib_frontend.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 7a31194..b832036 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -206,7 +206,8 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb)
 	int scope;
 
 	rt = skb_rtable(skb);
-	if (!(rt->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST)))
+	if ((rt->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST | RTCF_LOCAL)) ==
+	    RTCF_LOCAL)
 		return ip_hdr(skb)->daddr;
 
 	in_dev = __in_dev_get_rcu(dev);
-- 
1.7.3.4
