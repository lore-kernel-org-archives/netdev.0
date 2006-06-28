From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH]NET: Add ECN support for TSO
Date: Tue, 27 Jun 2006 21:54:39 -0700
Message-ID: <1151470479.3502.10.camel@rh4>
References: <1151464007.5124.13.camel@rh4>
 <20060628031052.GA4570@gondor.apana.org.au>
 <1151466034.5124.18.camel@rh4>
 <20060628034823.GA5125@gondor.apana.org.au>
 <1151469421.3502.3.camel@rh4>
 <20060628044209.GA5673@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:21777 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S932255AbWF1Exf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 00:53:35 -0400
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <20060628044209.GA5673@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-06-28 at 14:42 +1000, Herbert Xu wrote:
> On Tue, Jun 27, 2006 at 09:37:01PM -0700, Michael Chan wrote:

> > @@ -56,6 +55,9 @@ static inline void TCP_ECN_send(struct s
> >  			if (tp->ecn_flags&TCP_ECN_QUEUE_CWR) {
> >  				tp->ecn_flags &= ~TCP_ECN_QUEUE_CWR;
> >  				skb->h.th->cwr = 1;
> > +				if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
> > +					skb_shinfo(skb)->gso_type |=
> > +						SKB_GSO_TCPV4_ECN;
> 
> As a byte-pincher I must suggest that you turn this check into something
> like 
> 
> 				if (skb_shinfo(skb)->gso_type)
> 
> or even
> 
> 				if (skb_shinfo(skb)->gso_size)
> 
Assuming that we'll later have GSO_TCPV6, isn't it better to check for
TCPV4 explicitly now?  Or just change it later when necessary.

