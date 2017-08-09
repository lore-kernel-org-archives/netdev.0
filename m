From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 0/7] rtnetlink: allow to run selected handlers
 without rtnl
Date: Wed, 9 Aug 2017 10:19:28 +0200
Message-ID: <20170809081928.GA26899@breakpoint.cc>
References: <20170808.213329.522107918983433411.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:38344 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752324AbdHIIVm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 04:21:42 -0400
Content-Disposition: inline
In-Reply-To: <20170808.213329.522107918983433411.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Tue,  8 Aug 2017 18:02:29 +0200
> 
> > Unfortunately RTNL mutex is a performance issue, e.g. a cpu adding
> > an ip address prevents other cpus from seemingly unrelated tasks
> > such as dumping tc classifiers.
> 
> It is related if somehow the TC entries refer to IP addresses.
>
> Someone could create something like that.

Actually I am not following.  Why would read-only accesses need rtnl
locking wrt. any other operation (provided of course rtnl lock doesn't
protect the data structure)?

> > Initial no-rtnl spots are ip6 fib add/del and netns new/getid.
> 
> I could see the netns stuff being ok, but IPv6 route add/del I'm
> not so sure of.

[..]

> There really is a hierachy of these dependencies.  Device state, up
> to neighbour table state, up to protocol address state, up to routes,
>    up to FIB tables, etc. etc. etc.
> 
>    I'd really like to make this operate more freely, but this is an
>    extremely delicate area which has been bottled up like this for
>    two decades so good luck :-)

Would you accept a v2 if i don't touch ipv6 routes for the time being?

I would then audit those again.  At the very least inet6_rtm_getroute should
be able to work without rtnl lock (i.e., use a different lock if
needed to protect vs. concurrent modifications).
