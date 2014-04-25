From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC][PATCH] IP: Make ping sockets optional
Date: Fri, 25 Apr 2014 23:18:09 +0200
Message-ID: <20140425211809.GC7050@order.stressinduktion.org>
References: <1398266428.7767.140.camel@deadeye.wl.decadent.org.uk> <20140423153018.GA13717@breakpoint.cc> <1398268542.7767.145.camel@deadeye.wl.decadent.org.uk> <20140423162712.GB13717@breakpoint.cc> <20140424151748.GH1960@order.stressinduktion.org> <1398355320.7767.175.camel@deadeye.wl.decadent.org.uk> <20140424163712.GJ1960@order.stressinduktion.org> <CAKD1Yr0X5vqhdmFkwfgd0WJ0Jw7GGm8=iHNPeyfNKoODN4=1Mw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Florian Westphal <fw@strlen.de>,
	netdev <netdev@vger.kernel.org>,
	Vasiliy Kulikov <segoon@openwall.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:40514 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971AbaDYVSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 17:18:11 -0400
Content-Disposition: inline
In-Reply-To: <CAKD1Yr0X5vqhdmFkwfgd0WJ0Jw7GGm8=iHNPeyfNKoODN4=1Mw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 25, 2014 at 07:37:02PM +0900, Lorenzo Colitti wrote:
> On Fri, Apr 25, 2014 at 1:37 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > The origins of this interface are in the openwall project. I assume
> > embedded devices were not that high up on their agenda.
> 
> One of the original discussion threads I posted above has a link to a
> lengthy discussion on why the original designers of this code thought
> capabilities were not a good idea from a security standpoint.

Hmm, maybe I have overlooked it but I have not found any references to
capabilities.

> > We absolutely cannot abandon the interface as it already is in use by
> > android, as Lorenzo stated.
> 
> Well, the fact that it's in use by Android doesn't mean it can't be
> made optional - Android can just turn the feature on in their kernels.
> It would be unfortunate if it were to be removed entirely.
> 
> > Will android switch to file based capabilities
> > in some time? Is that possible?
> 
> I think Android does support file capabilities. But this socket type
> is not just for the ping binary. The fact that this socket type is
> available to any binary allows any application developer to write an
> app that can send ping packets. That seems like a useful capability
> for a diagnostic app.

Ok, I see. There seem to be more users of this on Android. I guess ping
sockets are available to every application writer or will it be set
dynamically because of application permissions? Sorry, I am not that common
with android.

> On the other hand, it seems to me that giving that same diagnostic app
> CAP_NET_RAW would be unacceptable from a security point of view since
> that app would now be able to sniff all traffic on the system, with
> obvious privacy implications. There are also the usual security
> concerns such as what if an exploit is discovered in the ping binary,
> etc. etc.

Ack, that's why my first hunch was to introduce a new capability just for ping
sockets. I assume this wouldn't work for android?

> What's the problem with this code? Is it just the 10KB in size?

I thought it was mostly unused. But now I heard that android uses it,
this is actually not true any more.

Bye,

  Hannes
