From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] ip_route_input panic fix
Date: Mon, 17 Apr 2006 19:49:31 -0700
Message-ID: <20060417194931.032aba02@localhost.localdomain>
References: <20060417171253.4e988afc@localhost.localdomain>
	<E1FVfxQ-0008Tf-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:54442 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751380AbWDRCto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2006 22:49:44 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1FVfxQ-0008Tf-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 18 Apr 2006 12:28:48 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Hi Stephen:
> 
> Stephen Hemminger <shemminger@osdl.org> wrote:
> > This fixes http://bugzilla.kernel.org/show_bug.cgi?id=6388
> > The bug is caused by ip_route_input dereferencing skb->nh.protocol of
> > the dummy skb passed dow from inet_rtm_getroute (Thanks Thomas for seeing
> > it). It only happens if the route requested is for a multicast IP
> > address.
> 
> Good catch.
> 
> > -       skb->mac.raw = skb->data;
> > +       skb->mac.raw = skb->nh.raw = skb->data;
> 
> This should fix it.
> 
> > +       /* Bugfix: need to give ip_route_input enough of an IP header to not gag. */
> > +       skb->nh.iph->protocol = IPPROTO_ICMP;
> 
> Do we really need this? After all we can get completely bogus values
> coming in through the network too.

Not really, just that ip_check_mc looks at the proto for !IGMP. And maybe
some tool like coverity or sparse would be smart enough to look for
uninitialized data usage.
