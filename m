From: Guido Trotter <ultrotter@quaqua.net>
Subject: Re: Policy routing + route "via" gives a strange behavior
Date: Tue, 20 Oct 2009 19:23:34 +0200
Message-ID: <20091020172334.GA6404@gg.studio.tixteam.net>
References: <20091020132820.GA3159@gg.studio.tixteam.net> <200910201948.39778.atis@mikrotik.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Atis Elsts <atis@mikrotik.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-146-243.sn2.eutelia.it ([83.211.146.243]:53482 "EHLO
	gg.studio.tixteam.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752787AbZJTR2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 13:28:11 -0400
Content-Disposition: inline
In-Reply-To: <200910201948.39778.atis@mikrotik.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 20, 2009 at 07:48:39PM +0300, Atis Elsts wrote:

Hi,

Thanks for your explanation/help!

> > This is also refused unless a route like the one before appears in the
> > default table, even though it does appear in table 100. Is this the right
> > behavior, and if yes, why? 
> 
> I guess what you describe is too infrequent use case for anyone to really 
> care. Connected and link scoped routes are usually not added to policy 
> routing tables :) Can you explain more for what kind of setup this is needed?
> 

What I'm using it to is to force virtual machine traffic from a host to be
routed to a different interface (a gre interface, in my case). I set up a rule
that traffic from the guests' network (or from their interfaces) looks up a
different routing table, and in that table I set a default gateway so that any
traffic the instance would do is sent via that gateway.

> This "issue" could be solved by using routing table in the FIB lookup done in 
> fib_check_nh(). However, doing that would break a lot more setups than it 
> would "fix".
> For example, if you had these rules
>   from all to 1.2.3.4 fwmark 0x64 lookup 100
>   from all fwmark 0x64 unreachable
> then adding policy route to table 100 would fail unless nexthop 1.2.3.4 was 
> used...
> 
Not sure I follow you here, sorry! :/ How would it behave differently depending
on the rules used? If in table 100 I had something like:

ip route add 1.2.3.4 dev eth1 via 2.3.4.5

Then the traffic looking up 100 (which according to the rules is to 1.2.3.4, but
could be to something else as well) must be routed via 2.3.4.5.
Of course then in table 100 I need a route to 2.3.4.5, or I need one in the
default table (which is the only one that gets checked now).

> Anyway, you can achieve what you wish by using the "onlink" option, e.g.:
>   ip route add table 100 default dev eth1 via 192.168.5.254 onlink

I will try this, thanks! What I was doing now was something like:
ip route add 192.168.5.254/32 dev eth1 # no table 100
ip route add table 100 default dev eth1 via 192.168.5.254
ip route del 192.168.5.254/32 dev eth1

But it was kind of a nasty workaround. Although it was working :)

Thanks,

Guido

