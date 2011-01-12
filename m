From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: [PATCH] inet6: prevent network storms caused by linux IPv6 routers
Date: Wed, 12 Jan 2011 21:34:08 +0300
Message-ID: <20110112183408.GA8417@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:50636 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753748Ab1ALTOA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jan 2011 14:14:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linux IPv6 forwards unicast packets, which are link layer multicasts...
The hole was present since day one. I was 100% this check is there, but it is not.

The problem shows itself, f.e. when Microsoft Network Load Balancer runs on a network.
This software resolves IPv6 unicast addresses to multicast MAC addresses.

Signed-off-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
---
 net/ipv6/ip6_output.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 94b5bf1..5f8d242 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -401,6 +401,9 @@ int ip6_forward(struct sk_buff *skb)
 		goto drop;
 	}
 
+	if (skb->pkt_type != PACKET_HOST)
+		goto drop;
+
 	skb_forward_csum(skb);
 
 	/*
-- 
1.7.2.3

