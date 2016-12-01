From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v3] ipv6 addrconf: Implemented enhanced DAD
 (RFC7527)
Date: Thu, 1 Dec 2016 23:28:24 +0100
Message-ID: <1764849a-e853-21f8-a6e5-f2280b3b8a88@stressinduktion.org>
References: <1480549159-8142-1-git-send-email-nordmark@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Bob Gilligan <gilligan@arista.com>
To: Erik Nordmark <nordmark@arista.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:52123 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752152AbcLAW20 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 17:28:26 -0500
In-Reply-To: <1480549159-8142-1-git-send-email-nordmark@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01.12.2016 00:39, Erik Nordmark wrote:
> Implemented RFC7527 Enhanced DAD.
> IPv6 duplicate address detection can fail if there is some temporary
> loopback of Ethernet frames. RFC7527 solves this by including a random
> nonce in the NS messages used for DAD, and if an NS is received with the
> same nonce it is assumed to be a looped back DAD probe and is ignored.
> RFC7527 is enabled by default. Can be disabled by setting both of
> conf/{all,interface}/enhanced_dad to zero.
> 
> Signed-off-by: Erik Nordmark <nordmark@arista.com>
> Signed-off-by: Bob Gilligan <gilligan@arista.com>
> ---

Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks!
> @@ -794,6 +808,17 @@ static void ndisc_recv_ns(struct sk_buff *skb)
>  have_ifp:
>  		if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
>  			if (dad) {
> +				if (nonce != 0 && ifp->dad_nonce == nonce) {
> +					u8 *np = (u8 *)&nonce;
> +					/* Matching nonce if looped back */
> +					ND_PRINTK(2, notice,
> +						  "%s: IPv6 DAD loopback for address %pI6c nonce %02x:%02x:%02x:%02x:%02x:%02x ignored\n",
> +						  ifp->idev->dev->name,
> +						  &ifp->addr,
> +						  np[0], np[1], np[2], np[3],
> +						  np[4], np[5]);
> +					goto out;
> +				}
>  				/*
>  				 * We are colliding with another node
>  				 * who is doing DAD
> 

I think it could be a "%pM" because it looks like a MAC address, but
better leave it like that. :)

Bye,
Hannes
