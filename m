From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: Accept ESP packets regardless of UDP
 encapsulation mode
Date: Wed, 17 Dec 2008 19:49:42 -0800 (PST)
Message-ID: <20081217.194942.01082060.davem@davemloft.net>
References: <1228396731.1643.57.camel@martin>
	<E1LD9rC-0007y7-KY@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: martin@strongswan.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48705
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751320AbYLRDtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 22:49:41 -0500
In-Reply-To: <E1LD9rC-0007y7-KY@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 18 Dec 2008 14:47:26 +1100

> Martin Willi <martin@strongswan.org> wrote:
> > An IPsec node speaking IKEv2 MUST accept incoming UDP encapsulated
> > ESP packets, even if no NAT situation is detected. This is important
> > if MOBIKE is in use. Some implementation keep the encapsulation
> > mode if they move out of a NAT situation.
> > 
> > diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
> > index b4a1317..65bcf09 100644
> > --- a/net/xfrm/xfrm_input.c
> > +++ b/net/xfrm/xfrm_input.c
> > @@ -167,11 +167,6 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
> >                        goto drop_unlock;
> >                }
> > 
> > -               if ((x->encap ? x->encap->encap_type : 0) != encap_type) {
> > -                       XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEMISMATCH);
> > -                       goto drop_unlock;
> > -               }
> 
> This can't work as ESP relies on this check.  Now that it's gone
> ESP may touch a UDP header which doesn't exist.
> 
> What exactly are you trying to achieve?

IKEv2 daemon needs to be agnostic about this situation.  So we have to
accept everything, regardless of configured encapsulation type.

At least that is my impression after reading the MOBIKE documents.
