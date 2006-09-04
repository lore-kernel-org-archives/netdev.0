From: gerrit@erg.abdn.ac.uk
Subject: [PATCH 2.6.17] net/ipv6/udp.c: Enforce mandatory checksums as per RFC 2460
Date: Mon, 4 Sep 2006 16:49:01 +0100
Message-ID: <200609041649.01763@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:17091 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S964880AbWIDPtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 11:49:16 -0400
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[UDPv6]: Enforce mandatory checksums as per RFC 2460

The current behaviour of computing outgoing checksums is not
compliant with RFC 2460, as per section 8.1:

 "Unlike IPv4, when UDP packets are originated by an IPv6 node,
  the UDP checksum is not optional.  That is, whenever
  originating a UDP packet, an IPv6 node must compute a UDP
  checksum over the packet and the pseudo-header, [...]"

This modification hence enforces to ignore sk_no_check on UDPv6.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
--

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 8d3432a..5122c4d 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -567,11 +567,6 @@ static int udp_v6_push_pending_frames(st
        uh->len = htons(up->len);
        uh->check = 0;

-       if (sk->sk_no_check == UDP_CSUM_NOXMIT) {
-               skb->ip_summed = CHECKSUM_NONE;
-               goto send;
-       }
-
        if (skb_queue_len(&sk->sk_write_queue) == 1) {
                skb->csum = csum_partial((char *)uh,
                                sizeof(struct udphdr), skb->csum);
