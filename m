From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 1/2] ipv4: add forwarding_uses_pmtu knob to protect forward path to use pmtu info
Date: Tue, 31 Dec 2013 04:52:47 +0100
Message-ID: <20131231035247.GA27636@order.stressinduktion.org>
References: <20131220130822.GD32129@order.stressinduktion.org> <20131230.222044.884570280065942449.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:59832 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331Ab3LaDwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 22:52:49 -0500
Content-Disposition: inline
In-Reply-To: <20131230.222044.884570280065942449.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 30, 2013 at 10:20:44PM -0500, David Miller wrote:
> Sorry Hannes, I'm still not happy with this change at all.
> 
> First of all, you misunderstood what I said last time around.
> I basically was trying to say that if you make this facility
> available at all, distributions are going to turn it on by
> default even if you make the kernel default to off.

Yes, I am sorry for that.

> That drives me nuts, and I don't want to give people this
> opportunity to screw things up again just like they did
> for rp_filter, which also defaults to off.
> 
> Secondly, I don't see how this is as big of an issue as you
> present it to be.  At best, the language is way too strong.
> 
> How can PMTU information be injected into the kernel?

I used icmp_err handler with type == ICMP_ECHOREPLY. It is pretty open
as it does not validate (and cannot) validate local socket state.

This also applies to ipv6 and raw handler could also be a problem.

> Local connections, well we want that and it's good.  And for TCP you
> have to be able to inject a valid TCP packet that can be validated by
> the stack for the PMTU information to stick.
> 
> Tunnels, well you said that tunnels don't apply to this change.
> 
> The only thing left are things like AH and ESP, which also perform
> some level of validation making sure that some state exists.  And
> frankly for non-tunneled IPSEC this PMTU information is absolutely
> essential.
>
> I really don't want to apply these changes, sorry.

I can understand.

I'll do more research on this and try to present more convincing reasons
why this could be a problem and explain and check more carefully how
this interacts with the xfrm subsystem. I am still convinced we should
suppress path mtu information in forwarding path.

I'll review the language of this change, too. ;)

Thank you for the review and a happy new year!
