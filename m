From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH]: SAD sometimes has double SAs.
Date: Mon, 26 Mar 2007 17:34:59 -0400
Message-ID: <1174944899.17953.20.camel@localhost.localdomain>
References: <200703232258.l2NMwKqH016994@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	herbert@gondor.apana.org.au, jmorris@namei.org, paul.moore@hp.com,
	vyekkirala@trustedcs.com
To: Joy Latten <latten@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50003 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932809AbXCZVgi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Mar 2007 17:36:38 -0400
In-Reply-To: <200703232258.l2NMwKqH016994@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-03-23 at 16:58 -0600, Joy Latten wrote:

> @@ -710,11 +713,20 @@ static struct xfrm_state *__find_acq_cor
>  
>  		switch (family) {
>  		case AF_INET:
> +			if (x->id.daddr.a4 == saddr->a4 &&
> +			    x->props.saddr.a4 == daddr->a4)
> +				track_opposite = 1;
>  			if (x->id.daddr.a4    != daddr->a4 ||
>  			    x->props.saddr.a4 != saddr->a4)
>  				continue;
>  			break;
>  		case AF_INET6:
> +			if (ipv6_addr_equal((struct in6_addr *)x->id.daddr.a6,
> +					     (struct in6_addr *)saddr) ||
> +			    ipv6_addr_equal((struct in6_addr *)
> +					     x->props.saddr.a6,
> +					     (struct in6_addr *)daddr))
> +					track_opposite = 1;
>  			if (!ipv6_addr_equal((struct in6_addr *)x->id.daddr.a6,
>  					     (struct in6_addr *)daddr) ||
>  			    !ipv6_addr_equal((struct in6_addr *)

I'm not at all able to speak on the correctness or validity of the
solution, but shouldn't the ipv6 case be a && not an || like the ipv4
case?  Isn't this going to match all sorts of things?  Did you test this
patch on ipv6 and see it to solve your problem?

I'm also not enjoying the formatting in the ipv6 part where the first
time you have the cast on the same time as the object but not the second
part where x->props.saddr.a6 is on its own little line.

-Eric

