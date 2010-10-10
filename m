From: Andy Walls <awalls@md.metrocast.net>
Subject: [PATCH] IPv4: Remove check for ipv4_is_lbcast() that will always
 return false
Date: Sun, 10 Oct 2010 12:10:21 -0400
Message-ID: <1286727021.2435.17.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from proofpoint-cluster.metrocast.net ([65.175.128.136]:31760 "EHLO
	proofpoint-cluster.metrocast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752455Ab0JJQJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Oct 2010 12:09:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In making an IPv4 routing decision, packets with an all 1's broadcast
destination are accepted as input packets, before being checked for being a
martian.  Remove the martian check for the all 1's broadcast destination
address.  Make the initial check for the all 1's broadcast destination
address easier to read.

Signed-off-by: Andy Walls <awalls@md.metrocast.net>


diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ac6559c..2b8c071 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2124,7 +2124,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32
            ipv4_is_loopback(saddr))
                goto martian_source;
 
-       if (daddr == htonl(0xFFFFFFFF) || (saddr == 0 && daddr == 0))
+       if (ipv4_is_lbcast(daddr) || (saddr == 0 && daddr == 0))
                goto brd_input;
 
        /* Accept zero addresses only to limited broadcast;
@@ -2133,8 +2133,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32
        if (ipv4_is_zeronet(saddr))
                goto martian_source;
 
-       if (ipv4_is_lbcast(daddr) || ipv4_is_zeronet(daddr) ||
-           ipv4_is_loopback(daddr))
+       if (ipv4_is_zeronet(daddr) || ipv4_is_loopback(daddr))
                goto martian_destination;
 
        /*


