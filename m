From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v4] tcp: harmonize tcp_vx_rcv header length assumptions
Date: Wed, 13 Jan 2010 17:03:10 -0800
Message-ID: <1263430990.1966.12.camel@Joe-Laptop.home>
References: <4B49D001.4000302@gmail.com> <4B4DA4F4.6060007@gmail.com>
	 <20100113115617.GA24818@basil.fritz.box> <4B4DE887.6030602@gmail.com>
	 <20100113155323.GB24818@basil.fritz.box> <4B4E23E0.4000007@gmail.com>
	 <4B4E378A.7040506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: William Allen Simpson <william.allen.simpson@gmail.com>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1148 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754825Ab0ANBDM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jan 2010 20:03:12 -0500
In-Reply-To: <4B4E378A.7040506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-01-13 at 16:13 -0500, William Allen Simpson wrote:
> I did today's tests on tcp_ipv4, but part of this harmonization is to
> make v4 and v6 match up better.  As I was examining line by line, one of
> the things that leaps out is that ipv4 has nf_reset(skb):
> 
> tcp_ipv4:
> 	if (!xfrm4_policy_check(sk, XFRM_POLICY_IN, skb))
> 		goto discard_and_relse;
> 	nf_reset(skb);
> 
> 	if (sk_filter(sk, skb))
> 		goto discard_and_relse;
> 
> tcp_ipv6:
> 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
> 		goto discard_and_relse;
> 
> 	if (sk_filter(sk, skb))
> 		goto discard_and_relse;
> 
> Does anybody know why?  Should ipv6 have it?  Or at least a comment
> explaining the reasoning for the omission?

You should ask the person that put the line in, but
it might be because no IPv6 NAT support exists.

$ git blame -L 1658,1658 net/ipv4/tcp_ipv4.c
b59c2701 (Patrick McHardy 2006-01-06 23:06:10 -0800 1658)       nf_reset(skb);

And

$ git log -p -1 b59c2701
commit b59c270104f03960069596722fea70340579244d
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Jan 6 23:06:10 2006 -0800

    [NETFILTER]: Keep conntrack reference until IPsec policy checks are done
    
    Keep the conntrack reference until policy checks have been performed for
    IPsec NAT support. The reference needs to be dropped before a packet is
    queued to avoid having the conntrack module unloadable.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>
    Signed-off-by: David S. Miller <davem@davemloft.net>





