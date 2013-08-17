From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH ipsec 2/3] ipv6: xfrm: dereference inner ipv6 header if encapsulated
Date: Sat, 17 Aug 2013 21:53:00 +0200
Message-ID: <20130817195300.GB7371@order.stressinduktion.org>
References: <20130817175130.GA7039@order.stressinduktion.org> <1376766234.21329.11.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:58076 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754368Ab3HQTxC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 15:53:02 -0400
Content-Disposition: inline
In-Reply-To: <1376766234.21329.11.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 17, 2013 at 12:03:54PM -0700, Eric Dumazet wrote:
> On Sat, 2013-08-17 at 19:51 +0200, Hannes Frederic Sowa wrote:
> > In xfrm6_local_error use inner_header if the packet was encapsulated.
> > 
> > Cc: Steffen Klassert <steffen.klassert@secunet.com>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> > 
> > This patch is based on Steffen Klassert's ipsec tree. 
> > 
> >  net/ipv6/xfrm6_output.c | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> > 
> > diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
> > index 3ac5ab2..45effcc 100644
> > --- a/net/ipv6/xfrm6_output.c
> > +++ b/net/ipv6/xfrm6_output.c
> > @@ -59,10 +59,12 @@ static void xfrm6_local_rxpmtu(struct sk_buff *skb, u32 mtu)
> >  void xfrm6_local_error(struct sk_buff *skb, u32 mtu)
> >  {
> >  	struct flowi6 fl6;
> > +	struct ipv6hdr *hdr;
> >  	struct sock *sk = skb->sk;
> >  
> > +	hdr = skb->encapsulation ? inner_ipv6_hdr(skb) : ipv6_hdr(skb);
> >  	fl6.fl6_dport = inet_sk(sk)->inet_dport;
> > -	fl6.daddr = ipv6_hdr(skb)->daddr;
> > +	fl6.daddr = hdr->daddr;
> >  
> >  	ipv6_local_error(sk, EMSGSIZE, &fl6, mtu);
> >  }
> 
> You could have use "const struct ipv6hdr *hdr;", but otherwise :

Thanks for the review, Eric!

I do think such details matter, so I'll respin this series by tomorrow.
