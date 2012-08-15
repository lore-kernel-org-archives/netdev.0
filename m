From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH v2] net-tcp: TCP/IP stack bypass for loopback
 connections
Date: Wed, 15 Aug 2012 01:24:28 -0400
Message-ID: <20120815012428.c747fa9d.billfink@mindspring.com>
References: <1344559958-29162-1-git-send-email-brutus@google.com>
	<20120814023155.ffe9c01d.billfink@mindspring.com>
	<CAEkNxbFgr1Qws_Fp3igDhir-81R-XWr52inmuXb1MNS9NigU0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Bruce Curtis <brutus@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-galgo.atl.sa.earthlink.net ([209.86.89.61]:33069 "EHLO
	elasmtp-galgo.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750735Ab2HOFYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2012 01:24:33 -0400
In-Reply-To: <CAEkNxbFgr1Qws_Fp3igDhir-81R-XWr52inmuXb1MNS9NigU0Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Aug, Bruce Curtis wrote:

> On Mon, Aug 13, 2012 at 11:31 PM, Bill Fink <billfink@mindspring.com> wrote:
> >
> > On Thu,  9 Aug 2012, Bruce "Brutus" Curtis wrote:
> >
> > > From: "Bruce \"Brutus\" Curtis" <brutus@google.com>
> > >
> > > TCP/IP loopback socket pair stack bypass, based on an idea by, and
> > > rough upstream patch from, David Miller <davem@davemloft.net> called
> > > "friends", the data structure modifcations and connection scheme are
> > > reused with extensive data-path changes.
> > >
> > > A new sysctl, net.ipv4.tcp_friends, is added:
> > >   0: disable friends and use the stock data path.
> > >   1: enable friends and bypass the stack data path, the default.
> >
> > The following is from a user perspective, since I am not
> > intimately familiar with the internals of the TCP stack.
> >
> > I think tcp_friends is a poor name from a user POV.
> > Something like tcp_bypass would be much better.
> >
> > I also believe it should be disabled by default, as that is
> > the current behavior, and those who would gain an advantage
> > from using it can easily enable it.
> >
> > Changing the behavior would violate the principle of least
> > surprise.  Loopback TCP testing of an application or system
> > is often a useful first step in evaluating its behavior and
> > performance.  If the TCP stack is bypassed, it will give a
> > very false impression when such tests are performed.
> >
> > Does it preserve all TCP semantics for applications, including
> > things like urgent data, ancillary data, and TCP socket options
> > and ioctls.  If it doesn't, it shouldn't be the default, and it
> > should be documented what features do and don't work when
> > tcp_bypass is enabled.  If all TCP semantics are unchanged,
> > that would also be good to know and document.
> >
> > And there's the already mentioned issue of breaking tcpdump
> > and related tools.
> >
> > While this could be a very useful feature in some environments,
> > it seems to me it would be safest to have it disabled by default.
> >
> >                                         -Bill
> >
> 1) tcp_friends vs tcp_bypass, the average user will not need to know
> about this tunable so if there's consensus that it needs to be
> changed, change it?

I see no reason to make it obtuse rather than something more
descriptive of its function (as opposed to how it's implemented).

> 2) this is a throughput/latency advantage for most (all?) so it
> benefits most (all?) production environments

I grant that given that (4) below is true.

> 3) as for breaking tcpdump and ... Again, it does maintain the
> connection establishment and finish packet flow so for most TCP
> connection related interpose uses this should work and be documented
> but if your trying to debug TCP's protocol state-machine, network
> emulation, ... then Yes a user would need to disable but IMHO this is
> the exception
> 
> 4) all TCP socket semantics are maintained and if not it's a bug and
> needs to be fixed

This was my biggest concern if it wasn't true.  Since you have now
verified that all TCP semantics are preserved, I now don't have a
major issue with it being enabled by default, since it's easy to
disable for more specialized situations.

I do have some concern that since the loopback path through the
TCP stack won't be heavily exercised anymore, it may be more likely
for bugs or performance degradations to creep into that code.

						-Thanks

						-Bill
