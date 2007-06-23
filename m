From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFD] L2 Network namespace infrastructure
Date: Sat, 23 Jun 2007 14:39:13 -0600
Message-ID: <m1myyq8ky6.fsf@ebiederm.dsl.xmission.com>
References: <m1tzszbwyb.fsf@ebiederm.dsl.xmission.com>
	<467CF8AC.80103@trash.net> <467D3A48.20706@candelatech.com>
	<m14pkya8fv.fsf@ebiederm.dsl.xmission.com>
	<467D7E0D.7060206@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Linux Containers <containers@lists.osdl.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:35409 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837AbXFWUkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 16:40:10 -0400
In-Reply-To: <467D7E0D.7060206@candelatech.com> (Ben Greear's message of "Sat,
	23 Jun 2007 13:09:49 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear <greearb@candelatech.com> writes:

> Any chance it could allow one to use a single threaded, single process and do
> something like
> int fd1 = socket(...., namespace1);
> int fd2 = socket(...., namespace2);
>
> Or, maybe a sockopt or similar call to move a socket into a particular
> namespace?
>
> I can certainly see it being useful to allow a default name-space per process,
> but it would be nice
> to also allow explicit assignment of a socket to a name-space for applications
> that want to span
> a large number of name-spaces.

That isn't the primary use case so I have not considered it much.
A setsockopt call might be possible.

It is also possible to have a bunch of children opening sockets for you
and passing to the process that wants to do the work. If you have a
sufficiently slow socket creation rate that will not be a problem just
a little cumbersome.

If you can open all of your sockets upfront it is possible to do
something where you open your sockets then unshare your network
namespace and repeat.

I am committed to making general infrastructure not something that is
targeted in a brittle way at only one scenario.

So it may be that we can cover your scenario.  However it is just
enough off of the beaten path that I'm not going to worry about it
the first time through.  It looks like it is a very small step from
where I am at to where you want to be.  So you may be able to cook
up something that will satisfy your requirements relatively easily.

Eric
