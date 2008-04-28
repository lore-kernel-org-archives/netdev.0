From: Thomas Graf <tgraf@suug.ch>
Subject: Re: PATCH WAS( Re: [ANNOUNCE] iproute2 v2.6.25
Date: Mon, 28 Apr 2008 13:52:03 +0200
Message-ID: <20080428115203.GM20815@postel.suug.ch>
References: <1208467480.15888.50.camel@localhost> <1208522727.4422.79.camel@localhost> <4808AEBF.7040504@trash.net> <1208563696.4450.43.camel@localhost> <480A21AF.1040405@trash.net> <1208692128.12249.26.camel@localhost> <480C7F68.7090105@trash.net> <1208783227.12249.172.camel@localhost> <480C992C.6050406@trash.net> <1208787720.12249.207.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:33193 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762992AbYD1Lvn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 07:51:43 -0400
Content-Disposition: inline
In-Reply-To: <1208787720.12249.207.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* jamal <hadi@cyberus.ca> 2008-04-21 10:21
> On Mon, 2008-21-04 at 15:39 +0200, Patrick McHardy wrote:
> 
> > 
> > Yes, that would be nice, the iproute netlink infrastructure is really
> > lagging behind. 
> 
> Agreed.
> 
> > I'm not sure which way would be preferrable, build
> > something new on top of libnl without disturbing existing users or
> > gradually port iproute on top of libnl, probably starting with the
> > netlink infrastructure.
> 
> I would say build something new would be the proper way to go. Maintain
> output of ip/tc/ifconfig/route and phase them out slowly.

Personally I'm in favour of having many small tools like git, i.e.
rtnl-link-add, rtnl-link-list, etc.

Tools like NetworkManager are already using or currently being ported to
libnl and will hide almost all trivial networking configuration tasks
behind a nice gui.

Alternatively there can be an advanced configuration tool with a focus
on Linux being used as a router.

> The majority of new users out there may not have the same challenges i
> had:
> I wanted to do some simple things in a short period; i knew how to use
> libnetlink - i thought the mapping would be easy to follow from
> libnetlink to libnl; after a few hours, rather than investing more time
> i found it easier to update things on top of libnetlink.
> People who are totaly starting may find it easier to learn libnl first.
> I certainly do plan to poke fingers at libnl - i just happen to have
> something that works.

I'm not going to argue with you Jamal :-) In fact I'm pretty sure that
most of the basic tasks are really trivial with libnl and many common
tasks are now accessible via clean interfaces. I agree though that the
number of functions makes it difficult to find the proper interfaces.
That's why I'm thinking about splitting things up in components like
libnl, libnl-link, libnl-tc, etc. to separate the actual netlink library
from netlink family implementations. Won't happen before 2.0 though.
