From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC alternate] ipv6: addrconf: clean up device type handling
Date: Wed, 30 Jul 2014 18:44:46 +0200
Message-ID: <1406738686.6757.18.camel@localhost>
References: <20140730153503.GJ801478@jupiter.n2.diac24.net>
	 <1406735921-122830-1-git-send-email-equinox@diac24.net>
	 <1406736755.6757.15.camel@localhost>
	 <20140730162337.GK801478@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jiri Pirko <jiri@resnulli.us>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:49138 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754948AbaG3Qot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 12:44:49 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by gateway1.nyi.internal (Postfix) with ESMTP id C357124B73
	for <netdev@vger.kernel.org>; Wed, 30 Jul 2014 12:44:48 -0400 (EDT)
In-Reply-To: <20140730162337.GK801478@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mi, 2014-07-30 at 18:23 +0200, David Lamparter wrote:
> On Wed, Jul 30, 2014 at 06:12:35PM +0200, Hannes Frederic Sowa wrote:
> > On Mi, 2014-07-30 at 17:58 +0200, David Lamparter wrote:
> [cut]
> > > This is an alternate version, yanking the switch() down and removing
> > > dev_config/gre_config duplication.  I have no idea what rationale is behind
> > > prefix_route - the result is a fe80::/64 route, but no address, which is not a
> > > functioning configuration.  Jiri, you touched this just a few weeks ago, can
> > > you comment?  (The "XXX: why is GRE special?")
> > 
> > Sure, it is valid. You can still use global addresses to talk to link
> > local addresses on the same link, even from another interface.
> 
> Okay, well, that may give some purpose to it, but doesn't really explain
> why GRE is special in this regard...
> 
> (And it's a violation of RFC4291 section 2.1 - "All interfaces are
> required to have at least one Link-Local unicast address" - and I'd bet
> on ndisc doing weird things in a setup like that.)

Yep - sure. But we also allow someone to remove the ll address manually.
And people did do that to transition the interface into an
disable_ipv6=1 mode, which had its own problems.

We don't care if the user does rfc compliant configurations. :)
The settings in the kernel should just be reasonable.
