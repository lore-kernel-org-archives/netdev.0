From: Andreas =?iso-8859-1?Q?H=FCbner?= <andreas@k4n.de>
Subject: Re: icmpv6: issue with routing table entries from link local
 addresses
Date: Tue, 13 Sep 2016 08:35:09 +0200
Message-ID: <20160913063509.GJ26782@targo.k4n.de>
References: <20160912142732.GI26782@targo.k4n.de>
 <b6804e09-403f-64ff-257b-6c5fda7f8047@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "d. caratti" <davide.caratti@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from targo.k4n.de ([213.133.103.195]:43923 "EHLO targo.k4n.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751198AbcIMGfR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Sep 2016 02:35:17 -0400
Content-Disposition: inline
In-Reply-To: <b6804e09-403f-64ff-257b-6c5fda7f8047@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 12, 2016 at 07:26:23PM +0200, Hannes Frederic Sowa wrote:
> > Actually, I'm convinced I must be doing something wrong here. The setup
> > for the issue is quite trivial, someone would have tripped over it
> > already. The only condition is that one host has multiple interfaces
> > with ipv6 enabled.
> > 
> > Any help in shedding some light onto this issue would be appreciated.
> 
> This shouldn't be the case. We certainly carry over the ifindex of the
> received packet into the routing lookup of the outgoing packet, thus the
> appropriate rule, with outgoing ifindex should be selected.

I saw this in the code and that's the reason why I wrote the initial
mail. Was trying to trace with ftrace, but got stuck somewhere around
the find_rr_leaf function. (If there is any good documentation on the
internal fib data structure, please point me to it.)

> I also couldn't reproduce your problem here with my system. Can you
> verify with tcpdump that the packet is leaving on another interface?

It is not leaving on another interface but simply discarded on the host.
The Ip6OutNoRoutes stat in /proc/net/snmp6 is increased.
>From my understanding the routing subsystem finds the first matching entry
in the main routing table, checks the interface and bails out because it
does not match.

I did omit a crucial information in the last mail, I'm currently stuck
on an older distribution kernel (3.16).
I'll try to check if there have been any relevant changes to IPv6
route lookup in the last two years.
(Maybe I should try to reproduce it with the current kernel, sorry that
I didn't think of this before.)


Andreas
