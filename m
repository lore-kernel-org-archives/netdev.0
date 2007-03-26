From: Joy Latten <latten@austin.ibm.com>
Subject: Re: [PATCH]: SAD sometimes has double SAs.
Date: Mon, 26 Mar 2007 17:25:33 -0600
Message-ID: <1174951534.3085.377.camel@faith.austin.ibm.com>
References: <200703232258.l2NMwKqH016994@faith.austin.ibm.com>
	 <1174944899.17953.20.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	herbert@gondor.apana.org.au, jmorris@namei.org, paul.moore@hp.com,
	vyekkirala@trustedcs.com
To: Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:57555 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933741AbXCZXmI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Mar 2007 19:42:08 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2QNg67k015656
	for <netdev@vger.kernel.org>; Mon, 26 Mar 2007 19:42:06 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2QNg6Di250850
	for <netdev@vger.kernel.org>; Mon, 26 Mar 2007 19:42:06 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2QNg5KS028419
	for <netdev@vger.kernel.org>; Mon, 26 Mar 2007 19:42:06 -0400
In-Reply-To: <1174944899.17953.20.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-03-26 at 17:34 -0400, Eric Paris wrote:
> On Fri, 2007-03-23 at 16:58 -0600, Joy Latten wrote:
> 
> > @@ -710,11 +713,20 @@ static struct xfrm_state *__find_acq_cor
> >  
> >  		switch (family) {
> >  		case AF_INET:
> > +			if (x->id.daddr.a4 == saddr->a4 &&
> > +			    x->props.saddr.a4 == daddr->a4)
> > +				track_opposite = 1;
> >  			if (x->id.daddr.a4    != daddr->a4 ||
> >  			    x->props.saddr.a4 != saddr->a4)
> >  				continue;
> >  			break;
> >  		case AF_INET6:
> > +			if (ipv6_addr_equal((struct in6_addr *)x->id.daddr.a6,
> > +					     (struct in6_addr *)saddr) ||
> > +			    ipv6_addr_equal((struct in6_addr *)
> > +					     x->props.saddr.a6,
> > +					     (struct in6_addr *)daddr))
> > +					track_opposite = 1;
> >  			if (!ipv6_addr_equal((struct in6_addr *)x->id.daddr.a6,
> >  					     (struct in6_addr *)daddr) ||
> >  			    !ipv6_addr_equal((struct in6_addr *)
> 
> I'm not at all able to speak on the correctness or validity of the
> solution, but shouldn't the ipv6 case be a && not an || like the ipv4
> case?  Isn't this going to match all sorts of things?  Did you test this
> patch on ipv6 and see it to solve your problem?
> 
Will fix this and resend. Sorry, forgot about ipv6. My mistake! :-( 

> I'm also not enjoying the formatting in the ipv6 part where the first
> time you have the cast on the same time as the object but not the second
> part where x->props.saddr.a6 is on its own little line.
> 
ok. 

Joy

