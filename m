From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Sat, 28 Nov 2009 20:05:01 +0100
Message-ID: <20091128190500.GB12264@sch.bme.hu>
References: <db81a9a20911230443h443b3c2l8fab5aef7b09cfa@mail.gmail.com> <1259137434.9191.3.camel@nienna.balabit> <db81a9a20911260919w1ffded25ref5ae24ee73f8eda@mail.gmail.com> <1259310417.3809.5.camel@nienna.balabit> <1259337932.3299.3.camel@bigi> <20091128151515.GA20476@sch.bme.hu> <4B1145F1.3090704@trash.net> <1259424278.3864.16.camel@bigi> <4B1158CE.90803@trash.net> <1259429774.3864.41.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	KOVACS Krisztian <hidden@sch.bme.hu>,
	KOVACS Krisztian <hidden@balabit.hu>,
	Andreas Schultz <aschultz@warp10.net>, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from centaur.sch.bme.hu ([152.66.208.5]:50983 "EHLO
	centaur.sch.bme.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753490AbZK1TE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 14:04:56 -0500
Content-Disposition: inline
In-Reply-To: <1259429774.3864.41.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On szo, nov 28, 2009 at 12:36:14 -0500, jamal wrote:
> On Sat, 2009-11-28 at 18:07 +0100, Patrick McHardy wrote:
> 
> > Right, its source validation. But the setup is valid, its asking for
> > specifically marked packets to be delivered locally for transparent
> > proxying. There's no requirement that rules using marks must resolve
> > to RTN_UNICAST.
> 
> True, but that requirement is needed for source validation;->
> i.e it is source address validation imposing the requirement
> that we must have a RTN_UNICAST route. The tproxy iproute setup entered
> a route that was not RTN_UNICAST. I think that the packet deserves to be
> beaten with a club then dropped hard into an abyss (Feel free to come up
> with  something more medievial to do to it Patrick;-> )
> 
> It doesnt make sense to have a source address that is not unicast
> belonging to a host or pretending to belong to a host.

The source address *is* unicast. The problem is that the routing setup is
asymmetrical, as Patrick has already mentioned: we're using a mark to
force certain packets (those that have matching sockets on the host) being
delivered locally.

In the other direction, reply packets won't be marked by the iptables
rules and thus will be routed on egress just fine. Your modification has
the assumption that routing is symmetrical, and that reply packets will
have the same mark. That assumption is not necessarily right, and I think
it's not entirely unreasonable to think that not only tproxy setups will
be broken by the change.

> So i didnt introduce that logic thats causing this pain.

Well, it depends whether or not you consider the initial setup valid.

> If it worked before it was hack or fluke imo ;-> If we think that
> source address validation needs to check for something else
> additionally, i think thats a separate topic (but doesnt
> seem worth a change)

My only concern is that this definitely breaks current setups, and while
we do have a workaround we don't have a way to let all users know what
needs to be done...

-- 
KOVACS Krisztian
