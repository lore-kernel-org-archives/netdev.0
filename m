From: Andrew Morton <akpm@linux-foundation.org>
Subject: net-2.6.25 splat
Date: Wed, 12 Dec 2007 16:21:40 -0800
Message-ID: <20071212162140.6b81328d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Ilpo =?ISO-8859-1?Q?J=E4rvine?= =?ISO-8859-1?Q?n?=
	<ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55570 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752159AbXLMAVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 19:21:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Pulled the tree a couple of hours ago.  The machine was running the full
-mm lineup, had been compiling kernels for an hour or so then oopsed in
icmpv6_rcv+0x5b/0x832.

I have a partial photo of the scrolled-off backtrace but the camera cable
is at home.

I don't know why it was doing ipv6 things at all.  Maybe there's ip6 stuff
running around google's corp network, dunno.

gdb says:

(gdb) l *0x17387
0x17387 is in icmpv6_rcv (net/ipv6/icmp.c:649).
644             struct in6_addr *saddr, *daddr;
645             struct ipv6hdr *orig_hdr;
646             struct icmp6hdr *hdr;
647             int type;
648     
649             if (xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb) &&
650                 skb->sp->xvec[skb->sp->len - 1]->props.flags & XFRM_STATE_ICMP) {
651                     int nh;
652     
653                     if (!pskb_may_pull(skb, sizeof(*hdr) + sizeof(*orig_hdr)))


I'll set the display to 80x50 and retry..	
