From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: Weak host model vs .interface down
Date: Sat, 12 Jun 2010 09:27:48 +0930
Message-ID: <20100612092748.5fed4baf@lk-netdev.nosense.org>
References: <OF1D06F11A.44DE8C5A-ONC125773F.00437856-C125773F.004425B9@transmode.se>
	<4C126514.30905@hp.com>
	<OFE6F71D1A.A94BE06C-ONC125773F.005C80CF-C125773F.005DF884@transmode.se>
	<4C126EC6.9000506@hp.com>
	<OF73173D19.3439A8A1-ONC125773F.006BA38C-C125773F.006C31A4@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.adam.net.au ([202.136.110.247]:35715 "EHLO
	smtp4.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752473Ab0FKX54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 19:57:56 -0400
In-Reply-To: <OF73173D19.3439A8A1-ONC125773F.006BA38C-C125773F.006C31A4@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Jun 2010 21:41:45 +0200
Joakim Tjernlund <joakim.tjernlund@transmode.se> wrote:

> Rick Jones <rick.jones2@hp.com> wrote on 2010/06/11 19:13:42:
> >
> > > The weak model doesn't go into such detail, it is assumption/impl. detail
> > > to assume that the ip address still is part of the system even when the interface
> > > is down. One could just as well define interface down as temporarly removing
> > > the IP address from the system too. This makes make much more sense to me and
> > > if you always want the system to answer on a IP adress you make it an IP alias.
> > >
> > > Since the current behaviour is a problem to me and routers in general, can
> > > we change this? What is the current usage model which needs it to stay as is?
> >
> > Router != end-system  so I wouldn't think the weak or strong end-system model
> > would apply to a router.  I think Stephen already posted a patch to allow that
> > for when one's box was a router rather than an end-system.
> 
> Not really an anwser to what I was asking but I choose to read that as
> you agree with me. The rest is an impl. detail. :)
> Stephen's patch is good but I would not mind making I/F down removing the
> IP address from the system unconditionally.
> 

I've asked the same question a few years back and got the same answer.
I accept the strong host / weak host argument, however I've also
thought about the problem a bit more, and why people get confused about
it.

The problem is the mental model. Assigning an IP address to an
interface implies that the IP address as attached and associated with
the interface and therefore the state of the interface. That is
certainly the case for people like me who work with networking
equipment, typically routers, which follow the strong host model. It is
very convenient to know that by shutting down an interface the
associated IP address stops working too. Other measures, such as
ACLing, or writing down and deleting and then having put it back, are
relatively much more effort and error prone.

While I'm sure past operational history is likely to make this
impractical, it would be far more intuitive for weak host model IP
address assignments to be made to a single, forced always up virtual
interface on the host, and strong host IP address assignments made to
any other "non-weak host" interfaces.

It'd be an interesting experiment to see if loopback could be used as a
"host interface" in the weak host model.

Regards,
Mark.
