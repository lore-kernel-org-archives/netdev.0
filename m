From: Jean-Philippe Andriot <jean-philippe.andriot@6WIND.com>
Subject: [PATCH] [XFRM/IPV6] fix next header offset in decode_session
Date: Tue, 7 Nov 2006 10:30:02 +0100
Message-ID: <20061107093002.GA6576@palpatine.dev.6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:51723 "EHLO
	proxy.6wind.com") by vger.kernel.org with ESMTP id S1753912AbWKGJaE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Nov 2006 04:30:04 -0500
Received: from palpatine.dev.6wind.com (unknown [10.16.0.38])
	by proxy.6wind.com (Postfix) with ESMTP id 30966525F84
	for <netdev@vger.kernel.org>; Tue,  7 Nov 2006 10:30:03 +0100 (CET)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The way to get the next protocol number of an IPv6 tunnel changes
after introducing IP6CB, but I think we should go back to the
previous version here.
In our case I think there was a confusion between the pointer
on the first byte of the next header and the value of the next
header field.

Signed-off-by: Andriot Jean-Philippe <jean-philippe.andriot@6wind.com>

--- xfrm6_policy.c.org  2006-11-07 09:45:47.000000000 +0100
+++ xfrm6_policy.c      2006-11-07 09:46:19.000000000 +0100
@@ -255,7 +255,7 @@ _decode_session6(struct sk_buff *skb, st
        u16 offset = skb->h.raw - skb->nh.raw;
        struct ipv6hdr *hdr = skb->nh.ipv6h;
        struct ipv6_opt_hdr *exthdr;
-       u8 nexthdr = skb->nh.raw[IP6CB(skb)->nhoff];
+       u8 nexthdr = skb->nh.ipv6h->nexthdr;
 
        memset(fl, 0, sizeof(struct flowi));
        ipv6_addr_copy(&fl->fl6_dst, &hdr->daddr);

