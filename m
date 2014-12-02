From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC PATCH] netfilter: conntrack: cache route for forwarded
 connections
Date: Tue, 2 Dec 2014 11:20:08 +0100
Message-ID: <20141202102008.GC16959@breakpoint.cc>
References: <1417480114-3002-1-git-send-email-fw@strlen.de>
 <1417484203.4442.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	brouer@redhat.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:60714 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753945AbaLBKUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 05:20:12 -0500
Content-Disposition: inline
In-Reply-To: <1417484203.4442.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-12-02 at 01:28 +0100, Florian Westphal wrote:
> > ... to avoid per-packet FIB lookup if possible.
> > 
> > The cached dst is re-used provided the input interface
> > is the same as that of the previous packet in the same direction.
> > 
> > If not, the cached dst is invalidated.
> > 
> > This should speed up forwarding when conntrack is already in use
> > anyway, especially when using reverse path filtering -- active RPF
> > enforces two FIB lookups for each packet.
> > 
> > Before the routing cache removal this didn't matter since RPF
> > was performed only when route cache didn't yield a result; but without
> > route cache it comes at high price.
> > 
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> > ---
> 
> Seems a good idea (but you might need some IPv6 care, as ( dst =
> dst_check(dst, 0); ) seems to handle IPv4 only)

As usual, you're right...

AFAICS its enough to stash fib sernum of the rt6info too and pass
that as the cookie, phew :-)

> Another idea would be to re-use TCP ehash so that regular IP early demux
> can be used, with a single lookup for both local and forwarded sessions.

Hmm, I'll look at this.  Maybe...

> (That would probably require a bit more memory, as you would need to
> insert into TCP ehash some kind of 'tiny sockets' )

... such tiny socket could be stored/tied to the conntrack extension
area.

I think we need to be careful to not re-add the route cache (and the DoS
issues associated with it).

Thanks Eric!
