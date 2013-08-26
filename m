From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Problematic commits in the ipsec tree
Date: Mon, 26 Aug 2013 11:41:45 +0200
Message-ID: <20130826094145.GK26773@secunet.com>
References: <20130822104724.GD26773@secunet.com>
 <20130822135342.GC30722@order.stressinduktion.org>
 <20130823085807.GH26773@secunet.com>
 <20130823110323.GB808@order.stressinduktion.org>
 <20130823113435.GC808@order.stressinduktion.org>
 <20130823124911.GD808@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48929 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751996Ab3HZJls (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Aug 2013 05:41:48 -0400
Content-Disposition: inline
In-Reply-To: <20130823124911.GD808@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 23, 2013 at 02:49:11PM +0200, Hannes Frederic Sowa wrote:
> 
> This could be the replacement for patch 1/2 to reassemble old behaviour
> without touching ip6_skb_dst_mtu if the socket type is not an IPv6 one.
> 
> I would still like to look if we could correctly handle *_PMTUDISC_PROBE one
> day and fallback to dst_mtu(dst->path) if possible. So I don't know if
> removing xfrm_skb_dst_mtu is good style and would just make churn in the git
> history. What do you think?

Currently I think we can call dst_mtu() unconditionally from
__xfrm6_output(), then we would not need xfrm_skb_dst_mtu().
But this needs further investigation, IPsec pmtu discovery
was frequently broken in the past and I don't want to break
it again.

> 
> [PATCH ipsec 1/2] xfrm: revert ipv4 mtu determination to dst_mtu
> 
> In commit 0ea9d5e3e0e03a63b11392f5613378977dae7eca ("xfrm: introduce
> helper for safe determination of mtu") I switched the determination of
> ipv4 mtus from dst_mtu to ip_skb_dst_mtu. This was an error because in
> case of IP_PMTUDISC_PROBE we fall back to the interface mtu, which is
> never correct for ipv4 ipsec.
> 
> This patch partly reverts 0ea9d5e3e0e03a63b11392f5613378977dae7eca
> ("xfrm: introduce helper for safe determination of mtu").
> 

I think with this and you other patch, we get the all the
interfamily tunnel problems fixed for now. Everything else
should be done in ipsec-next.

Please resend the whole patchset, so we can get it fixed soon.

Tanks a lot!
