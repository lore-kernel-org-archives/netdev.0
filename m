From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [RFC] [PATCH] ip: skip IP checksum for skbs with CHECKSUM_UNNECESSARY set
Date: Fri, 22 Aug 2008 22:24:31 +0300
Message-ID: <200808222224.32311.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:8810 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752149AbYHVT1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 15:27:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We are working on a completely in hardware LRO implementation and this patch 
would simplify the hardware implementation. Is this acceptable?

--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -415,7 +415,8 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 
        iph = ip_hdr(skb);
 
-       if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
+       if (!skb_csum_unnecessary(skb) &&
+           unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
                goto inhdr_error;
 
        len = ntohs(iph->tot_len);

