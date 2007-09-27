From: David Miller <davem@davemloft.net>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Thu, 27 Sep 2007 12:08:03 -0700 (PDT)
Message-ID: <20070927.120803.39482469.davem@davemloft.net>
References: <20070927073446.GA14643@gondor.apana.org.au>
	<1190896785.4290.18.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60573
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756013AbXI0TIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 15:08:07 -0400
In-Reply-To: <1190896785.4290.18.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Thu, 27 Sep 2007 08:39:45 -0400

> nice work. I like the egress flag idea;->
> and who would have thunk stateless nat could be written in such a few
> lines ;-> I would have put the checksum as a separate action but it is
> fine the way you did it since it simplifies config.
> more comments below.
> 
> On Thu, 2007-27-09 at 15:34 +0800, Herbert Xu wrote:
> 
> > +config NET_ACT_NAT
> > +        tristate "Stateless NAT"
> > +        depends on NET_CLS_ACT
> > +        select NETFILTER
> 
> I am gonna have to agree with Evgeniy on this Herbert;->
> The rewards are it will improve performance for people who dont need
> netfilter.
> Ok, who is gonna move the csum utility functions out? /me looks at
> Evgeniy;->
> I could do it realsoonnow if noone raises their hands. 
> In any case, it would be real nice to have but i dont see it as a show
> stopper for inclusion.

I agree that we should move the functions out.   However...

You have to realize that this logic is a complete crock
of shit for %99.99999999999999999999 of Linux users out there
who get and only use distribution compiled kernels which are
going to enable everything anyways.

So we better make sure there are zero performance implications at some
point just for compiling netfilter into the tree.  I know that isn't
the case currently, but that means that we aren't helping out the
majority of Linux users and are thus only adding these optimizations
for such a small sliver of users and that is totally pointless and
sucks.
