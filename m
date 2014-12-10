From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next 0/2] netfilter: conntrack: route cache for
 forwarded connections
Date: Wed, 10 Dec 2014 15:42:06 +0100
Message-ID: <20141210144206.GH6672@breakpoint.cc>
References: <1418052964-4632-1-git-send-email-fw@strlen.de>
 <20141210141319.GA5028@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, brouer@redhat.com,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141210141319.GA5028@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Mon, Dec 08, 2014 at 04:36:02PM +0100, Florian Westphal wrote:
> > [ Pablo, in case you deem this too late for -next just let me know
> > and I will resend once its open again ]
> > 
> > This adds an optional forward routing cache extension for netfilter
> > connection tracking.
> > 
> > The memory cost is an additional 32 bytes per conntrack entry
> > on x86_64.
> > 
> > Unlike any other currently implemented connection tracking
> > extension the rtcache has no run-time tunables, it is always active.
> > 
> > Also, unlike other conntrack extensions, it can be built as a module,
> > in this case modprobe/rmmod are used to enable/disable the cache.
> 
> I expect distributors will provide this a module. I think we should
> provide features that can be enable/disable in some way, in this case
> it can be modprobe/rmmod.

Yes, I just wanted to mention this in case someone thinks a sysctl is
must-have.

I did not want to add sysctl "just because" as we cannot easily rip
them out later.

> BTW, did you evaluate Eric's alternative? Any comment on that?

Right, sorry.  So Eric suggested to leverage existing early demux.

This would work, but I found several disadvantages, namely it would:

1. only work for protocols that have early demux support
2. have to add some sort of new mini-sk to the "right" data
structure (udp_table, tcp_hashinfo) so not just af but l4 specific
handling
3. add more code to L4 protocol handlers
4. add some upper ceiling for such "forward sockets".
5. devise a scheme by which to zap the entry again

4+5 can be avoided by embedding the "forward sock" inside conntrack,
but that would mean we get larger code than this patch while still
retaining the conntrack dependency.

And without conntrack, I'm not sure how one would go about
adding such route cache without adding back all the problems it had.

> If the merge window remains open, I'll take the pending patches in
> patchwork and send a new batch for David by tomorrow morning.
> 
> Let me know, thanks.

Ok.  I can send a rebased V3.  OTOH, I don't want to rush things.

If you think further discussion is needed before deciding to go with
a conntrack-based route cache then lets do that.

In this case I can resend the v3 once next is open again plus a summary
of the alternatives/problems and we can take it from there.

