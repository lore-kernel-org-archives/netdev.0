From: Brian Haley <brian.haley@hp.com>
Subject: Re: linux kernel's IPV6_MULTICAST_HOPS default is 64; should be 1?
Date: Tue, 04 May 2010 12:43:05 -0400
Message-ID: <4BE04E99.2080903@hp.com>
References: <OFD462DFA3.FF279B8C-ON88257719.0057B1F8-88257719.005914D6@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, enh@google.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:33913 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760039Ab0EDQn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 12:43:28 -0400
In-Reply-To: <OFD462DFA3.FF279B8C-ON88257719.0057B1F8-88257719.005914D6@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Stevens wrote:
> I think the original code was intending to do late binding -- carry "-1" 
> as
> meaning "not set by user" and use the default value _at_the_time_of_
> _the_send_, and in its context. For that to have worked, the checks for
> "<0" in the send paths should've checked for multicast and used the
> multicast default as you're saying, Brian. And doing that not on the
> set, but when generating packets, is what I would've expected.

Right, we could do it that way, but then how far do we unravel the thread?
Unicast hoplimit is settable in the route, do we add a mcast_hops there
too, in addition to the per-interface tunable?  I think just having it
the recommended default is good enough here, until someone shows they
have the need to do more.

> I don't see anything that's broken by changing it to use the default at
> the time of the set since for mcast the default is really a constant,
> and in fact, it looks like in addition to not actually using the default 
> of 1,
> it was returning "-1" in the cmsg when not set by the user (and it, too,
> should've been "1", which it would return now).
> 
> But if the default is different for each destination or interface in
> the multicast case (ie, by adding conf settings for mcast), then
> it really should do late binding and leave it as "-1" in the set, right?
> That's what I thought it was already doing, but apparently not;
> I think it used to, but maybe I just didn't notice.

Yes, that would be the ideal fix, and give the admin more control over
the value, but it seems like overkill to me.  It's been 64 for a while,
and it's always been changeable by apps.  I guess the only thing to
think about is there could be an app that works because it being 64
today, but will break tomorrow.  Having a tunable parameter will let
you get the app working without re-writing it.

-Brian
