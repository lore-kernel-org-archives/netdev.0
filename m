From: Salam Noureddine <noureddine@aristanetworks.com>
Subject: Re: Issue with gratuitous arps when new addr is different from cached addr
Date: Wed, 20 Nov 2013 22:33:17 -0800
Message-ID: <CAO7SqHCUmqNqYwhJtP9iRjG=pyc5Uhnf5eYhXN-mkQLr1oZsWQ@mail.gmail.com>
References: <CAO7SqHAVz2D53u141Za01DvBFnLky2imkYNvBV-2UuALpC3w6w@mail.gmail.com>
	<20131121044048.GB4347@order.stressinduktion.org>
	<CAO7SqHC4astdejH6wVAyjsVeuh96T8P3ao3bCDNs=opfv5bbUg@mail.gmail.com>
	<20131121062349.GC4347@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Salam Noureddine <noureddine@aristanetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	Phil Sutter <phil@nwl.cc>, Eric Dumazet <edumazet@google.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f176.google.com ([209.85.128.176]:34975 "EHLO
	mail-ve0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902Ab3KUGdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 01:33:17 -0500
Received: by mail-ve0-f176.google.com with SMTP id oz11so2287956veb.7
        for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 22:33:17 -0800 (PST)
In-Reply-To: <20131121062349.GC4347@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 20, 2013 at 10:23 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Wed, Nov 20, 2013 at 10:06:34PM -0800, Salam Noureddine wrote:
>> Isn't locktime useful in that case for limiting the rate of garp
>> changes to the arp cache?
>
> Yes, as I said, it would be nice to have rate-limiting for those, too.
>
> GARP is used in cluster setups to make the switch-over as fast as possible and
> I don't think they accept those lock-down delays, so I guess it would be nice
> to forceful override the lladdr if (sip == tip) && ACCEPT_ARP(dev) is true in
> every case.

I was in fact testing a switch-over scenario and saw that the arp
update was taking
much longer than the locktime period which pointed to this problem.

>
> I guess you are not testing with ACCEPT_ARP?
>

Yes, I am not setting ACCEPT_ARP.

> In that case I am not sure what to do.
>
> override = (...timing...) || sip == tip; could work but does relax the
> protection of the neigh cache.
>
> In IPv6 we have a flag in the packet if we should overwrite the entry.
>
> I'll have to think about that a bit more. Could well be the case that we need
> your proposal, too. But then we would have to validate the change with IPv6,
> too and neighbour cache states are really complex.
>
> Greetings,
>
>   Hannes
>
