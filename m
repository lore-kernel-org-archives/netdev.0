From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC PATCH] netfilter: conntrack: cache route for forwarded
 connections
Date: Tue, 2 Dec 2014 11:21:14 +0100
Message-ID: <20141202102114.GD16959@breakpoint.cc>
References: <1417480114-3002-1-git-send-email-fw@strlen.de>
 <alpine.LFD.2.11.1412020827260.1593@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	brouer@redhat.com, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1412020827260.1593@ja.home.ssi.bg>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Julian Anastasov <ja@ssi.bg> wrote:
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
> >  Sending as RFC since I haven't tested this yet (aside from
> >  single-forwarded-flow), so no performance data either.
> > 
> >   - doesn't work when iif changes (it invalidates cached dst), don't
> >   think its a problem
> 
> 	The idea is good. But code that caches dsts should
> also handle at least NETDEV_UNREGISTER (NETDEV_DOWN being
> another option) to release dsts. Holding dsts for frozen
> conns in EST state for long time is a problem.

Okay, point taken.  Thanks Julian.
