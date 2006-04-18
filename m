From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ip_route_input panic fix
Date: Tue, 18 Apr 2006 12:28:48 +1000
Message-ID: <E1FVfxQ-0008Tf-00@gondolin.me.apana.org.au>
References: <20060417171253.4e988afc@localhost.localdomain>
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:26636 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932146AbWDRC27
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 22:28:59 -0400
To: shemminger@osdl.org (Stephen Hemminger)
In-Reply-To: <20060417171253.4e988afc@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen:

Stephen Hemminger <shemminger@osdl.org> wrote:
> This fixes http://bugzilla.kernel.org/show_bug.cgi?id=6388
> The bug is caused by ip_route_input dereferencing skb->nh.protocol of
> the dummy skb passed dow from inet_rtm_getroute (Thanks Thomas for seeing
> it). It only happens if the route requested is for a multicast IP
> address.

Good catch.

> -       skb->mac.raw = skb->data;
> +       skb->mac.raw = skb->nh.raw = skb->data;

This should fix it.

> +       /* Bugfix: need to give ip_route_input enough of an IP header to not gag. */
> +       skb->nh.iph->protocol = IPPROTO_ICMP;

Do we really need this? After all we can get completely bogus values
coming in through the network too.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
