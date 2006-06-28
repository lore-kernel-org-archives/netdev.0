From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH]NET: Add ECN support for TSO
Date: Tue, 27 Jun 2006 20:40:34 -0700
Message-ID: <1151466034.5124.18.camel@rh4>
References: <1151464007.5124.13.camel@rh4>
 <20060628031052.GA4570@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:53010 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1751082AbWF1Dnx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 23:43:53 -0400
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <20060628031052.GA4570@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-06-28 at 13:10 +1000, Herbert Xu wrote:
> On Tue, Jun 27, 2006 at 08:06:47PM -0700, Michael Chan wrote:
> >
> > diff --git a/include/net/sock.h b/include/net/sock.h
> > index 2d8d6ad..2c75172 100644
> > --- a/include/net/sock.h
> > +++ b/include/net/sock.h
> > @@ -1033,7 +1033,8 @@ static inline void sk_setup_caps(struct 
> >  	if (sk->sk_route_caps & NETIF_F_GSO)
> >  		sk->sk_route_caps |= NETIF_F_TSO;
> >  	if (sk->sk_route_caps & NETIF_F_TSO) {
> > -		if (sock_flag(sk, SOCK_NO_LARGESEND) || dst->header_len)
> > +		if ((sock_flag(sk, SOCK_NO_LARGESEND) &&
> > +		    !tso_ecn_capable(sk->sk_route_caps)) || dst->header_len)
> >  			sk->sk_route_caps &= ~NETIF_F_TSO;
> 
> Why turn it off? With GSO in place the stack will handle it just fine
> (even your description says so :)  We should instead remove all code
> that turns off TSO/ECN when the other is present.
> 
We need to turn off NETIF_F_TSO for a connection that has negotiated to
turn on ECN if the output device cannot handle TSO and ECN.  In other
words, if the output device does not have either GSO or TSO_ECN feature
set.

